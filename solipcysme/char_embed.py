# solipcysme -- spacy pipeline for french texts focused on personal pronouns and verbal moods
# Copyright (C) 2024,2025  thjbdvlt
#
# solipcysme is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published
# by the Free Software Foundation, either version 3 of the License,
# or (at your option) any later version.
#
# solipcysme is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with solipcysme.  If not, see <https://www.gnu.org/licenses/>.


from .doc_to_array import to_utf8_array
from .feature_extractor import SolipcysmeFeatureExtractor

from typing import List, Union, cast

from thinc.api import (
    HashEmbed,
    Maxout,
    Model,
    chain,
    concatenate,
    list2ragged,
    ragged2list,
    with_array,
)
from thinc.types import Floats2d, Ints2d, Ragged

from spacy.attrs import intify_attr
from spacy.errors import Errors
from spacy.tokens import Doc
from spacy.util import registry
from spacy.ml.staticvectors import StaticVectors


def _CharEmbSuff(
    nM: int, nCstart: int, nCend: int
) -> Model[List[Doc], List[Floats2d]]:
    # nM: Number of dimensions per character.
    # nCstart/nCend: Number of characters (prefix / suffix).
    nC = nCstart + nCend
    return Model(
        "charembed",
        forward,
        init=init,
        dims={"nM": nM, "nC": nC, "nO": nM * nC, "nV": 256},
        params={"E": None, "nCstart": nCstart, "nCend": nCend},
    )


def init(model: Model, X=None, Y=None):
    vectors_table = model.ops.alloc3f(
        model.get_dim("nC"), model.get_dim("nV"), model.get_dim("nM")
    )
    model.set_param("E", vectors_table)


def forward(model: Model, docs: List[Doc], is_train: bool):
    if docs is None:
        return []
    ids = []
    output = []
    E = model.get_param("E")
    nC = model.get_dim("nC")
    nM = model.get_dim("nM")
    nO = model.get_dim("nO")
    nCstart = model.get_param("nCstart")
    nCend = model.get_param("nCend")
    nCv = model.ops.xp.arange(nC)
    for doc in docs:
        doc_ids = model.ops.asarray(to_utf8_array(doc, nCstart, nCend))
        doc_vectors = model.ops.alloc3f(len(doc), nC, nM)
        doc_vectors[:, nCv] = E[nCv, doc_ids[:, nCv]]
        output.append(doc_vectors.reshape((len(doc), nO)))
        ids.append(doc_ids)

    def backprop(d_output):
        dE = model.ops.alloc(E.shape, dtype=E.dtype)
        for doc_ids, d_doc_vectors in zip(ids, d_output):
            d_doc_vectors = d_doc_vectors.reshape(
                (len(doc_ids), nC, nM)
            )
            dE[nCv, doc_ids[:, nCv]] += d_doc_vectors[:, nCv]
        model.inc_grad("E", dE)
        return []

    return output, backprop


@registry.architectures("SolipcysmeCharEmbed")
def SolipcysmeCharEmbed(
    width: int,
    rows: List[int],
    nM: int,
    nCstart: int,
    nCend: int,
    include_static_vectors: bool,
    features: List[Union[int, str]] = ["NORM"],
    u_features: List[Union[int, str]] = [],
) -> Model[List[Doc], List[Floats2d]]:
    nC: int = nCstart + nCend

    # replace Attribute names by their IDs
    features = [intify_attr(i) for i in features]

    # at least one Attribute is required
    if len(features) == 0:
        raise ValueError(Errors.E911.format(feat="[]"))

    # character embeddings
    char_embed = chain(
        _CharEmbSuff(nM=nM, nCstart=nCstart, nCend=nCend),
        cast(Model[List[Floats2d], Ragged], list2ragged()),
    )

    # >>>>>>>>>>>>>>>>>>>
    # from MultiHashEmbed
    seed = 7

    def make_hash_embed(index):
        nonlocal seed
        seed += 1
        return HashEmbed(
            width, rows[index], column=index, seed=seed, dropout=0.0
        )

    embeddings = [
        make_hash_embed(i)
        for i in range(len(features) + len(u_features))
    ]
    # <<<<<<<<<<<<<<<<<<<

    feature_extractor: Model[List[Doc], Ragged] = chain(
        SolipcysmeFeatureExtractor(features, u_features),
        cast(Model[List[Ints2d], Ragged], list2ragged()),
        # >>>>>>>>>>>>>>>>>>>
        # from MultiHashEmbed
        with_array(concatenate(*embeddings)),
        # <<<<<<<<<<<<<<<<<<<
    )

    # FeatsWidth depends on number of features and of include_static_vectors
    len_feats = len(embeddings) + include_static_vectors
    width_feats = width * len_feats
    size_input = (nM * nC) + width_feats

    max_out: Model[Ragged, Ragged]
    if include_static_vectors:
        max_out = with_array(
            Maxout(
                width,
                size_input,
                nP=3,
                normalize=True,
                dropout=0.0,
            )
        )
        model = chain(
            concatenate(
                char_embed,
                feature_extractor,
                StaticVectors(width, dropout=0.0),
            ),
            max_out,
            ragged2list(),
        )
    else:
        max_out = with_array(
            Maxout(
                width,
                size_input,
                nP=3,
                normalize=True,
                dropout=0.0,
            )
        )
        model = chain(
            concatenate(
                char_embed,
                feature_extractor,
            ),
            max_out,
            ragged2list(),
        )
    return model

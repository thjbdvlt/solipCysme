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

from spacy.tokens import Doc
from spacy.util import registry
from spacy.ml.staticvectors import StaticVectors


@registry.architectures("SolipcysmeMultiHash")
def SolipcysmeMultiHash(
    width: int,
    features: List[Union[str, int]],
    u_features: List[Union[str, int]],
    rows: List[int],
    include_static_vectors: bool,
) -> Model[List[Doc], List[Floats2d]]:
    """Construct an embedding layer that separately embeds a number of lexical attributes using hash embedding, concatenates the results, and passes it through a feed-forward subnetwork to build a mixed representation.

    The features used can be configured with the 'attrs' argument. The suggested attributes are NORM, PREFIX, SUFFIX and SHAPE. This lets the model take into account some subword information, without constructing a fully character-based representation. If pretrained vectors are available, they can be included in the representation as well, with the vectors table kept static (i.e. it's not updated).

    The `width` parameter specifies the output width of the layer and the widths of all embedding tables. If static vectors are included, a learned linear layer is used to map the vectors to the specified width before concatenating it with the other embedding outputs. A single Maxout layer is then used to reduce the concatenated vectors to the final width.

    The `rows` parameter controls the number of rows used by the `HashEmbed` tables. The HashEmbed layer needs surprisingly few rows, due to its use of the hashing trick. Generally between 2000 and 10000 rows is sufficient, even for very large vocabularies. A number of rows must be specified for each table, so the `rows` list must be of the same length as the `attrs` parameter.

    width (int): The output width. Also used as the width of the embedding tables. Recommended values are between 64 and 300.
    attrs (list of attr IDs): The token attributes to embed. A separate embedding table will be constructed for each attribute.
    rows (List[int]): The number of rows in the embedding tables. Must have the same length as attrs.
    include_static_vectors (bool): Whether to also use static word vectors. Requires a vectors table to be loaded in the Doc objects' vocab.
    """

    n_features = len(features) + len(u_features)

    if len(rows) != n_features:
        raise ValueError(
            f"Mismatched lengths: {len(rows)} vs {n_features}"
        )
    seed = 7

    def make_hash_embed(index):
        nonlocal seed
        seed += 1
        return HashEmbed(
            width, rows[index], column=index, seed=seed, dropout=0.0
        )

    embeddings = [make_hash_embed(i) for i in range(n_features)]
    concat_size = width * (len(embeddings) + include_static_vectors)
    max_out: Model[Ragged, Ragged] = with_array(
        Maxout(width, concat_size, nP=3, dropout=0.0, normalize=True)
    )
    if include_static_vectors:
        feature_extractor: Model[List[Doc], Ragged] = chain(
            SolipcysmeFeatureExtractor(features, u_features),
            cast(Model[List[Ints2d], Ragged], list2ragged()),
            with_array(concatenate(*embeddings)),
        )
        model = chain(
            concatenate(
                feature_extractor,
                StaticVectors(width, dropout=0.0),
            ),
            max_out,
            ragged2list(),
        )
    else:
        model = chain(
            SolipcysmeFeatureExtractor(list(features, u_features)),
            cast(Model[List[Ints2d], Ragged], list2ragged()),
            with_array(concatenate(*embeddings)),
            max_out,
            ragged2list(),
        )
    return model

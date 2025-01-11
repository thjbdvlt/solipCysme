from typing import Callable, List, Tuple, Union
from thinc.api import Model, registry
from thinc.types import Ints2d
from spacy.tokens import Doc
from .doc_to_array import to_array


@registry.layers("SolipcysmeFeatureExtractor")
def SolipcysmeFeatureExtractor(
    columns: List[Union[int, str]], u_columns
) -> Model[List[Doc], List[Ints2d]]:
    return Model(
        "extract_features",
        forward_underscore,
        attrs={"columns": columns, "u_columns": u_columns},
    )


def forward_underscore(
    model: Model[List[Doc], List[Ints2d]], docs, is_train: bool
) -> Tuple[List[Ints2d], Callable]:
    columns = model.attrs["columns"]

    u_columns = model.attrs["u_columns"]
    n_u_columns = len(u_columns)
    n_columns = len(columns)

    features: List[Ints2d] = []
    for doc in docs:
        if hasattr(doc, "to_array"):
            attrs = to_array(
                doc,
                columns,
                n_u_columns,
            )
        else:
            attrs = to_array(
                doc.doc,
                columns,
                n_u_columns,
            )[doc.start : doc.end]

        # `u_features` are taken from `Doc._` and must be iterables of the same length as the Doc.
        for i in range(n_u_columns):
            attrs[:, n_columns + i] = getattr(doc._, u_columns[i])

        if attrs.ndim == 1:
            attrs = attrs.reshape((attrs.shape[0], 1))

        features.append(model.ops.asarray2i(attrs, dtype="uint64"))

    backprop: Callable[[List[Ints2d]], List] = lambda d_features: []
    return features, backprop

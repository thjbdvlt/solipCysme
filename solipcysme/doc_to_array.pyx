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


cimport cython
cimport numpy as np
import numpy
from spacy.attrs cimport attr_id_t
from spacy.typedefs cimport attr_t
from spacy.tokens.token cimport Token, TokenC
from spacy.tokens.doc cimport Doc, get_token_attr
from spacy.attrs import IDS, intify_attr
from spacy.errors import Errors


@cython.boundscheck(False)
def to_utf8_array(doc, int nCstart, int nCend):
    """Minimally modified method `Doc.to_utf8_array()`.

    Args:
        doc (Doc)
        nCstart (int): Number of characters at the start of word.
        nCend (int): Number of characters at the end of word.

    Returns (ndarray)
    """

    byte_strings = [token.norm_.encode('utf8') for token in doc]
    cdef int nr_char = nCstart + nCend
    if nr_char == -1:
        nr_char = max(len(bs) for bs in byte_strings)
    cdef np.ndarray output = numpy.zeros(
        (len(byte_strings), nr_char), dtype='uint8'
    )
    output.fill(255)
    cdef int i, j, start_idx, end_idx
    cdef bytes byte_string
    for i, byte_string in enumerate(byte_strings):
        j = 0
        start_idx = 0
        end_idx = len(byte_string) - 1
        while j < nCend:
            if end_idx >= 0:
                output[i, j] = <unsigned char>byte_string[end_idx]
                end_idx -= 1
            j += 1
        while j < nr_char:
            if start_idx <= end_idx:
                output[i, j] = <unsigned char>byte_string[start_idx]
                start_idx += 1
            j += 1
    return output


@cython.boundscheck(False)
cpdef np.ndarray to_array(Doc doc, object py_attr_ids, int n_sup_dim):
    """Minimally modified method `Doc.to_array()`

    Args:
        doc (Doc)
        py_attr_ids (object)
        n_sup_dim (int):  The number of additional dimensions.

    Returns (ndarray)
    """

    cdef int i, j
    cdef np.ndarray[attr_t, ndim=2] output
    if isinstance(py_attr_ids, str):
        py_attr_ids = [py_attr_ids]
    elif not hasattr(py_attr_ids, "__iter__"):
        py_attr_ids = [py_attr_ids]
    try:
        py_attr_ids = [
            (IDS[id_.upper()] if hasattr(id_, "upper") else id_)
            for id_ in py_attr_ids
        ]
    except KeyError as msg:
        keys = [k for k in IDS.keys() if not k.startswith("FLAG")]
        raise KeyError(Errors.E983.format(dict="IDS", key=msg, keys=keys)) from None
    cdef np.ndarray attr_ids = numpy.asarray(py_attr_ids, dtype="i")
    cdef int n_dim = len(attr_ids) + n_sup_dim
    output = numpy.ndarray(shape=(doc.length, n_dim), dtype=numpy.uint64)
    c_output = <attr_t*>output.data
    c_attr_ids = <attr_id_t*>attr_ids.data
    cdef TokenC* token
    cdef int nr_attr = attr_ids.shape[0]
    for i in range(doc.length):
        token = &doc.c[i]
        for j in range(nr_attr):
            c_output[i*n_dim + j] = get_token_attr(token, c_attr_ids[j])
    return output if n_dim >= 2 else output.reshape((doc.length,))

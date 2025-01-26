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


from distutils.core import setup
from distutils.extension import Extension
from Cython.Build import cythonize
from numpy import get_include


def make_ext():
    """Make the Cython extension."""

    return Extension(
        "solipcysme.doc_to_array",
        ["./solipcysme/doc_to_array.pyx"],
        include_dirs=[".", get_include()],
        language="c++",
    )


setup(
    name="solipcysme",
    ext_modules=cythonize(make_ext(), language_level=3),
)

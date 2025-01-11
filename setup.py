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

import hunspell
from spacy.tokens import Doc
from spacy.lookups import Table
from spacy import Language
from typing import Union


class FeatGetter:
    def __init__(self, prefix: Union[str, bytes], pretagger):
        """Init a FeatGetter from a pattern and a PreTagger"""

        if isinstance(prefix, str):
            prefix = prefix.encode()

        self.prefix = prefix
        self.table = Table()
        self.oov = pretagger.oov
        self.empty = pretagger.empty
        self.strings = pretagger.strings
        self.hs = pretagger.hs

    def __call__(self, doc: Doc) -> Doc:
        """Get hash value of features for all tokens in a Doc."""

        get_hash = self.get_hash
        return [get_hash(i.norm_) for i in doc]

    def get_hash(self, word: str) -> bytes:
        """Get the Hash value of concatenate Morphological Feature.

        Args:
            token (Token)

        Returns (int):  The hash value of the attribute values.
        """

        table = self.table
        prefix = self.prefix

        # no need to analyze same word many times.
        if word in table:
            return table[word]

        # in hyphen-based compound words, the last subword is analyzed
        if "-" in word and not word.startswith("-"):
            word = word.split("-")[-1]

        # analyze word
        a = self.hs.analyze(word)

        # out of vocabulary words
        if a is None:
            table[word] = self.oov
            return self.oov

        # empty analysis list
        if not a:
            table[word] = self.empty
            return self.empty

        # create a set for attribute values
        x = set()
        for i in a:
            for j in i.split():
                if j.startswith(prefix):
                    x.add(j)

        # concatenate sorted values into a string like "po:adjpo:nounpo:verb". That's ugly but it doesn't matter since we only want its hash value.
        a = b"".join(sorted(x)).decode()

        table[word] = self.strings[a]

        # return hash value of that string
        if a in self.strings:
            return self.strings[a]
        else:
            return self.strings.add(a)


class PreTagger:
    def __init__(
        self,
        nlp,
        name,
        dic: str,
        aff: str,
        ext_names: list[str],
        prefixes: list[str],
        add_dics: list[str] = None,
        string_empty: str = "",
        string_oov: str = "/",
    ):
        """Initiate a PreTagger.

        Args:
            nlp (Language):  The spaCy pipeline.
            dic (str):  Path to Hunspell `.dic`.
            aff (str):  Path to Hunspell `.aff`.
            ext_names (List[str]):  List of Doc extension names.
            attrs_names (List[str]):  List of prefixes for hunspell features.
            string_empty (str):  The string to use when no feature.
            string_oov (str):  The string to use for unknown words.

        Returns (Pretagger)
        """

        self.name = name
        self.strings = nlp.vocab.strings
        self.empty = self.strings.add(string_empty)
        self.oov = self.strings.add(string_oov)
        self._nlp = nlp

        self.hs = hunspell.HunSpell(dic, aff)
        if add_dics:
            for file in add_dics:
                self.add_dic(file)
        self.add_extensions(ext_names, prefixes)

    def add_extensions(self, ext_names, prefixes):
        """Add many extensions."""

        for name, s in zip(ext_names, prefixes):
            self.add_ext(name, s)

    def add_ext(self, ext_name, prefix):
        """Add an Extension."""

        Doc.set_extension(
            ext_name,
            getter=FeatGetter(prefix, self),
            force=True,
        )

    def __call__(self, doc, *args, **kwargs):
        """Do nothing."""
        return doc

    def to_disk(self, path, *, exclude=tuple(), **kwargs):
        """Do nothing."""
        pass

    def from_disk(self, path, *args, exclude=tuple(), **kwargs):
        """Do nothing."""
        pass


@Language.factory(
    "pretagger_hunspell",
    default_config={
        "name": "pretagger_hunspell",
        "add_dics": None,
        "string_empty": "",
        "string_oov": "/",
    },
)
def make_pretagger_hunspell(
    name: str,
    nlp,
    dic: str,
    aff: str,
    ext_names: list[str],
    prefixes: list[str],
    add_dics=[],
    string_oov: str = "/",
    string_empty: str = "",
):
    return PreTagger(
        nlp=nlp,
        name=name,
        dic=dic,
        aff=aff,
        ext_names=ext_names,
        prefixes=prefixes,
        add_dics=add_dics,
        string_empty=string_empty,
        string_oov=string_oov,
    )

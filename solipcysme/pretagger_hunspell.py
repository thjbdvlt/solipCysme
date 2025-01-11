import hunspell
from spacy.tokens import Doc
from spacy.lookups import Table
from spacy import Language
from spacy.util import ensure_path
import os
import shutil
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
        add_dics: list[str],
    ):
        """Initiate a PreTagger.

        Args:
            nlp (Language):  The spaCy pipeline.
            dic (str):  Path to Hunspell `.dic`.
            aff (str):  Path to Hunspell `.aff`.
            attrs (List[str]):  List of Hunspell features.
            attrs_names (List[str]):  List of Doc Extension names.

        Returns (Pretagger)
        """

        self.name = name
        self.strings = nlp.vocab.strings
        self.empty = self.strings[""]
        self.oov = self.strings.add("/")
        self._nlp = nlp

        try:
            self.hs = hunspell.HunSpell(dic, aff)
            for file in add_dics:
                self.add_dic(file)

        except hunspell.HunSpellError:
            self.hs = None

        for name, pattern in zip(ext_names, prefixes):
            Doc.set_extension(
                name,
                getter=FeatGetter(pattern, self),
                force=True,
            )

    def __call__(self, doc):
        """Do nothing."""

        return doc

    def _get_fp(self, path):
        config = self._nlp.config["components"][self.name]
        return [path / os.path.basename(config[i]) for i in ('dic', 'aff')]

    def to_disk(self, path, *, exclude=tuple(), **kwargs):
        """Save the PreTagger to disk."""

        config = self._nlp.config["components"][self.name]

        path = ensure_path(path)
        if not path.exists():
            path.mkdir()

        path_dic, path_aff = self._get_fp(path)

        try:
            shutil.copyfile(config["dic"], path_dic)
            shutil.copyfile(config["aff"], path_aff)
            if config["add_dics"]:
                with open(path_dic, "ba") as f_write:
                    for file_input in config["add_dics"]:
                        with open(file_input, "br") as f_read:
                            shutil.copyfileobj(f_read, f_write)
                            f_write.write(b"\n")
            with open(path_aff, "ba") as f_write:
                with open(config["aff"], "br") as f_read:
                    for line in f_read:
                        f_write.write(line)

        except FileNotFoundError:
            pass

    def from_disk(self, path, *args, exclude=tuple(), **kwargs):
        """Load a Pretagger from disk."""

        if not self.hs:
            path_dic, path_aff = self._get_fp(path)
            self.hs = hunspell.Hunspell(path_dic, path_aff)


@Language.factory(
    "pretagger_hunspell",
    default_config={
        "name": "pretagger_hunspell",
        "add_dics": [],
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
):
    return PreTagger(
        nlp=nlp,
        name=name,
        dic=dic,
        aff=aff,
        ext_names=ext_names,
        prefixes=prefixes,
        add_dics=add_dics,
    )

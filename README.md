solipCysme
==========

[spaCy](https://spacy.io/) [pipeline](https://spacy.io/usage/processing-pipelines) for french fictions or first person point of view texts (with a focus on personal pronouns, moods and tenses), mostly trained on novels.

| Feature | Description |
| --- | --- |
| **Language** | french |
| **Name** | `fr_solipcysme` |
| **Version** | `0.2.2` |
| **spaCy** | `==3.8.4` |
| **Default Pipeline** | `jusqucy_tokenizer`,`commecy_normalizer`, `jusqucy_normalizer`, `pretagger_hunspell`,`morphologizer`, `viceverser_lemmatizer`, `parser` |
| **Components** | [jusqucy_tokenizer](https://github.com/thjbdvlt/jusquci), [jusqucy_normalizer](https://github.com/thjbdvlt/jusquci), [commecy_normalizer](https://github.com/thjbdvlt/commecy), `morphologizer`, [viceverser_lemmatizer](https://github.com/thjbdvlt/spacy-viceverser), `parser` |
| **Vectors** | 669785 keys, 6697856 unique vectors (100 dimensions) |
| **Sources** | Corpus [narraFEATS](https://github.com/thjbdvlt/corpus-narraFEATS) (morphologizer), [Universal Dependencies](https://universaldependencies.org/fr/) (parser), [french-word-vectors](https://github.com/thjbdvlt/french-word-vectors) (vectors)|
| **License** | [GPL](https://www.gnu.org/licenses/gpl-3.0.html) |
| **Author** | [thjbdvlt](https://github.com/thjbdvlt) |

installation
------------

```bash
pip install https://github.com/thjbdvlt/solipCysme/releases/download/v.3.8.4/fr_solipcysme-2.8.4-py3-none-any.whl
```

usage
-----

```python
import spacy

nlp = spacy.load("fr_solipcysme")

doc = nlp(
    "la MACHINE à (b)rouiller le temps s'est peuuut-etre déraillée..?"
)

for i in doc:
    print(
        i.norm_,      # commecy_normalizer / jusqucy_normalizer
        i.pos_,       # morphologizer
        i.morph,      # morphologizer
        i.lemma_,     # viceverser_lemmatizer
        i.dep_,       # parser
        i.head,       # parser
        i.sent_start, # jusqucy_tokenizer
        i._.ttype,    # jusqucy_tokenizer
        i._.isword,   # jusqucy_tokenizer
    )

print(
    doc._.jusqucy_ttypes,  # jusqucy_tokenizer
    doc._.hunspell_po,     # pretagger_hunspell
    doc._.hunspell_is,     # pretagger_hunspell
)
```

components and architectures
------------

solipCysme not only is a *trained pipeline*, but also a set of minimal pipeline components and model architectures that can be used independently.

### SolipcysmeMultiHashed

a modified [MultiHashEmbed](https://spacy.io/api/architectures#MultiHashEmbed) that makes it possible to use `Doc` underscore attributes as features. The value of an attribute must be a `list` of `int`, and must have the same length as the `Doc` itself.

### SolipcysmeCharEmbed

a modified [CharacterEmbed](https://spacy.io/api/architectures#CharacterEmbed) that makes it possible to use underscore attributes as features and that replace `nC` (number of character) by `nCstart` and `nCend`, so that one can chose an asymetric representation of words (e. g., for french, to only suffix, with `nCstart = 0` and `nCend = 6`).

### pretagger_hunspell

a component that makes Hunspell morphological analysis available as *features* for the `SolipcysmeMultiHashe` or `SolipcysmeCharEmbed` architectures.

limits and specificities
------

- only knows about straigt apostroph (`'`) and quotes (`"`).
- morphologizer depends on the `jusqucy_tokenizer`, because this tokenizer sets a value to a doc extension (`Doc._.jusqucy_ttypes`), used by the morpholgizer.
- morphologizer depends on the `pretagger_hunspell` component, too; because the morphologizer uses the output of Hunspell as token features (`po:` and `is:` features).
- no `Gender` feature

license
------

this work is released under [GPL](https://www.gnu.org/licenses/gpl-3.0.html) license.

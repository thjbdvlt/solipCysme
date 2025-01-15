solipCysme
==========

[spaCy](https://spacy.io/) [pipeline](https://spacy.io/usage/processing-pipelines) for french fictions or first person point of view texts (with a focus on personal pronouns, moods and tenses), mostly trained on novels.

| Feature | Description |
| --- | --- |
| **Language** | french |
| **Name** | `fr_solipcysme` |
| **Version** | `3.8.4` |
| **spaCy** | `==3.8.4` |
| **Default Pipeline** | `jusqucy_tokenizer`,`commecy_normalizer`, `jusqucy_normalizer`, `pretagger_hunspell`,`morphologizer`, `viceverser_lemmatizer`, `parser` |
| **Components** | [jusqucy_tokenizer](https://github.com/thjbdvlt/jusquci), [jusqucy_normalizer](https://github.com/thjbdvlt/jusquci), [commecy_normalizer](https://github.com/thjbdvlt/commecy), `morphologizer`, [viceverser_lemmatizer](https://github.com/thjbdvlt/spacy-viceverser), `parser` |
| **Vectors** | 421266 keys, 421266 unique vectors (100 dimensions) |
| **Sources** | Corpus [narraFEATS](https://github.com/thjbdvlt/corpus-narraFEATS) (morphologizer), [Universal Dependencies](https://universaldependencies.org/fr/) (parser), [french-word-vectors](https://github.com/thjbdvlt/french-word-vectors) (vectors)|
| **License** | [CC BY-NC-SA 4.0](https://creativecommons.org/licenses/by-nc-sa/4.0/deed.fr) |
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

for i in nlp(
    "la MACHINE à (b)rouiller le temps s'est peuuut-etre déraillée..?"
):
    print(
        i, 
        i.norm_,  # set by commecy / jusqucy
        i.pos_,  # set by morphologizer
        i.morph,  # set by morphologizer
        i.lemma_,   # set by viceverser
        i.dep_,   # set by parser
        i._.jusqucy_ttypes,  # set by jusqucy
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

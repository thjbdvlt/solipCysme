solipCysme
==========

[spaCy](https://spacy.io/) [pipeline](https://spacy.io/usage/processing-pipelines) for french focused on personal pronouns, fictions and  first person point of view texts.

| Feature | Description |
| --- | --- |
| **Language** | french |
| **Name** | `solipCysme` |
| **Version** | `3.7.0` |
| **spaCy** | `>=3.7.6,<3.8.0` |
| **Default Pipeline** | `presque_normalizer`, `tokentype`, `morphologizer`, `viceverser_lemmatizer`, `sentencizer`, `parser` |
| **Components** | [presque_normalizer](https://github.com/thjbdvlt/spacy-presque), [tokentype](https://github.com/thjbdvlt/spacy-tokentype), `morphologizer`, [viceverser_lemmatizer](https://github.com/thjbdvlt/spacy-viceverser), `sentencizer`, `parser` |
| **Vectors** | 504297 keys, 504297 unique vectors (100 dimensions) |
| **Sources** | Corpus [narraFEATS](https://github.com/thjbdvlt/corpus-narraFEATS) (morphologizer), corpus [cabillaUD](https://github.com/thjbdvlt/corpus-cabillaUD) (parser), corpus [attirail](https://github.com/thjbdvlt/corpus-attirail) (vectors). |
| **License** | [CC BY-NC-SA 4.0](https://creativecommons.org/licenses/by-nc-sa/4.0/deed.fr) |
| **Author** | [thjbdvlt](https://github.com/thjbdvlt) |

installation
------------

```bash
pip install https://github.com/thjbdvlt/solipCysme/releases/download/solipCysme-v3.7.0/fr_solipcysme-3.7.0-py3-none-any.whl
```

usage
-----

```python
import spacy

nlp = spacy.load("fr_solipcysme")
```

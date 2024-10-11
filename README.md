solipCysme
==========

[spaCy](https://spacy.io/) [pipeline](https://spacy.io/usage/processing-pipelines) for french fictions or first person point of view texts (with a focus on personal pronouns).

| Feature | Description |
| --- | --- |
| **Language** | french |
| **Name** | `fr_solipcysme` |
| **Version** | `3.7.0` |
| **spaCy** | `>=3.7.6,<3.8.0` |
| **Default Pipeline** | `presque_normalizer`, `tokentype`, `morphologizer`, `viceverser_lemmatizer`, `sentencizer`, `parser` |
| **Components** | [quelquhui_tokenizer](https://github.com/thjbdvlt/quelquhui), [presque_normalizer](https://github.com/thjbdvlt/spacy-presque), [tokentype](https://github.com/thjbdvlt/spacy-tokentype), `morphologizer`, [viceverser_lemmatizer](https://github.com/thjbdvlt/spacy-viceverser), `sentencizer`, `parser` |
| **Vectors** | 504297 keys, 504297 unique vectors (100 dimensions) |
| **Sources** | Corpus [narraFEATS](https://github.com/thjbdvlt/corpus-narraFEATS) (morphologizer), corpus [cabillaUD](https://github.com/thjbdvlt/corpus-cabillaUD) (parser), corpus [attirail](https://github.com/thjbdvlt/corpus-attirail) (vectors). |
| **License** | [CC BY-NC-SA 4.0](https://creativecommons.org/licenses/by-nc-sa/4.0/deed.fr) |
| **Author** | [thjbdvlt](https://github.com/thjbdvlt) |

installation
------------

```bash
# from github release
pip install https://github.com/thjbdvlt/solipCysme/releases/download/solipCysme-v3.7.0/fr_solipcysme-3.7.0-py3-none-any.whl

# from huggingface
pip install https://huggingface.co/thjbdvlt/fr_solipcysme/resolve/main/fr_solipcysme-any-py3-none-any.whl
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
        i.norm_, 
        i.pos_, 
        i.morph, 
        i.lemma_, 
        i.dep_, 
        i._.tokentype,
        i._.vv_pos,
        i._.vv_morph
    )
```

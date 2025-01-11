import solipcysme.pretagger_hunspell
import spacy

fp_dic = "../spell-fr.vim/fr_ud.dic"
fp_aff = fp_dic.replace(".dic", ".aff")
prefixes = ["po:", "is:"]
ext_names = ["hunspell_po", "hunspell_is"]
nlp = spacy.load("fr_core_news_sm")
nlp.add_pipe(
    "pretagger_hunspell",
    config={
        "dic": fp_dic,
        "aff": fp_aff,
        "prefixes": prefixes,
        "ext_names": ext_names,
    },
)
nlp.to_disk("model_test/")

doc = nlp("deppuis toujours tu sont là")

doc._.hunspell_po

nlp = spacy.load("./model_test")

doc = nlp("deppuis toujours tu sont là")

len(nlp.get_pipe("pretagger_hunspell").strings)

doc._.hunspell_po

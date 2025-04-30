import spacy
from pathlib import Path
import typer


def main(
    path_model_morphologizer: Path,
    path_model_parser: Path,
    pipeline_output: Path,
) -> None:
    nlp = spacy.load(path_model_morphologizer)
    nlp_parser = spacy.load(path_model_parser)
    # Remove the `typifier`, which is only there for training.
    # For annotation, the tokenizer does this.
    nlp.remove_pipe("jusqucy_typifier")
    nlp.add_pipe("parser", source=nlp_parser, last=True)
    cfg = {
        "dic": {"@misc": "solipcysme_dic"},
        "aff": {"@misc": "solipcysme_aff"},
    }
    nlp.add_pipe("viceverser_lemmatizer", config=cfg, last=True)
    # Clean training config parameters.
    for i in ("train", "dev", "vectors", "init_tok2vec"):
        nlp.config["paths"][i] = None
    nlp.to_disk(pipeline_output)


if __name__ == "__main__":
    typer.run(main)

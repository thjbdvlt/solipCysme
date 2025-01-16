import importlib
import os
import spacy


def _get_filepath(ext):
    return os.path.join(
        importlib.resources.files("solipcysme"), f"fr_ud.{ext}"
    )


@spacy.registry.misc("solipcysme_dic")
def get_dic_filepath():
    """Get the `.dic` filepath."""
    return _get_filepath("dic")


@spacy.registry.misc("solipcysme_aff")
def get_aff_filepath():
    """Get the `.aff` filepath."""
    return _get_filepath("aff")

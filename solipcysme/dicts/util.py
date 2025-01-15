import importlib
import os


def _get_dict_files(lang: str) -> tuple[str]:
    """Get `.dic` and `.aff` files located in solipcysme module."""

    module_dir = importlib.resources.files("solipcysme")

    return {
        ext: os.path.join(module_dir, "dicts", f"{lang}.{ext}")
        for ext in ["dic", "aff"]
    }

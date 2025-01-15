import importlib
import os


def _get_dict_files(lang: str) -> tuple[str]:
    module_dir = importlib.resources.files('solipcysme')

    return {ext: os.path.join(module_dir, f"{lang}.{ext}") for ext in ('dic', 'aff')}

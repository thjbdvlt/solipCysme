# solipcysme -- spacy pipeline for french texts focused on personal pronouns and verbal moods
# Copyright (C) 2024,2025  thjbdvlt
#
# solipcysme is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published
# by the Free Software Foundation, either version 3 of the License,
# or (at your option) any later version.
#
# solipcysme is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with solipcysme.  If not, see <https://www.gnu.org/licenses/>.


import importlib
from pathlib import Path
import spacy


def _get_filepath(ext):
    directory = Path(importlib.resources.files("solipcysme"))
    filename = Path("fr_ud").with_suffix(ext)
    return str(directory / filename)


@spacy.registry.misc("solipcysme_dic")
def get_dic_filepath():
    """Get the `.dic` filepath."""
    return _get_filepath(".dic")


@spacy.registry.misc("solipcysme_aff")
def get_aff_filepath():
    """Get the `.aff` filepath."""
    return _get_filepath(".aff")

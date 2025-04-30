Scripts and data to train [solipCysme](https://github.com/thjbdvlt/solipCysme), a [spaCy](https://spacy.io/) pipeline for french.

The main scripts are [train.sh](train.sh), which train the morphologizer then the parser, and [package.sh](package.sh), which assembly the pipeline and package it.

Some scripts also fetch data from GitHub as training data (see `get_data.sh` scripts).

To train only one component (i.e. morphologizer or parser), one can use the training script (`train.sh`) in the according directory.

# Todo

- Pretraining for the dependency parser.

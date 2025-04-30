#!/bin/bash

# Package the solipCysme pipeline.
#
# The content of the directory `./pipeline` will be overwritten
# by the pipeline, and another directory, fr_solipCysme_{size}-{version},
# e.g. fr_solipCysme_sm-0.2.5, will be created.

set -e -o pipefail

# Help message.
usage="usage:  $0 -s {sm|md|lg} [OPTIONS]

required:

-s   SIZE:  Small (sm), Medium (md), Large (lg).

optional:

-o   PATH:  Output directory path (will be overwritten).
-n   NAME:  Pipeline name.
-m   META:  Path to meta.json.
"

# No default values
size=

# Default values
name=solipCysme
output=pipeline
meta=meta.json
raw=data/raw.txt

# Parse options.
while getopts s:o:hr: opt; do
    case $opt in
        s) size="$OPTARG";;
        o) output="$OPTARG";;
        n) name="$OPTARG";;
        m) meta="$OPTARG";;
        r) raw="$OPTARG";;
        h)
            echo "$usage"
            exit 0;;
        *)
            echo "Unknown flag: $opt" >&2
            exit 1;;
    esac
done

# Ensure required option are set.
: ${size:?Missing -s size}

# Get the path to the models, according to `$size`.
model_path() {
    realpath "${1}/model/${size}/model-best"
}
morph="$(model_path morphologizer)"
parser="$(model_path parser)"

# Check that the models exists. If not, train them.
[ -s "$morph" ] && [ -s "$parser" ] || {
    echo "Missing components. Training..."
    ./train.sh -s "$size" -r "$raw"
}

# Build the full pipeline with right components and configuration.
python3 ./util/make_pipeline.py "$morph" "$parser" "$output"

# Get the version tag from file, and make the complete name.
version="$(head -n 1 VERSION)"
name="${name}_${size}"

# Package the pipeline.
spacy package "$output" . --build wheel \
    --name "$name" --version "$version" --meta "$meta"

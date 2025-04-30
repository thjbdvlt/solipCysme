#!/bin/bash

# Train the full solipCysme pipeline.
#
# Trainable components (morphologizer + parser) are trained using
# all other components outputs (normalizers, lemmatizer, ...).
# Thus, the pipeline should be re-trained whenever these components
# get updated.

set -e -o pipefail

# Help message.
usage="usage:  $0 -s {sm|md|lg} -r RAW [OPTIONS]

required:

-s   SIZE: Small (sm), Medium (md), Large (lg).
-r   FILE: File with raw text for pretraining.
"

# Unset all variables.
size=
raw=
vectors=vectors
labels=labels

# Parse options.
while getopts s:r:h opt; do
    case $opt in
        s) size="$OPTARG";;
        r) raw="$OPTARG";;
        m) morph="$OPTARG";;
        h)
            echo "$usage"
            exit 0;;
        *)
            echo "Unknown flag: $opt" >&2
            exit 1;;
    esac
done

ensure_exists() {
    test -s "$1" || {
        echo "File not found: $i" >&2
        exit 1
    }
}

# Ensure all required variables are set.
: ${size:?Missing -s size}
: ${raw:?Missing -r raw}
ensure_exists "$raw"
ensure_exists "$labels"

# Get full path, as the training requires to change directory.
opts=(
    -s  "$size"
    -r  "$(realpath "$raw")"
    -l  "$(realpath "$labels")"
)

# Ensure vectors are here if needed.
case $size in
    sm);;
    md | lg) ./get_vectors.sh -s $size;;
    *)
        echo "Unknown value for size: $size" >&2
        echo "Possible values are: sm, md, lg. " >&2
        exit 1;;
esac

# Train the trainable components.
for i in morphologizer parser
do
    cd $i
    ./train.sh "${opts[@]}"
    cd -
done

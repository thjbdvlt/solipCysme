#!/bin/bash

# Train the full solipCysme pipeline.
#
# Trainable components (morphologizer + parser) are trained using
# all other components outputs (normalizers, lemmatizer, ...).
# Thus, the pipeline should be re-trained whenever these components
# are updated.

set -e -o pipefail

# Help message.
usage="usage:  $0 {sm|md|lg}"
[ "$1" == '-h' ] && {
    echo "$usage"
    exit 0
}
[ "$1" ] || {
    echo "Missing argument: SIZE." >&2
    echo "$usage"
    exit 1
}

size="$1"

# Constant paths
raw=./data/raw.txt
labels=./labels

# Only one argument: model size.
size="$1"
case "$size" in
    sm);;
    md | lg) ./get_vectors.sh $size;;
    *)
        echo "$usage"
        echo "Unknown value for size: $size" >&2
        echo "Possible values are: sm, md, lg. " >&2
        exit 1;;
esac

# Ensure raw data is there
[ -f "$raw" ] || ./get_raw_data.sh

# Train the trainable components.
for i in morphologizer parser
do
    cd $i
    ./train.sh "$size"
    cd -
done

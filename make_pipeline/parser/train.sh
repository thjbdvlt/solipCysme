#!/bin/bash

# Train the parser model.
# If necessary, automatically generate the labels,
# and pretrain the model.
# See `-h` option for command line options.

set -e -o pipefail

# Command line options
size=

# Files and directory
train="train.spacy"
dev=dev.spacy
cfg=config.cfg
output=./model
raw=../data/raw.txt
labels=../labels

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

# Only one argument is needed: size.
size="$1"

# Ensure that 'train', 'dev', 'raw' data are files,
for i in "$train" "$dev" "$raw"
do
    test -s "$i" || {
        echo "Not a file: $i" >&2
        exit 1
    }
done

# Morphologizer is best model with same size.
# (It needs to be the same static vectors.)
# As the size needs to be known, it cannot be defined at the top.
morph="../morphologizer/model/${size}/model-best"

# Configuration values depend on `-s SIZE`
case "$size" in
    sm | md)
        width=128
        depth=3
        rows=[2000,500,1000,2000]
        static=false;;
    lg)
        width=128
        depth=4
        rows=[4000,2000,4000,2000]
        static=true;;
    *)
        echo "Unknown value for -s: $size" >&2
        echo "Possible values are: sm, md, lg." >&2
        exit 1;;
esac

# Init command line options
opts=()

# Medium/Large models require word vectors,
# while Small requires vectors to be set to 'null'.
if [ "$size" == md ] || [ "$size" == lg ]
then
    path_vec="../vectors/${size}"
else
    path_vec=null
fi
opts+=(--paths.vectors "$path_vec")

# Make command line options
component=parser
tok2vec=components.${component}.model.tok2vec
embed=${tok2vec}.embed
encode=${tok2vec}.encode
pretrain_d=pretrain/${size}
pretrain_model=pretrain/${size}/model-last.bin
labels_json="${labels}/${component}.json"
opts+=(
    --${encode}.width=${width}
    --${encode}.depth=${depth}
    --${embed}.rows=${rows}
    --${embed}.include_static_vectors=${static}
    --paths.dev=${dev}
    --paths.train=${train}
    --components.morphologizer.source=${morph}
)

# Get the data if its missing.
[ -s "$train" ] && [ -s "$dev" ] || ./get_data.sh

# Labels
mkdir -p "$labels"
test -s "$labels_json" || {
    spacy init labels ${cfg} "$labels"
}

# Training
mkdir -p "${output}"
spacy train "${cfg}" --output "${output}/${size}" "${opts[@]}"

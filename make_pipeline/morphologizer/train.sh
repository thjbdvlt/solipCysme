#!/bin/bash

# Train the morphologizer model.
# If necessary, automatically generate the labels,
# and pretrain the model.
# See `-h` option for command line options.

set -e -o pipefail

# Command line options
size=

# Files and directory
train="./narrafeats/train.spacy"
dev=./narrafeats/dev.spacy
cfg=config.cfg
output=./model
labels=../labels
raw=../data/raw.txt

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

# Configuration values depend on `-s SIZE`
case "$size" in
    sm | md)
        width=128
        depth=3
        rows=[2000,500,1000,2000]
        static=false;;
    lg)
        width=256
        depth=4
        rows=[4000,1000,2000,4000]
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
# Thus, Small models are pretraing with another architecture.
obj=pretraining.objective
case "$size" in
    md | lg)
        opts+=(
            --paths.vectors ../vectors/${size}
            --${obj}.@architectures spacy.PretrainVectors.v1
            --${obj}.maxout_pieces 3
            --${obj}.hidden_size 300
            --${obj}.loss cosine
        );;
    sm) 
        opts+=(
            --paths.vectors null
            --${obj}.@architectures spacy.PretrainCharacters.v1
            --${obj}.maxout_pieces 3
            --${obj}.hidden_size 300
            --${obj}.n_characters 4
        );;
esac

# Make command line options
component=morphologizer
tok2vec=components.${component}.model.tok2vec
embed=${tok2vec}.embed
encode=${tok2vec}.encode
pretrain_d=pretrain/${size}
pretrain_model=pretrain/${size}/model-last.bin
labels_json="${labels}/${component}.json"
opts+=(
    --paths.init_tok2vec=${pretrain_model}
    --${encode}.width=${width}
    --${encode}.depth=${depth}
    --${embed}.rows=${rows}
    --${embed}.include_static_vectors=${static}
    --paths.dev=${dev}
    --paths.train=${train}
)

# Get the data if its missing.
test -s "$train" && test -s "$dev" || ./get_data.sh 

# Labels
mkdir -p "$labels"
test -s "$labels_json" || {
    spacy init labels ${cfg} "$labels"
}

# Pretraining, but not for small models.
mkdir -p "$pretrain_d"
test -s "$pretrain_model" || {
    spacy pretrain "$cfg" "$pretrain_d" "${opts[@]}"
}

# Training
mkdir -p "${output}"
spacy train "${cfg}" --output "${output}/${size}" "${opts[@]}"

#!/bin/bash

# Train the morphologizer model.
# If necessary, automatically generate the labels,
# and pretrain the model.
# See `-h` option for command line options.

set -e -o pipefail

# Command line options
size=
raw=
labels=

# Files and directory
train="./narrafeats/train.spacy"
dev=./narrafeats/dev.spacy
cfg=config.cfg
output=./model

# Help
usage="usage:

$0 -s SIZE -r RAW

e.g.: -r raw.txt
"

# Parse options
while getopts s:l:v:r:h opt; do
    case $opt in
        s) size="$OPTARG";;
        l) labels="$OPTARG";;
        r) raw="$OPTARG";;
        h)
            echo "$usage"
            exit 0;;
        *)
            echo "Unknown flag: $opt" >&2
            exit 1;;
    esac
done

# Ensure all required variables are set
: ${size:?Missing -s size}
: ${raw:?Missing -r raw}
: ${train:?Missing -t train}
: ${dev:?Missing -d dev}
: ${labels:?Missing -l labels}

# Ensure that 'train', 'dev', 'raw' data are files,
for i in "$train" "$dev" "$raw"
do
    test -s "$i" || {
        echo "Not a file: $i" >&2
        exit 1
    }
done

# Ensure that 'labels' is a directory.
test -d "$labels" || {
    echo "Not a directory: $labels" >&2
    exit 1
}

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
if [ "$size" == md ] || [ "$size" == lg ]
then
    path_vec="../vectors/${size}"
else
    path_vec=null
fi
opts+=(--paths.vectors "$path_vec")

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
    --corpora.pretrain.path=${raw}
)

# Get the data if its missing.
test -s "$train" && test -s "$dev" || ./get_data.sh 

# Labels
test -s "$labels_json" || {
    spacy init labels ${cfg} "$labels"
}

# Pretraining
mkdir -p "$pretrain_d"
test -s "$pretrain_model" || {
    spacy pretrain "$cfg" "$pretrain_d" "${opts[@]}"
}

# Training
mkdir -p "${output}"
spacy train "${cfg}" --output "${output}/${size}" "${opts[@]}"

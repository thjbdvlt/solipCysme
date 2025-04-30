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

optional:

-v   DIR:  Path to Word2Vec word vectors (text format).
-b         Word2Vec are in binary format.
"

# Unset all variables.
size=
raw=
word2vec=
vectors=vectors
labels=labels
word2vec_binary=

# Parse options.
while getopts s:v:r:hb opt; do
    case $opt in
        s) size="$OPTARG";;
        b) word2vec_binary=true;;
        v) word2vec="$OPTARG";;
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

init_vectors() {
    local src="$1"
    local src_txt="data/vec.txt"
    local dest="$2"

    # Check argument
    [ "$1" ] || {
        echo "Missing argument in function 'init_vectors'." >&2
        exit 1
    }
    ensure_exists "$1"

    # If binary format: convert it to text format first.
    [ "$word2vec_binary" ] && {
        python3 ./util/vec_bin_to_txt.py "$src" "$src_txt"
        src="$src_txt"
    }

    # Convert to spaCy format.
    spacy init vectors fr "$src" "$vectors" --verbose \
        --attr NORM --name solipcysme.vectors 
}


# Medium/Large models require word vectors,
# while Small requires vectors to be set to 'null'.
if [ "$size" == md ] || [ "$size" == lg ]
then
    [ -s "$vectors" ] || {
        [ "$word2vec" ] || {
            echo "No vectors found." >&2
            echo "Submit source with '-v' option." >&2
            exit 1
        }
        init_vectors "$word2vec" "${vectors}/${size}"
    }
    opts+=(-v "$(realpath $vectors)")
fi

# # Vectors are optional.
# if [ "$vectors" ]
# then
#     test -s 
#     opts+=( -v "$(realpath "$vectors")" )
# fi

# Train the trainable components.
for i in morphologizer parser
do
    cd $i
    ./train.sh "${opts[@]}"
    cd -
done

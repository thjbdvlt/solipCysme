#!/bin/bash

# Get vectors (word2vec) and convert to spaCy format.

set -e -o pipefail

# Help message.
usage="usage:  $0 -s {sm|md|lg}

required:

-s   SIZE: Small (sm), Medium (md), Large (lg).
"

# No default value
size=

# Parse options.
while getopts s:h opt; do
    case $opt in
        s) size="$OPTARG";;
        h)
            echo "$usage"
            exit 0;;
        *)
            echo "Unknown flag: $opt" >&2
            exit 1;;
    esac
done

# Ensure a size is passed as argument.
[ $size ] || {
    echo "Missing argument (-s SIZE)." >&2
    exit 1
}

# Check value of $size
case $size in
    sm) exit 0;; # Small models don't use vectors
    md | lg);;
    *)
        echo "Unknown value for size: $size" >&2
        echo "Possible values are: sm, md, lg. " >&2
        exit 1;;
esac

# Files
bin=vectors/vectors.bin
txt=vectors/vectors.txt

# If vectors are already there, exit script.
[ -s vectors/${size}/vocab/vectors ] && exit 0

# Convert from text word2vec to spaCy format.
convert_vectors() {
    spacy init vectors fr vectors/vectors.txt "vectors/${size}" --verbose \
        --attr NORM --name solipcysme.vectors 
}

# If vectors exists in text format, convert to spaCy format.
[ -s vectors/vectors.txt ] && {
    convert_vectors
    exit 0
}

bin_to_spacy() {
    python3 ./util/vec_bin_to_txt.py $bin $txt
    convert_vectors
    exit 0
}

# If vectors exists as binary format, convert to text then spaCy.
[ -s vectors/vectors.bin ] && {
    bin_to_spacy
    exit 0
}

# If the script reach that point, download the vectors.
wget https://github.com/thjbdvlt/french-word-vectors/releases/download/v0.3.1/vectors.bin -P

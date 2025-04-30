#!/bin/bash

# Get data from Universal Dependency in CONLL-U format.
# Then transform it into spaCy format (DocBin).

set -e -o pipefail

# Create a directory to store training data.
mkdir -p data

# I only produce two files: train and dev.
train_spacy=train.spacy
dev_spacy=dev.spacy

# From two concatenated CONLL-U files.
train=data/train.conllu
dev=data/dev.conllu

to_docbin() {
    for i in $dev $train
    do
        spacy convert $i . -n 10
    done
}


# If DocBin files already exists, do nothing.
[ -s "$train_spacy" ] && [ -s "$dev_spacy" ] && {
    exit 0
}

# If the concatenated CONLL-U files exists, convert them and exit.
[ -s "$train_spacy" ] && [ -s "$dev_spacy" ] && {
    to_docbin
    exit 0
}

# Data are taken from the Universal Dependencies GitHub repositories.
ud=https://raw.githubusercontent.com/UniversalDependencies/UD_French-
suff=/refs/heads/master/fr_

# Three datasets are used:
# - https://github.com/UniversalDependencies/UD_French-Sequoia
# - https://github.com/UniversalDependencies/UD_French-Rhapsodie
# - https://github.com/UniversalDependencies/UD_French-ParisStories
urls=()
for repo in Sequoia Rhapsodie ParisStories
do
    repo_lower="$(echo "$repo" | tr '[:upper:]' '[:lower:]')"
    url="${ud}${repo}${suff}"
    # For each dataset, get 'train', 'dev' and 'test' files.
    for split in train dev test
    do
        urls+=("${url}${repo_lower}-ud-${split}.conllu")
    done
done

# Download every missing files.
for i in "${urls[@]}"
do
    [ -s "data/$(basename "$i")" ] || {
        wget "$i" -P data
    }
done

# Reinitiate the files
echo > $train
echo > $dev

# Concatenate all files with an empty line between each of them.
for i in data/*-dev.conllu
do
    cat $i >> $dev
    echo >> $dev
done
for i in data/*-train.conllu data/*-test.conllu
do
    cat $i >> $train
    echo >> $dev
done

# Convert to spaCy format (DocBin).
to_docbin

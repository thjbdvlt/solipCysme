#!/bin/bash

# Get unannotated raw data to pretrain.
#
# This script fetch data from the corpus "Corpus Chapitres : 2000 romans français du 19e et 20e siècles libres de droit en xml-tei", which can be found online, and extract data from it.
#
# Sources:
# - https://www.thalim.cnrs.fr/ressources-numeriques/article/corpus- chapitres-2000-romans-francais-du-19e-et-20e-siecles-libres-de- droit-en
# - https://github.com/ANRChapitres/2000romans19e20e

set -e -o pipefail

# source
url=https://github.com/ANRChapitres/2000romans19e20e/archive/refs/tags/v1.0.0.tar.gz

fp=data/v1.0.0
tar=${fp}.tar
zip=${tar}.gz
dir=data/2000romans19e20e-1.0.0
raw=data/raw.txt

# Number of paragraphs to extract
n_par=100000


# Get and extract data
[ -s "$raw" ] || {
    [ -d "$dir" ] || {
        [ -s "$tar" ] || {
            [ -s "$zip" ] || {
                wget "$url" -P data/
            }
            gunzip "$zip"
        }
        tar xvf "$tar" -C data
    }
    python3 util/extract_paragraph_xml.py \
        "$dir" "$raw" --max "$n_par"
}

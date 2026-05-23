#!/bin/bash

# Get data from corpus-narraFEATS.

set -e -o pipefail

# If the data are already there, do nothing.
test -s narrafeats/train.spacy \
    && test -s narrafeats/dev.spacy \
    && exit 0

# Set some shortcut variables.
d=narrafeats
tar=$d.tar
gz=$tar.gz

# Function to download, unzip, untar, and convert data.
convert() {
    cd $d
    make all
}
untar() {
    tar xvf $tar
    convert
}
unzip() {
    gunzip $gz
    untar
}
download() {
    # wget https://github.com/thjbdvlt/corpus-narraFEATS/releases/download/$version/narrafeats.tar.gz
    wget https://github.com/thjbdvlt/corpus-narraFEATS/releases/latest/download/narrafeats.tar.gz
    # FIXME: this file doesn't exists. must clone the repository instead.
    unzip
}

# Check which data is already there, and only get what's necessary.
# If the directory exists, convert from CONLL-U to DocBin.
if test -d $d
then convert
# If not, but the archive is there, just unarchive then convert.
elif test -s $tar
then untar
# If not, but the zip is there, unzip then unarchive, then...
elif test -s $gz
then unzip
# If not is there, download, there...
elif ! test -e $d
then download
# If something is not OK, remove everything and download, then...
else
    rm -f $d $tar $gz
    exit 1
fi

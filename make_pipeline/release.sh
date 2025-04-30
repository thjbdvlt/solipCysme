#!/bin/bash

# Release the pipeline.

# Get the current version.
version="$(head -n 1 VERSION)"

# Create an array for files that will be released.
files=()

# Check that there is two directories, for `lg` and `sm` models.
# If some is missing, package it.
for size in sm lg
do
    fp=fr_solipCysme_${size}-${version}/dist/fr_solipcysme_${size}-${version}-py3-none-any.whl
    test -s $fp || ./package.sh -s $size
    files+=($fp)
done

# Get the spaCy version.
spacy_version="$(pip list | grep -P '^spacy\s' | grep -Po '[.\d]+$')"

# Upload the release.
gh release create "$version" "${files[@]}" \
    --notes "solipCysme version ${version} (spaCy $spacy_version)."

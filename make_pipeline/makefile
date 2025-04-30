src_vectors   := 

# Model and Pipeline Outputs
vec_txt       := data/vec.txt

.PHONY: package all clean pipeline train vectors release

all: train package

# Train trainable components
train_opts := -r ./data/raw.txt -l ./labels
train:
	./train.sh -s sm $(train_opts)
	./train.sh -s lg $(train_opts) -v ./vectors 

# Package the Pipeline
package:
	./package.sh -s sm
	./package.sh -s lg

release: package
	./release.sh

# Vectors from Word2Vec to spaCy format.
# TODO: sizes!
$(vec_txt): scripts/vec_bin_to_txt.py $(src_vectors)
	python3  $^ $@
vectors: $(vec_txt)
	spacy init vectors fr $< $@ --verbose \
		--attr NORM --name solipcysme.vectors 

clean:
	rm -rf ./fr_solipcysme* ./fr_solipCysme* ./pipeline

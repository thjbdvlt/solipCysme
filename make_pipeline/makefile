.PHONY: all package clean train release

all: package

train:
	./train.sh -s sm -r ./data/raw.txt
	./train.sh -s lg -r ./data/raw.txt

package:
	./package.sh -s sm
	./package.sh -s lg

release:
	./release.sh

clean:
	rm -rf ./fr_solipcysme* ./fr_solipCysme* ./pipeline \
		./data/2000romans19e20e-1.0.0 ./data/v1.0.0*

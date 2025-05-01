.PHONY: all package clean train release

all: package

train:
	./train.sh sm
	./train.sh lg

package:
	./package.sh -s sm
	./package.sh -s lg

release:
	./release.sh

clean:
	rm -rf ./fr_solipcysme* ./fr_solipCysme* ./pipeline \
		./data/2000romans19e20e-1.0.0 ./data/v1.0.0* \
		./parser/pretrain ./morphologizer/pretrain

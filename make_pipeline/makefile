.PHONY: all package clean train release sm lg

all: package

sm lg:
	./train.sh $@
	./package.sh -s $@

train package:
	./$@.sh -s sm
	./$@.sh -s lg

release:
	./$@.sh

clean:
	rm -rf ./fr_solipcysme* ./fr_solipCysme* ./pipeline \
		./data/2000romans19e20e-1.0.0 ./data/v1.0.0* \

clean_all:
	make clean
	rm -rf ./parser/pretrain ./morphologizer/pretrain

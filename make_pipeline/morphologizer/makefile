.PHONY: all train test clean

opts := -r ../data/raw.txt -v ../vectors

all: clean
	./train.sh sm $(opts)
	./train.sh lg $(opts)

train: clean
	read -p 'size?' size \
		&& ./train.sh $(opts) $${size}

test:
	read -p 'size?' size \
		&& python3 test.py model/$${size}/model-best | less

clean:
	rm -rf __pycache__

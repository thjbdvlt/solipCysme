.PHONY: all train test clean

opts := -r ../data/raw.txt -v ../vectors

all: clean
	train.sh -s sm $(opts)
	train.sh -s lg $(opts)

train: clean
	read -p 'size?' size \
		&& train.sh $(opts) -s $${size}

test:
	read -p 'size?' size \
		&& python3 test.py model/$${size}/model-best | less

clean:
	rm -rf __pycache__

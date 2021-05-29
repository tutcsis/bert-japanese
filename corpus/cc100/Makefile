# -*- Makefile -*-

PYTHON = python3

preprocess: corpus_sampled.txt corpus_01.txt

corpus_sampled.txt: ja.txt
	grep -v '^$$' $^ | shuf -n 1000000 -o $@

corpus_01.txt: ja.txt
	$(PYTHON) ../../merge_split_corpora.py --input_files $^ --output_dir ./ --num_files 32

ja.txt: ja.txt.xz
	xz --decompress --keep $^

ja.txt.xz:
	wget http://data.statmt.org/cc-100/ja.txt.xz -o download.log

.INTERMEDIATE: ja.txt

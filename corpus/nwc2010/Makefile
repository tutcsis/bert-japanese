# -*- Makefile -*-

PYTHON = python3
XZFILES = $(shell cut -f6 -d/ filelist)

preprocess: corpus_sampled.txt corpus_01.txt

corpus_sampled.txt: corpus.txt
	grep -v '^$$' $^ | shuf | head -n 1000000 > $@

corpus_01.txt: corpus.txt
	$(PYTHON) ../../merge_split_corpora.py --input_files $^ --output_dir ./ --num_files 8

corpus.txt: $(patsubst %.xz,%.dat,$(XZFILES))
	cat $^ > $@

%.dat: %.xz
	$(PYTHON) sampling.py $^ --output $@

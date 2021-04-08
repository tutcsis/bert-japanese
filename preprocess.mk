# -*- Makefile -*-

PYTHON = python3
WIKIBASEDATE ?= 20161001
WIKIBASENAME ?= jawiki-$(WIKIBASEDATE)
FULLPAGEURL = https://dumps.wikimedia.org/jawiki/$(WIKIBASEDATE)/$(WIKIBASENAME)-pages-articles.xml.bz2
FULLPAGEFILE = $(notdir $(FULLPAGEURL))

preprocess: corpus_sampled.txt corpus_01.txt

corpus_sampled.txt: corpus.txt
	grep -v '^$$' $^ | shuf | head -n 1000000 > $@

corpus_01.txt: corpus.txt
	$(PYTHON) ../../merge_split_corpora.py --input_files $^ --output_dir ./ --num_files 8

corpus.txt: jawiki.xml
	$(PYTHON) ../../convert_corpus_wiki.py -i $^ -o $@

jawiki.xml: $(FULLPAGEFILE) ../../WikiExtractor.py
	$(PYTHON) ../../WikiExtractor.py -b 100M -o $(WIKIBASENAME)-extracted --jp_split_sentences $(FULLPAGEFILE)
	find $(WIKIBASENAME)-extracted -type f -name 'wiki_*' | sort | xargs cat > $@

../../WikiExtractor.py:
	cd ../.. && wget https://raw.githubusercontent.com/tutcsis/wikiextractor/master/WikiExtractor.py

$(FULLPAGEFILE):
	wget $(FULLPAGEURL)

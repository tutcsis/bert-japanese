# -*- Makefile -*-

WIKIBASEDATE ?= 20161001
WIKIBASENAME ?= jawiki-$(WIKIBASEDATE)
BASEDIR      = ../..
TOKENIZERDIR = $(BASEDIR)/tokenizers/$(WIKIBASENAME)/wordpiece_unidic_lite
PRETRAINDIR  = $(BASEDIR)/bert/$(WIKIBASENAME)/wordpiece_unidic_lite/bert-base/pretrained

all: config.json model.ckpt.data-00000-of-00001 model.ckpt.index vocab.index

config.json: $(BASEDIR)/model_configs/bert-base-v2/wordpiece/config.json
	cp -p $^ $@

model.ckpt.data-00000-of-00001: $(PRETRAINDIR)/bert_model.ckpt-101.data-00000-of-00001
	cp -p $^ $@

model.ckpt.index: $(PRETRAINDIR)/bert_model.ckpt-101.index
	cp -p $^ $@

vocab.index: $(TOKENIZERDIR)/vocab.txt
	cp -p $^ $@

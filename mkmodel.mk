# -*- Makefile -*-

WIKIBASEDATE ?= 20161001
WIKIBASENAME ?= jawiki-$(WIKIBASEDATE)
BASEDIR      = ../..
TOKENIZERDIR = $(BASEDIR)/tokenizers/$(WIKIBASENAME)/wordpiece_unidic_lite
PRETRAINDIR  = $(BASEDIR)/bert/$(WIKIBASENAME)/wordpiece_unidic_lite/bert-base/pretrained

all: config.json model.ckpt.data-00000-of-00001 model.ckpt.index vocab.index pytorch_model.bin

config.json: $(BASEDIR)/model_configs/bert-base-v2/wordpiece/config.json
	cp -p $^ $@

model.ckpt.data-00000-of-00001: $(PRETRAINDIR)/bert_model.ckpt-101.data-00000-of-00001
	cp -p $^ $@

model.ckpt.index: $(PRETRAINDIR)/bert_model.ckpt-101.index
	cp -p $^ $@

vocab.index: $(TOKENIZERDIR)/vocab.txt
	cp -p $^ $@

# https://huggingface.co/transformers/converting_tensorflow_models.html
pytorch_model.bin: config.json model.ckpt.index model.ckpt.data-00000-of-00001
	. $(BASEDIR)/venv/bin/activate && \
	python3 $(BASEDIR)/convert_original_tf2_checkpoint_to_pytorch.py \
		--tf_checkpoint_path model.ckpt \
		--config_file config.json \
		--pytorch_dump_path $@

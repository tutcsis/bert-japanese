# -*- Makefile -*-

WIKIBASEDATE ?= 20161001
WIKIBASENAME ?= jawiki-$(WIKIBASEDATE)
BASEDIR      = ../..
TOKENIZERDIR = $(BASEDIR)/tokenizers/$(WIKIBASENAME)/wordpiece_unidic_lite
PRETRAINDIR  = $(BASEDIR)/bert/$(WIKIBASENAME)/wordpiece_unidic_lite/bert-base/pretrained

all: config.json tokenizer_config.json model.ckpt.data-00000-of-00001 model.ckpt.index vocab.txt pytorch_model.bin

config.json: $(BASEDIR)/model_configs/bert-base-v2/wordpiece/config.json
	cp -p $^ $@

tokenizer_config.json: $(BASEDIR)/model_configs/tokenizer_config.json
	cp -p $^ $@

model.ckpt.data-00000-of-00001: $(PRETRAINDIR)/bert_model.ckpt-101.data-00000-of-00001
	cp -p $^ $@

model.ckpt.index: $(PRETRAINDIR)/bert_model.ckpt-101.index
	cp -p $^ $@

vocab.txt: $(TOKENIZERDIR)/vocab.txt
	cp -p $^ $@

# https://huggingface.co/transformers/converting_tensorflow_models.html
pytorch_model.bin: config.json $(PRETRAINDIR)/bert_model.ckpt-101.index
	. $(BASEDIR)/venv/bin/activate && \
	python3 $(BASEDIR)/convert_bert_original_tf2_checkpoint_to_pytorch.py \
		--tf_checkpoint_path $(PRETRAINDIR) \
		--bert_config_file config.json \
		--pytorch_dump_path $@

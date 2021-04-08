# Pretrained Japanese BERT models

This is a repository of derived versions of pretrained Japanese BERT models provided by Tohoku-University.
Because documents and scripts are modified for our research, see [the repository of Tohoku-University](https://github.com/cl-tohoku/bert-japanese) if you need the original version.

## Model Architecture

The architecture of our models are the same as the original BERT models proposed by Google.
- **BERT-base** models consist of 12 layers, 768 dimensions of hidden states, and 12 attention heads.
- **BERT-large** models consist of 24 layers, 1024 dimensions of hidden states, and 16 attention heads.

## Environment

The scripts to train Japanese BERT models depends on the specific versions of `tokenizers` and `transformers`.
The following command is necessary to prepare the environment.

```sh
$ python3 -m venv venv
$ source venv/bin/activate
$ ( cd venv && git clone https://github.com/tensorflow/models )
$ ( cd venv/models && git checkout remotes/origin/r2.3.0 )
$ pip3 install -r requirements.txt
$ pip3 install -r venv/models/official/requirements.txt
```

## Training Data

The training corpus is generated from the Wikipedia dump file.

```sh
$ make -C corpus/jawiki-20161001
$ make -C corpus/jawiki-20181001
```

The Following command shows the increasing size of Japanese Wikipedia.

```sh
$ wc corpus/jawiki-20161001/corpus.txt corpus/jawiki-20181001/corpus.txt corpus/jawiki-20210329/corpus.txt 
  16833992   18163840 2279315211 corpus/jawiki-20161001/corpus.txt
  18830749   20326833 2557947453 corpus/jawiki-20181001/corpus.txt
  32234571   57769778 4429197361 corpus/jawiki-20210329/corpus.txt
```

## Tokenization

For each of BERT-base and BERT-large, we provide two models with different tokenization methods.

- For **`wordpiece`** models, the texts are first tokenized by MeCab with the Unidic 2.1.2 dictionary and then split into subwords by the WordPiece algorithm.
  The vocabulary size is 32768.
- For **`character`** models, the texts are first tokenized by MeCab with the Unidic 2.1.2 dictionary and then split into characters.
  The vocabulary size is 6144.

We used [`fugashi`](https://github.com/polm/fugashi) and [`unidic-lite`](https://github.com/polm/unidic-lite) packages for the tokenization.

```sh
$ ./train_tokenizer.sh 20161001
$ ./train_tokenizer.sh 20181001
```

## Training

The models are trained with the same configuration as the original BERT; 512 tokens per instance, 256 instances per batch, and 1M training steps.
For training of the MLM (masked language modeling) objective, we introduced **whole word masking** in which all of the subword tokens corresponding to a single word (tokenized by MeCab) are masked at once.

### Creation of the pretraining data

The following scripts submits jobs to create the pretraining data.  Each job takes roughly 1 hour.

```sh
$ ./create_pretraining_data.sh 20161001
$ ./create_pretraining_data.sh 20181001
```

### Training of the models

The following scripts submits jobs to train BERT-base, wordpiece models.

```sh
$ ./pretraining.sh 20161001
$ ./pretraining.sh 20181001
```

***Following documents are not updated***.

```sh
# BERT-base, WordPiece (unidic_lite)
$ ctpu up -name tpu01 -tpu-size v3-8 -tf-version 2.3
$ cd /usr/share/models
$ sudo pip3 install -r official/requirements.txt
$ tmux
$ export PYTHONPATH="$PYTHONPATH:/usr/share/tpu/models"
$ WORK_DIR="gs://<your GCS bucket name>/bert-japanese"
$ python3 official/nlp/bert/run_pretraining.py \
--input_files="$WORK_DIR/bert/jawiki-20200831/wordpiece_unidic_lite/pretraining_data/pretraining_data_*.tfrecord" \
--model_dir="$WORK_DIR/bert/jawiki-20200831/wordpiece_unidic_lite/bert-base" \
--bert_config_file="$WORK_DIR/bert/jawiki-20200831/wordpiece_unidic_lite/bert-base/config.json" \
--max_seq_length=512 \
--max_predictions_per_seq=80 \
--train_batch_size=256 \
--learning_rate=1e-4 \
--num_train_epochs=100 \
--num_steps_per_epoch=10000 \
--optimizer_type=adamw \
--warmup_steps=10000 \
--distribution_strategy=tpu \
--tpu=tpu01

# BERT-base, Character
$ ctpu up -name tpu02 -tpu-size v3-8 -tf-version 2.3
$ cd /usr/share/models
$ sudo pip3 install -r official/requirements.txt
$ tmux
$ export PYTHONPATH="$PYTHONPATH:/usr/share/tpu/models"
$ WORK_DIR="gs://<your GCS bucket name>/bert-japanese"
$ python3 official/nlp/bert/run_pretraining.py \
--input_files="$WORK_DIR/bert/jawiki-20200831/character/pretraining_data/pretraining_data_*.tfrecord" \
--model_dir="$WORK_DIR/bert/jawiki-20200831/character/bert-base" \
--bert_config_file="$WORK_DIR/bert/jawiki-20200831/character/bert-base/config.json" \
--max_seq_length=512 \
--max_predictions_per_seq=80 \
--train_batch_size=256 \
--learning_rate=1e-4 \
--num_train_epochs=100 \
--num_steps_per_epoch=10000 \
--optimizer_type=adamw \
--warmup_steps=10000 \
--distribution_strategy=tpu \
--tpu=tpu02

# BERT-large, WordPiece (unidic_lite)
$ ctpu up -name tpu03 -tpu-size v3-8 -tf-version 2.3
$ cd /usr/share/models
$ sudo pip3 install -r official/requirements.txt
$ tmux
$ export PYTHONPATH="$PYTHONPATH:/usr/share/tpu/models"
$ WORK_DIR="gs://<your GCS bucket name>/bert-japanese"
$ python3 official/nlp/bert/run_pretraining.py \
--input_files="$WORK_DIR/bert/jawiki-20200831/wordpiece_unidic_lite/pretraining_data/pretraining_data_*.tfrecord" \
--model_dir="$WORK_DIR/bert/jawiki-20200831/wordpiece_unidic_lite/bert-large" \
--bert_config_file="$WORK_DIR/bert/jawiki-20200831/wordpiece_unidic_lite/bert-large/config.json" \
--max_seq_length=512 \
--max_predictions_per_seq=80 \
--train_batch_size=256 \
--learning_rate=5e-5 \
--num_train_epochs=100 \
--num_steps_per_epoch=10000 \
--optimizer_type=adamw \
--warmup_steps=10000 \
--distribution_strategy=tpu \
--tpu=tpu03

# BERT-large, Character
$ ctpu up -name tpu04 -tpu-size v3-8 -tf-version 2.3
$ cd /usr/share/models
$ sudo pip3 install -r official/requirements.txt
$ tmux
$ export PYTHONPATH="$PYTHONPATH:/usr/share/tpu/models"
$ WORK_DIR="gs://<your GCS bucket name>/bert-japanese"
$ python3 official/nlp/bert/run_pretraining.py \
--input_files="$WORK_DIR/bert/jawiki-20200831/character/pretraining_data/pretraining_data_*.tfrecord" \
--model_dir="$WORK_DIR/bert/jawiki-20200831/character/bert-large" \
--bert_config_file="$WORK_DIR/bert/jawiki-20200831/character/bert-large/config.json" \
--max_seq_length=512 \
--max_predictions_per_seq=80 \
--train_batch_size=256 \
--learning_rate=5e-5 \
--num_train_epochs=100 \
--num_steps_per_epoch=10000 \
--optimizer_type=adamw \
--warmup_steps=10000 \
--distribution_strategy=tpu \
--tpu=tpu04
```

## Licenses

The pretrained models are distributed under the terms of the [Creative Commons Attribution-ShareAlike 3.0](https://creativecommons.org/licenses/by-sa/3.0/).

The codes in this repository are distributed under the Apache License 2.0.

## Related Work

- Original BERT model by Google Research Team
    - https://github.com/google-research/bert
    - https://github.com/tensorflow/models/tree/master/official/nlp/bert (for TensorFlow 2.0)
- Juman-tokenized Japanese BERT model
    - Author: Kurohashi-Kawahara Laboratory, Kyoto University
    - http://nlp.ist.i.kyoto-u.ac.jp/index.php?BERT日本語Pretrainedモデル
- MeCab-Jumandic-tokenized Japanese BERT model (trained with a large mini-batch size)
    - Author: National Institute of Information and Communications Technology (NICT)
    - https://alaginrc.nict.go.jp/nict-bert/index.html
- Sentencepiece Japanese BERT model
    - Author: Yohei Kikuta
    - https://github.com/yoheikikuta/bert-japanese
- Sentencepiece Japanese BERT model, trained on SNS corpus
    - Author: Hottolink, Inc.
    - https://github.com/hottolink/hottoSNS-bert

## Acknowledgments

The models are trained with Cloud TPUs provided by [TensorFlow Research Cloud](https://www.tensorflow.org/tfrc/) program.

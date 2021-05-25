# BERT model traind from NWC2010

Invoke following commands on the root directory of this repository.

```sh
$ make -C corpus/nwc2010
$ ./train_tokenizer.sh nwc2010
$ ./create_pretraining_data.sh nwc2010
$ ./pretraining.sh nwc2010
```

# Links

 * [Original Site](http://www.s-yata.jp/corpus/nwc2010/)

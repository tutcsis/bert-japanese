# BERT model traind from NWC2010

Invoke following commands on the root directory of this repository.

```sh
$ make -C corpus/nwc2010
$ ./train_tokenizer.sh nwc2010
$ ./create_pretraining_data.sh nwc2010
$ ./pretraining.sh nwc2010
```

The original version of NWC2010 contains 5,731,944,418 lines.
Because it is too big, the script of this repository randomly samples
2% of the original data.

# Links

 * [Original Site](http://www.s-yata.jp/corpus/nwc2010/)

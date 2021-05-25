#!/usr/bin/python3

import os
import sys
import io
import random
import lzma
import fugashi
import unidic_lite
import unicodedata

sys.stdout = io.TextIOWrapper(sys.stdout.buffer, encoding='utf-8')
sys.stderr = io.TextIOWrapper(sys.stdout.buffer, encoding='utf-8')

tagger = False
def tokenize(line):
    line = unicodedata.normalize("NFKC", line)
    tokens = []
    for w in tagger(line):
        try:
            tokens.append(w.surface)
        except:
            pass
    return ' '.join(tokens)

# emplty lines are used as document separators according to
# http://www.s-yata.jp/corpus/nwc2010/texts/
def sampling(args):
    with lzma.open(args.input, mode='r') as fp:
        flag = random.random() < args.ratio
        for line in fp:
            line = line.lstrip()
            line = line.rstrip()
            if len(line) == 0:
                if flag:
                    print('', file=args.output)
                flag = random.random() < args.ratio
                continue
            if flag:
                print(tokenize(line.decode('utf-8')), file=args.output)

def parse_args():
    import argparse as ap
    p = ap.ArgumentParser()
    p.add_argument('input', type=str)
    p.add_argument('-o', '--output', type=ap.FileType('w', encoding='utf-8'), default=sys.stdout)
    p.add_argument('--ratio', type=float, default='0.01')
    p.add_argument('--seed', type=int, default=42)
    p.add_argument('--dicdir')
    p.add_argument('--rcfile')
    return p.parse_args()

def main():
    args = parse_args()
    random.seed(args.seed)
    dicdir = args.dicdir or unidic_lite.DICDIR
    rcfile = os.path.join(dicdir, 'mecabrc')
    global tagger
    tagger = fugashi.GenericTagger(f'-r {rcfile} -d {dicdir}')
    charset = tagger.dictionary_info[0]['charset']
    assert charset == 'utf-8' or charset == 'utf8'
    sampling(args)

if __name__ == '__main__':
    main()

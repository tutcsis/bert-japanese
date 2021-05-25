#!/usr/bin/python3

import os
import sys
import io
import random
import lzma
import unicodedata

sys.stdout = io.TextIOWrapper(sys.stdout.buffer, encoding='utf-8')
sys.stderr = io.TextIOWrapper(sys.stdout.buffer, encoding='utf-8')

# emplty lines are used as document separators according to
# http://www.s-yata.jp/corpus/nwc2010/texts/
def sampling(args):
    with lzma.open(args.input, mode='r') as fp:
        count = 0
        flag = random.random() < args.ratio
        for line in fp:
            line = line.lstrip()
            line = line.rstrip()
            if len(line) == 0:
                if flag and count:
                    print('', file=args.output)
                count = 0
                flag = random.random() < args.ratio
                continue
            if flag:
                line = unicodedata.normalize("NFKC", line.decode('utf-8', errors='ignore'))
                if len(line) < args.min_text_length:
                    continue
                elif len(line) > args.max_text_length:
                    continue
                else:
                    count += 1
                    print(line, file=args.output)

def parse_args():
    import argparse as ap
    p = ap.ArgumentParser()
    p.add_argument('input', type=str)
    p.add_argument('-o', '--output', type=ap.FileType('w', encoding='utf-8'), default=sys.stdout)
    p.add_argument('--ratio', type=float, default='0.02')
    p.add_argument('--seed', type=int, default=42)
    p.add_argument('--min_text_length', type=int, default=10)
    p.add_argument('--max_text_length', type=int, default=200)
    return p.parse_args()

def main():
    args = parse_args()
    random.seed(args.seed)
    sampling(args)

if __name__ == '__main__':
    main()

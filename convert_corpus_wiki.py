#!/usr/bin/python3

import sys
import io
import unicodedata

sys.stdin = io.TextIOWrapper(sys.stdin.buffer, encoding='utf-8', errors='ignore')
sys.stdout = io.TextIOWrapper(sys.stdout.buffer, encoding='utf-8')

def parse_args():
    import argparse as ap
    p = ap.ArgumentParser()
    p.add_argument('-i', '--input_file', dest='inputs', type=ap.FileType('r', encoding='utf-8', errors='ignore'), nargs='*', default=[sys.stdin])
    p.add_argument('-o', '--output_file', dest='output', type=ap.FileType('w', encoding='utf-8'), default=sys.stdout)
    p.add_argument('--min_text_length', type=int, default=10)
    p.add_argument('--max_text_length', type=int, default=200)
    return p.parse_args()

if __name__ == '__main__':
    args = parse_args()
    for fp in args.inputs:
        for text in fp:
            text = unicodedata.normalize('NFKC', text)
            if '</doc>' in text:
                print('', file=args.output)
            elif '<' == text[:1]:
                continue
            elif len(text) < args.min_text_length:
                continue
            elif len(text) > args.max_text_length:
                continue
            else:
                print(text, file=args.output, end='')

#!/bin/sh

wikidate=${1}
case ${wikidate} in
	[0-9][0-9]*)
		inputfile=corpus/jawiki-${wikidate}/corpus_sampled.txt
		outputdir=tokenizers/jawiki-${wikidate}/wordpiece_unidic_lite
		;;
	*)
		inputfile=corpus/${wikidate}/corpus_sampled.txt
		outputdir=tokenizers/${wikidate}/wordpiece_unidic_lite
		;;
esac
if [ ! -f ${inptfile} ]; then
	exit 1
fi
if [ ! -d ${outputdir} ]; then
	mkdir -p ${outputdir}
fi

generate_command(){
	workdir=`pwd`
	cat <<EOF
( cd ${workdir} && \
source ${workdir}/venv/bin/activate && \
env TOKENIZERS_PARALLELISM=false python3 train_tokenizer.py \
	--input_files ${workdir}/${inputfile} \
	--output_dir ${workdir}/${outputdir} \
	--tokenizer_type wordpiece \
	--mecab_dic_type unidic_lite \
	--vocab_size 32768 \
	--limit_alphabet 6129 \
	--num_unused_tokens 10 \
)
EOF
}

generate_command | qsub -q cpu-only -l select=1:ncpus=20:ngpus=0 -N train_tokenizer_${wikidate}

#!/bin/sh

wikidate=${1}
case ${wikidate} in
	[0-9][0-9]*)
		corpusdir=corpus/jawiki-${wikidate}
		vocabfile=tokenizers/jawiki-${wikidate}/wordpiece_unidic_lite/vocab.txt
		outputdir=bert/jawiki-${wikidate}/wordpiece_unidic_lite/pretraining_data
		;;
	*)
		corpusdir=corpus/${wikidate}
		vocabfile=tokenizers/${wikidate}/wordpiece_unidic_lite/vocab.txt
		outputdir=bert/${wikidate}/wordpiece_unidic_lite/pretraining_data
		;;
esac
if [ ! -f ${vocabfile} ]; then
	exit 1
fi
if [ ! -d ${outputdir} ]; then
	mkdir -p ${outputdir}
fi

generate_command(){
	partnum=${1}
	workdir=`pwd`
	cat <<EOF
( cd ${workdir} && \
source ${workdir}/venv/bin/activate && \
python3 create_pretraining_data.py \
	--input_file ${workdir}/${corpusdir}/corpus_${partnum}.txt \
	--output_file ${workdir}/${outputdir}/pretraining_data_${partnum}.tfrecord \
	--vocab_file ${workdir}/${vocabfile} \
	--tokenizer_type wordpiece \
	--mecab_dic_type unidic_lite \
	--do_whole_word_mask \
	--max_seq_length 512 \
	--max_predictions_per_seq 80 \
	--dupe_factor 10 \
)
EOF
}

for f in ${corpusdir}/corpus_*.txt
do
	i=`basename ${f} .txt|cut -f2 -d_`
	case ${i} in
		[0-9][0-9])
			generate_command ${i}|qsub -q cpu-only -l select=1:ncpus=8:ngpus=0 -N create_pretraining_data_${wikidate}_${i}
			;;
	esac
done

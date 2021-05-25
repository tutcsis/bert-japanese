#!/bin/sh

wikidate=${1}
case ${wikidate} in
	[0-9][0-9]*)
		datadir=bert/jawiki-${wikidate}/wordpiece_unidic_lite/pretraining_data
		modeldir=bert/jawiki-${wikidate}/wordpiece_unidic_lite/bert-base
		;;
	*)
		datadir=bert/${wikidate}/wordpiece_unidic_lite/pretraining_data
		modeldir=bert/${wikidate}/wordpiece_unidic_lite/bert-base
		;;
esac
if [ ! -d ${datadir} ]; then
	echo "Missing ${datadir}"
	exit 1
fi
if [ ! -d ${modeldir} ]; then
	mkdir -p ${modeldir}
fi

generate_command(){
	workdir=`pwd`
	cat <<EOF
( cd ${workdir} && \
module purge && \
module load cudnn/7.6.5-cuda-10.1 && \
source ${workdir}/venv/bin/activate && \
python3 check_tensorflow_gpu.py && \
python3 venv/models/official/nlp/bert/run_pretraining.py \
	--input_files="${workdir}/${datadir}/pretraining_data_*.tfrecord" \
	--model_dir="${workdir}/${modeldir}" \
	--bert_config_file="${workdir}/model_configs/bert-base-v2/wordpiece/config.json" \
	--max_seq_length=512 \
	--max_predictions_per_seq=80 \
	--train_batch_size=128 \
	--learning_rate=1e-4 \
	--num_train_epochs=100 \
	--num_steps_per_epoch=10000 \
	--optimizer_type=adamw \
	--warmup_steps=10000 \
	--distribution_strategy=mirrored \
	--num_gpus=8 \
) >${workdir}/pretraining_${wikidate}.log 2>&1
EOF
}
#generate_command
generate_command | qsub -q full-gpu -l select=1:ncpus=16:ngpus=8 -N pretraining_${wikidate}

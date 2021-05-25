#!/bin/sh

generate_command(){
	file=${1}
	curdir=`pwd`
	cat <<EOF
cd ${curdir} && xzcat ${file} | wc >>count.log
EOF
}

for f in *.xz; do
	generate_command ${f}|qsub -q cpu-only -l select=1:ncpus=1:ngpus=0 -N count_${f}
done

#!/bin/sh

generate_command(){
	infile=${1}
	outfile=`basename ${1} .xz`.dat
	curdir=`pwd`
	cat <<EOF
cd ${curdir} && python3 sampling.py ${infile} --output ${outfile}
EOF
}

for f in *.xz; do
	generate_command ${f}|qsub -q cpu-only -l select=1:ncpus=1:ngpus=0 -N sampling_${f}
done

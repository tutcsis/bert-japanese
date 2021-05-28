#!/bin/sh
#PBS -q cpu-only
#PBS -l select=1:ncpus=20

if [ -n "${PBS_O_WORKDIR}" ]; then
	if [ "${PBS_ENVIRONMENT}" != PBS_INTERACTIVE ]; then
		cd "${PBS_O_WORKDIR}"
	fi
fi
make

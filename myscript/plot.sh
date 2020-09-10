#!/bin/bash

source config.sh

if [ ! -d $PLOT_FOLDER ]; then
	mkdir $PLOT_FOLDER
fi

for metric in $MONTI_METRICS
do
	python plot.py $metric $N_PHISICAL_CORE
done

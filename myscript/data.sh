#!/bin/bash

#BENCHS="RAYTRACE RADIOSITY VOLREND WATER-NSQUARED WATER-SPATIAL BARNES FMM CHOLESKY OCEAN-CONTIGUOUS-PARTITIONS" #OCEAN-NON-CONTIGUOUS-PARTITIONS"
BENCHS="RAYTRACE RADIOSITY VOLREND"
PERF_CTRS="CLOCK ENERGY"

FOLDER="likwid-output"

(( THREADS = $1 + 1 ))
THREADS=`seq 1 $THREADS`

RUNS=$2
RUNS=`seq 0 $RUNS`

if [ -f "clock.txt" ]; then
	echo "" > clock.txt
else
	touch clock.txt
fi

if [ -f "energy.txt" ]; then
	echo "" > energy.txt
else 
	touch energy.txt
fi

for b in $BENCHS
do
	for pc in $PERF_CTRS
	do
		PC=`echo "${pc,,}"`
		DIR=./$FOLDER/$pc/$b
		for r in $RUNS
		do
			for t in $THREADS
			do
				FILE=$DIR/$b-$r-$t.txt
				if [ $pc == "CLOCK" ]; then
					python collect_clock.py $FILE $PC.txt
				else
					python collect_energy.py $FILE $PC.txt
				fi
			done
		done
	done
done 

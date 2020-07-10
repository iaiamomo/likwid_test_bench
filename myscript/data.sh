#!/bin/bash

#BENCHS="RAYTRACE RADIOSITY VOLREND WATER-NSQUARED WATER-SPATIAL BARNES FMM CHOLESKY OCEAN-CONTIGUOUS-PARTITIONS" #OCEAN-NON-CONTIGUOUS-PARTITIONS"
BENCHS="RAYTRACE RADIOSITY VOLREND"
PERF_CTRS="CLOCK ENERGY"

FOLDER="likwid-output"

(( THREADS_N = $1 + 1 ))
THREADS=`seq 1 $THREADS_N`

RUNS_N=$2
RUNS=`seq 1 $RUNS_N`

if [ -f "clock.txt" ]; then
	rm clock.txt
	touch clock.txt
else
	touch clock.txt
fi

if [ -f "energy.txt" ]; then
	rm energy.txt
	touch energy.txt
else 
	touch energy.txt
fi

if [ -f "clock_avg.txt" ]; then
	rm clock_avg.txt
	touch clock_avg.txt
else 
	touch clock_avg.txt
fi

if [ -f "energy_avg.txt" ]; then
	rm energy_avg.txt
	touch energy_avg.txt
else 
	touch energy_avg.txt
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

python avg.py clock_avg.txt $THREADS_N $RUNS_N
python avg.py energy_avg.txt $THREADS_N $RUNS_N

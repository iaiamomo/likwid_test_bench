#!/bin/bash

source config.sh

if [ -d $CSV_AVG_RUN_FOLDER ]; then
	rm -rf $CSV_AVG_RUN_FOLDER
	mkdir $CSV_AVG_RUN_FOLDER
else
	mkdir $CSV_AVG_RUN_FOLDER
fi

for g in $LIKWID_G
do
	G=./$FOLDER/"${g,,}".txt
	if [ -f $G ]; then
		rm $G
		touch $G
	else
		touch $G
	fi
	G_AVG_RUN=$CSV_AVG_RUN_FOLDER/"${g,,}"
	mkdir $G_AVG_RUN
	G_AVG_THREAD_RUN=$CSV_AVG_THREAD_RUN_FOLDER/"${g,,}"
	mkdir $G_AVG_THREAD_RUN
done

for b in $BENCHS_NAME_NPB
do
	for g in $LIKWID_G
	do
		G="${g,,}"
		DIR=./$FOLDER/$g/$b
		for r in $RUNS
		do
			for pc in $PHISICAL_CORE
			do
				LOGICAL_CORE=`seq 0 $pc`
				for lc in $LOGICAL_CORE
				do
					for f in $FREQ
					do
						FILE=$DIR/$b-r-$r-pc-$pc-lc-$lc-f-$f.txt
						python collect_$G.py $FILE ./$FOLDER/$G.txt
					done
				done
			done
		done
	done
done 

for g in $LIKWID_G
do
	G="${g,,}"
	python avg_run.py ${G}_avg.txt $N_PHISICAL_CORE $TOT_RUNS
done

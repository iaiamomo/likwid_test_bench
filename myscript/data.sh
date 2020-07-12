#!/bin/bash

source config.sh

ID_LIST_FILE=`seq 1 $TOT_THREADS`	#lista thread id nei file output

for g in $LIKWID_G
do
	G="${g,,}".txt
	if [ -f $G ]; then
		rm $G
		touch $G
	else
		touch $G
	fi
	G_AVG="${g,,}"_avg.txt
	if [ -f $G_AVG ]; then
		rm $G_AVG
		touch $G_AVG
	else
		touch $G_AVG
	fi
done

for b in $BENCHS_NAME
do
	for g in $LIKWID_G
	do
		G="${g,,}"
		DIR=./$FOLDER/$g/$b
		for r in $RUNS
		do
			for t in $ID_LIST_FILE
			do
				FILE=$DIR/$b-$r-$t.txt
				python collect_$G.py $FILE $G.txt
			done
		done
	done
done 

for b in $BENCHS_NAME_NPB
do
	for g in $LIKWID_G
	do
		G="${g,,}"
		DIR=./$FOLDER/$g/$b
		for r in $RUNS
		do
			for t in $ID_LIST_FILE
			do
				FILE=$DIR/$b-$r-$t.txt
				python collect_$G.py $FILE $G.txt
			done
		done
	done
done 

for g in $LIKWID_G
do
	G="${g,,}"
	echo ${G}_avg.txt
	python avg.py ${G}_avg.txt $TOT_THREADS $TOT_RUNS
done

#!/bin/bash

source config.sh

ID_LIST_FILE=`seq 1 $TOT_THREADS`	#lista thread id nei file output

if [ -d $AVG_FOLDER ]; then
	rm -rf $AVG_FOLDER
	mkdir $AVG_FOLDER
else
	mkdir $AVG_FOLDER
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
	G_AVG=$AVG_FOLDER/"${g,,}"
	mkdir $G_AVG
done

for b in $BENCHS_NAME_SPLASH3
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
				python collect_$G.py $FILE ./$FOLDER/$G.txt
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
				python collect_$G.py $FILE ./$FOLDER/$G.txt
			done
		done
	done
done 

for b in $BENCHS_NAME_STAMP
do
	for g in $LIKWID_G
	do
		G="${g,,}"
		DIR=./$FOLDER/$g/$b
		for r in $RUNS
		do
			for t in $ID_LIST_FILE
			do
				for nt in $PAR_N_THREAD
				do
					FILE=$DIR/$b-${nt}t-$r-$t.txt
					python collect_$G.py $FILE ./$FOLDER/$G.txt
				done
			done
		done
	done
done

for g in $LIKWID_G
do
	G="${g,,}"
	python avg.py ${G}_avg.txt $TOT_THREADS $TOT_RUNS
done

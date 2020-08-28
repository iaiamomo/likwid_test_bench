#!/bin/bash

source config.sh

ID_LIST_FILE=`seq 1 $TOT_THREADS`	#lista thread id nei file output NON SERVIRÀ PIÙ

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

#NON VIENE ESEGUITO
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
				FILE=$DIR/$b-r-$r-t-$t.txt
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

#NON VIENE ESEGUITO
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
					FILE=$DIR/$b-${nt}t-r-$r-t-$t.txt
					python collect_$G.py $FILE ./$FOLDER/$G.txt
				done
			done
		done
	done
done

#ONLY IF I HAVE MORE THAN 1 RUN
if [ "$TOT_RUNS" -gt 1] ; then
	for g in $LIKWID_G
	do
		G="${g,,}"
		python avg.py ${G}_avg.txt $TOT_THREADS $TOT_RUNS
	done
fi

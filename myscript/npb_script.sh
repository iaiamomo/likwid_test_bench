#!/bin/bash

source config.sh

#to execute likwid-perfctr i need access msr
CHECK_MSR="/dev/cpu/0/msr"
if [ ! -d "$CHECK_MSR" ]; then
	sudo modprobe msr
	sudo chmod +rw /dev/cpu/*/msr
fi

MDIR=`pwd`
cd $APPS_NPB
APPS_NPB=`pwd`
cd $MDIR

if [ ! -d $FOLDER ]; then
	mkdir -p $FOLDER
fi

if [ $COMPILE -eq 1 ]; then
	make clean-bin;
fi

if [ $EXECUTE -eq 1 ]; then
	for g in $LIKWID_G
	do
		for r in $RUNS
		do
			PIN=N:
			N_THREAD=1
			
			for t in $THREAD_ID_LIST
			do
				
				if [ $PIN == N: ] ; then
					PIN=$PIN$t
				else
					PIN=$PIN,$t
				fi
				
				for b in $BENCHS_NPB
				do
					DIR=$APPS_NPB
					nb=${APPS_NPB}/$b
					FILE=`basename $nb`				#execute basename
					PAR=`echo $FILE | tr '.' '_'`  	#substitute - with _
					GREP=`eval echo '$'GREP_$PAR`
					OUT_FILE=$MDIR/$FOLDER/$g/$FILE/$FILE-r-$r-t-$N_THREAD.txt
					mkdir -p $MDIR/$FOLDER/$g/$FILE
					cd $DIR
					echo $OUT_FILE
					
					if [ $OVERWRITE = "1" ] ; then
						echo "" > $OUT_FILE
					fi
					
					while [ ! -f  $OUT_FILE ] || [ $(grep -c "$GREP" $OUT_FILE) -eq 0 ]
					do
						likwid-perfctr -C $PIN -g $g -f ./$FILE &> $OUT_FILE
					done
					
					cd $MDIR
				done
				(( N_THREAD = $N_THREAD + 1 ))
			done
		done
	done
fi

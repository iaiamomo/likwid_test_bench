#!/bin/bash

source config.sh

#to execute likwid-perfctr i need access msr
CHECK_MSR="/dev/cpu/0/msr"
if [ ! -d "$CHECK_MSR" ]; then
	sudo modprobe msr
	sudo chmod +rw /dev/cpu/*/msr
fi

MDIR=`pwd`
cd $APPS_STAMP
APPS_STAMP=`pwd`
cd $MDIR
cd $INPUT_DIR_STAMP
INPUT_DIR_STAMP=`pwd`
cd $MDIR

#MOVE ALL INPUTS INTO A RAM FILESYSTEM
for i in $APPS_STAMP/*
do
    mkdir -p /mnt/stamp/`basename $i`/inputs
    cp $i/inputs/* /mnt/stamp/`basename $i`/inputs
done

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
				
				for b in $BENCHS_STAMP
				do
					for n_thread in $PAR_N_THREAD		#parameter to pass to benchmark
					do
						nb=${APPS_STAMP}/$b			#../stamp/benchmark
						DIR=`dirname "$nb"`		#execute dirname
						FILE=`basename $nb`		#execute basename
						PAR=`echo $FILE | tr '-' '_'`  	#substitute - with _
						PARV=`eval echo '$'PAR_$PAR`  	#eval calculate '$'PAR_$PAR -> accede ai parametri di ogni bench
						if [ "PAR_$PAR" == "PAR_vacation" ]; then
							THREAD="-c$n_thread"
							PARV=${PARV//thread/$THREAD}
						elif [ "PAR_$PAR" == "PAR_kmeans" ]; then
							THREAD="-p$n_thread"
							PARV=${PARV//thread/$THREAD}
						else
							THREAD="-t$n_thread"
							PARV=${PARV//thread/$THREAD}
						fi
						GREP=`eval echo '$'GREP_$PAR`
						N_THREAD_BENCH=2
						(( N_THREAD = $t + 1 ))
						OUT_FILE=$MDIR/$FOLDER/$g/$FILE/$FILE-${n_thread}t-$r-$N_THREAD.txt
						mkdir -p $MDIR/$FOLDER/$g/$FILE/
						cd $DIR
						echo $OUT_FILE
						
						if [ $OVERWRITE = "1" ] ; then
							echo "" > $OUT_FILE
						fi
						
						while [ ! -f  $OUT_FILE ] || [ $(grep -c "$GREP" $OUT_FILE) -eq 0 ]
						do
							likwid-perfctr -C $PIN -g $g -f ./$FILE $PARV  &> $OUT_FILE
						done
						
						cd $MDIR
					done
				done
				(( N_THREAD = $N_THREAD + 1 ))
			done
		done
	done
fi

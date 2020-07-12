#!/bin/bash

source config.sh

#to execute likwid-perfctr i need msr
CHECK_MSR="/dev/cpu/0/msr"
if [ ! -d "$CHECK_MSR" ]; then
	sudo modprobe msr
	sudo chmod +rw /dev/cpu/*/msr
fi

MDIR=`pwd`
cd $APPS
APPS=`pwd`
cd $MDIR
cd $INPUT_DIR
INPUT_DIR=`pwd`
cd $MDIR

#MOVE ALL INPUTS INTO A RAM FILESYSTEM
for i in $APPS/*
do
    mkdir -p /mnt/splash3/codes/apps/`basename $i`/inputs
    cp $i/inputs/* /mnt/splash3/codes/apps/`basename $i`/inputs
done

mkdir -p $FOLDER

if [ $COMPILE -eq 1 ]; then
	make clean-bin;
fi

if [ $EXECUTE -eq 1 ]; then
	for g in $LIKWID_G
	do
		for r in $RUNS
		do
			PIN=N:
			for t in $THREAD_ID_LIST
			do
				if [ $PIN == N: ] ; then
					PIN=$PIN$t
				else
					PIN=$PIN,$t
				fi
				
				for b in $BENCHS
				do
					nb=${APPS}/$b			#../splash3/codes/apps/benchmark
					DIR=`dirname "$nb"`		#execute dirname
					FILE=`basename $nb`		#execute basename
					SUFF=`python -c "print '-'+'$b'.split('/')[1].upper().replace('_', '-') if 'ocean' in '$DIR' else ''"`
					PAR=`echo $FILE | tr '-' '_'`  	#substitute - with _
					PARV=`eval echo '$'PAR_$PAR`  	#eval calculate '$'PAR_$PAR -> accede ai parametri di ogni bench
					GREP=`eval echo '$'GREP_$PAR`
					N_THREAD_BENCH=2
					PARV=${PARV//PROCESS/$N_THREAD_BENCH}
					(( N_THREAD = $t + 1 ))
					OUT_FILE=$MDIR/$FOLDER/$g/$FILE$SUFF/$FILE$SUFF-$r-$N_THREAD.txt
					mkdir -p $MDIR/$FOLDER/$g/$FILE$SUFF
					cd $DIR
					echo $OUT_FILE
					
					if [ $OVERWRITE = "1" ] ; then
						echo "" > $OUT_FILE
					fi
					
					while [ ! -f  $OUT_FILE ] || [ $(grep -c "$GREP" $OUT_FILE) -eq 0 ]
					do
						if [ "PAR_$PAR" == "PAR_WATER_NSQUARED" ] || [ "PAR_$PAR" == "PAR_WATER_SPATIAL" ]; then
							head -n2 $PARV > $INPUT_DIR/${FILE}tmp-splash
							val=`tail -n1 $PARV | cut -d' ' -f2`
							echo $t $val >> $INPUT_DIR/${FILE}tmp-splash
							#echo $CMDPATH/lib$l.sh ./$FILE "<" $PARV
							{ timeout $TIMEOUT /usr/bin/time  likwid-perfctr -C $PIN -g $g -f ./$FILE < $PARV; } &> $OUT_FILE
							rm $INPUT_DIR/${FILE}tmp-splash
						elif [ "PAR_$PAR" == "PAR_BARNES" ]; then
							head -n11 $PARV > $INPUT_DIR/${FILE}tmp-splash
							echo $t >> $INPUT_DIR/${FILE}tmp-splash
							#echo $CMDPATH/lib$l.sh ./$FILE "<" $PARV
							{ timeout $TIMEOUT /usr/bin/time  likwid-perfctr -C $PIN -g $g -f ./$FILE < $PARV; } &> $OUT_FILE
							rm $INPUT_DIR/${FILE}tmp-splash
						elif [ "PAR_$PAR" == "PAR_FMM" ]; then
							head -n4 $PARV > $INPUT_DIR/${FILE}tmp-splash
							echo $t >> $INPUT_DIR/${FILE}tmp-splash
							tail -n4 $PARV >> $INPUT_DIR/${FILE}tmp-splash
							#echo $CMDPATH/lib$l.sh ./$FILE "<" $PARV
							{ timeout $TIMEOUT /usr/bin/time  likwid-perfctr -C $PIN -g $g -f ./$FILE < $PARV; } &> $OUT_FILE
							rm $INPUT_DIR/${FILE}tmp-splash
						else
							#echo $CMDPATH/lib$l.sh ./$FILE $PARV
							{ timeout $TIMEOUT /usr/bin/time  likwid-perfctr -C $PIN -g $g -f ./$FILE $PARV; }  &> $OUT_FILE
						fi
					done
					
					cd $MDIR
				done
				
				for b in $BENCHS_NPB
				do
					DIR=$APPS_NPB
					nb=${APPS_NPB}/$b
					FILE=`basename $nb`				#execute basename
					PAR=`echo $FILE | tr '.' '_'`  	#substitute - with _
					GREP=`eval echo '$'GREP_$PAR`
					(( N_THREAD = $t + 1 ))
					OUT_FILE=$MDIR/$FOLDER/$g/$FILE/$FILE-$r-$N_THREAD.txt
					mkdir -p $MDIR/$FOLDER/$g/$FILE
					cd $DIR
					echo $OUT_FILE
					
					if [ $OVERWRITE = "1" ] ; then
						echo "" > $OUT_FILE
					fi
					
					while [ ! -f  $OUT_FILE ] || [ $(grep -c "$GREP" $OUT_FILE) -eq 0 ]
					do
						{ timeout $TIMEOUT /usr/bin/time  likwid-perfctr -C $PIN -g $g -f ./$FILE; }  &> $OUT_FILE
					done
					
					cd $MDIR
				done
			done
		done
	done
fi

./data.sh

exit

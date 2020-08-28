#!/bin/bash
source config.sh

MDIR=`pwd`
cd $APPS_SPLASH3
APPS_SPLASH3=`pwd`
cd $MDIR
cd $INPUT_DIR_SPLASH3
INPUT_DIR_SPLASH3=`pwd`
cd $MDIR

#MOVE ALL INPUTS INTO A RAM FILESYSTEM
for i in $APPS_SPLASH3/*
do
    mkdir -p /mnt/splash3/codes/apps/`basename $i`/inputs
    cp $i/inputs/* /mnt/splash3/codes/apps/`basename $i`/inputs
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
			PIN=""
			N_THREAD=1
			
			for t in $THREAD_ID_LIST
			do
				if [ -z "$PIN" ] ; then
					PIN=$t
				else
					PIN=$PIN,$t
				fi
				
				for b in $BENCHS_SPLASH3
				do
					nb=${APPS_SPLASH3}/$b			#../splash-3/codes/apps/benchmark
					DIR=`dirname "$nb"`		#execute dirname
					FILE=`basename $nb`		#execute basename
					SUFF=`python -c "print '-'+'$b'.split('/')[1].upper().replace('_', '-') if 'ocean' in '$DIR' else ''"`
					PAR=`echo $FILE | tr '-' '_'`  	#substitute - with _
					PARV=`eval echo '$'PAR_$PAR`  	#eval calculate '$'PAR_$PAR -> accede ai parametri di ogni bench
					GREP=`eval echo '$'GREP_$PAR`
					N_THREAD_BENCH=10
					PARV=${PARV//PROCESS/$N_THREAD_BENCH}
					OUT_FILE=$MDIR/$FOLDER/$g/$FILE$SUFF/$FILE$SUFF-r-$r-t-$N_THREAD.txt
					mkdir -p $MDIR/$FOLDER/$g/$FILE$SUFF
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
				(( N_THREAD = $N_THREAD + 1 ))
			done
		done
	done
fi

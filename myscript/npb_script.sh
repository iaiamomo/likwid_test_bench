#!/bin/bash
source config.sh

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
			for pc in $PHISICAL_CORE
			do
				LOGICAL_CORE=`seq 0 $pc`
				for lc in $LOGICAL_CORE
				do
					PIN=""
					THREAD=0
					SEQUENCE=`seq 1 $pc`
					for w in $SEQUENCE
					do
						if [ -z "$PIN" ] ; then
							PIN=$THREAD
						else
							PIN=$PIN,$THREAD
						fi
						(( THREAD = $THREAD + 2 ))
					done
					THREAD=20
					SEQUENCE=`seq 1 $lc`
					for w in $SEQUENCE
					do
						PIN=$PIN,$THREAD
						(( THREAD = $THREAD + 2 ))
					done
					#now PIN is ready to be used

					for f in $FREQ
					do
						for c in $CORES
						do
							echo userspace > /sys/devices/system/cpu/cpu${c}/cpufreq/scaling_governor
							echo $f > /sys/devices/system/cpu/cpu${c}/cpufreq/scaling_setspeed
						done

						for b in $BENCHS_NPB
						do
							DIR=$APPS_NPB
							nb=${APPS_NPB}/$b
							FILE=`basename $nb`				#execute basename
							PAR=`echo $FILE | tr '.' '_'`  	#substitute - with _
							GREP=`eval echo '$'GREP_$PAR`

							OUT_FILE=$MDIR/$FOLDER/$g/$FILE/$FILE-r-$r-pc-$pc-lc-$lc-f-$f.txt	#r=run, pc=n physical core, lc=n logical core, f=frequence

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

					done
				done 
			done
			
		done
	done
fi

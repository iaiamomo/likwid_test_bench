#!/bin/bash

source config.sh

#to execute likwid-perfctr i need msr
CHECK_MSR="/dev/cpu/0/msr"
if [ ! -d "$CHECK_MSR" ]; then
	sudo modprobe msr
	sudo chmod +rw /dev/cpu/*/msr
fi

#RELATIVE PATH TO APP FOLDER
APPS="../splash3/codes/apps"

#LIST ALL BENCHMARKS
BENCHS="raytrace/RAYTRACE radiosity/RADIOSITY volrend/VOLREND"
		#"raytrace/RAYTRACE radiosity/RADIOSITY \
		#volrend/VOLREND water-nsquared/WATER-NSQUARED \
		#water-spatial/WATER-SPATIAL barnes/BARNES fmm/FMM \
		#ocean/contiguous_partitions/OCEAN" #ocean/non_contiguous_partitions/OCEAN"

INPUT_DIR="/mnt/splash3/codes/apps"
#INPUT_DIR="../splash3/codes/apps"

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

FOLDER="likwid-output"

mkdir -p $FOLDER

PAR_RAYTRACE="-pPROCESS -m64 -a400 $INPUT_DIR/raytrace/inputs/car.env"
PAR_RADIOSITY="-p PROCESS -bf 0.0008 -room -batch" 
PAR_VOLREND="PROCESS $INPUT_DIR/volrend/inputs/head 8" #MODIFICATA 200
PAR_WATER_NSQUARED="$INPUT_DIR/water-nsquared/inputs/n512-pPROCESS" #MODIFICATA parsec_native
PAR_WATER_SPATIAL="$INPUT_DIR/water-spatial/inputs/n512-pPROCESS" #MODIFICATA parsec_native
PAR_BARNES="$INPUT_DIR/barnes/inputs/n16384-pPROCESS"
PAR_FMM="$INPUT_DIR/fmm/inputs/input.PROCESS.16384"
PAR_OCEAN="-n258 -pPROCESS -e1e-07 -r20000 -t28800"  #MODIFICATA -n2050

#./BARNES < inputs/n16384-p#
#./FMM < inputs/input.#.16384
#./OCEAN -p# -n258
#./RADIOSITY -p # -ae 5000 -bf 0.1 -en 0.05 -room -batch
#./RAYTRACE -p# -m64 inputs/car.env
#./VOLREND # inputs/head 8
#./WATER-NSQUARED < inputs/n512-p#
#./WATER-SPATIAL < inputs/n512-p#

GREP_RAYTRACE="TIMING STATISTICS MEASURED"
GREP_RADIOSITY="Elem(hierarchical)/Elem(uniform)"
GREP_VOLREND="elapsed"
GREP_WATER_NSQUARED="Exited Happily with" 
GREP_WATER_SPATIAL="Exited Happily with"
GREP_BARNES="RESTTIME"
GREP_FMM="Total time for steps"
GREP_OCEAN="Total time without initialization"

if [ $COMPILE -eq 1 ]; then
	make clean-bin;
fi


if [ $EXECUTE -eq 1 ]; then
	for r in $RUNS
	do
		PIN=N:
		for t in $THREADS
		do
			if [ $PIN == N: ] ; then
				PIN=$PIN$t
			else
				PIN=$PIN,$t
			fi
			
			for b in $BENCHS
			do
				nb=${APPS}/$b		#../splash3/codes/apps/benchmark
				DIR=`dirname "$nb"`		#execute dirname
				FILE=`basename $nb`		#execute basename
				SUFF=`python -c "print '-'+'$b'.split('/')[1].upper().replace('_', '-') if 'ocean' in '$DIR' else ''"`
				PAR=`echo $FILE | tr '-' '_'`  	#substitute - with _
				PARV=`eval echo '$'PAR_$PAR`  #eval calculate before '$'PAR_$PAR -> accede ai parametri di ogni bench
				GREP=`eval echo '$'GREP_$PAR`
				N_THREAD_BENCH=2
				PARV=${PARV//PROCESS/$N_THREAD_BENCH}
				(( THR = $t + 1 ))
				FILECLOCK=$MDIR/$FOLDER/CLOCK/$FILE$SUFF/$FILE$SUFF-$r-$THR.txt
				FILEENERGY=$MDIR/$FOLDER/ENERGY/$FILE$SUFF/$FILE$SUFF-$r-$THR.txt
				mkdir -p $MDIR/$FOLDER/CLOCK/$FILE$SUFF
				mkdir -p $MDIR/$FOLDER/ENERGY/$FILE$SUFF
				cd $DIR
				echo $FILECLOCK
				echo $FILEENERGY
				
				if [ $OVERWRITE = "1" ] ; then
					echo "" > $FILECLOCK
					echo "" > $FILEENERGY
				fi
				
				while [ ! -f  $FILECLOCK ] || [ $(grep -c "$GREP" $FILECLOCK) -eq 0 ]
				do
					if [ "PAR_$PAR" == "PAR_WATER_NSQUARED" ] || [ "PAR_$PAR" == "PAR_WATER_SPATIAL" ]; then
						head -n2 $PARV > $INPUT_DIR/${FILE}tmp-splash
						val=`tail -n1 $PARV | cut -d' ' -f2`
						echo $t $val >> $INPUT_DIR/${FILE}tmp-splash
						#echo $CMDPATH/lib$l.sh ./$FILE "<" $PARV
						{ timeout $TIMEOUT /usr/bin/time  likwid-perfctr -C $PIN -g CLOCK -f ./$FILE < $PARV; } &> $FILECLOCK
						rm $INPUT_DIR/${FILE}tmp-splash
					elif [ "PAR_$PAR" == "PAR_BARNES" ]; then
						head -n11 $PARV > $INPUT_DIR/${FILE}tmp-splash
						echo $t >> $INPUT_DIR/${FILE}tmp-splash
						#echo $CMDPATH/lib$l.sh ./$FILE "<" $PARV
						{ timeout $TIMEOUT /usr/bin/time  likwid-perfctr -C $PIN -g CLOCK -f ./$FILE < $PARV; } &> $FILECLOCK
						rm $INPUT_DIR/${FILE}tmp-splash
					elif [ "PAR_$PAR" == "PAR_FMM" ]; then
						head -n4 $PARV > $INPUT_DIR/${FILE}tmp-splash
						echo $t >> $INPUT_DIR/${FILE}tmp-splash
						tail -n4 $PARV >> $INPUT_DIR/${FILE}tmp-splash
						#echo $CMDPATH/lib$l.sh ./$FILE "<" $PARV
						{ timeout $TIMEOUT /usr/bin/time  likwid-perfctr -C $PIN -g CLOCK -f ./$FILE < $PARV; } &> $FILECLOCK
						rm $INPUT_DIR/${FILE}tmp-splash
					else
						#echo $CMDPATH/lib$l.sh ./$FILE $PARV
						{ timeout $TIMEOUT /usr/bin/time  likwid-perfctr -C $PIN -g CLOCK -f ./$FILE $PARV; }  &> $FILECLOCK
					fi
				done
				
				while [ ! -f  $FILEENERGY ] || [ $(grep -c "$GREP" $FILEENERGY) -eq 0 ]
				do
					if [ "PAR_$PAR" == "PAR_WATER_NSQUARED" ] || [ "PAR_$PAR" == "PAR_WATER_SPATIAL" ]; then
						head -n2 $PARV > $INPUT_DIR/${FILE}tmp-splash
						val=`tail -n1 $PARV | cut -d' ' -f2`
						echo $t $val >> $INPUT_DIR/${FILE}tmp-splash
						#echo $CMDPATH/lib$l.sh ./$FILE "<" $PARV
						{ timeout $TIMEOUT /usr/bin/time  likwid-perfctr -C $PIN -g ENERGY -f ./$FILE < $PARV; } &> $FILEENERGY
						rm $INPUT_DIR/${FILE}tmp-splash
					elif [ "PAR_$PAR" == "PAR_BARNES" ]; then
						head -n11 $PARV > $INPUT_DIR/${FILE}tmp-splash
						echo $t >> $INPUT_DIR/${FILE}tmp-splash
						#echo $CMDPATH/lib$l.sh ./$FILE "<" $PARV
						{ timeout $TIMEOUT /usr/bin/time  likwid-perfctr -C $PIN -g ENERGY -f ./$FILE < $PARV; } &> $FILEENERGY
						rm $INPUT_DIR/${FILE}tmp-splash
					elif [ "PAR_$PAR" == "PAR_FMM" ]; then
						head -n4 $PARV > $INPUT_DIR/${FILE}tmp-splash
						echo $t >> $INPUT_DIR/${FILE}tmp-splash
						tail -n4 $PARV >> $INPUT_DIR/${FILE}tmp-splash
						#echo $CMDPATH/lib$l.sh ./$FILE "<" $PARV
						{ timeout $TIMEOUT /usr/bin/time  likwid-perfctr -C $PIN -g ENERGY -f ./$FILE < $PARV; } &> $FILEENERGY
						rm $INPUT_DIR/${FILE}tmp-splash
					else
						#echo $CMDPATH/lib$l.sh ./$FILE $PARV
						{ timeout $TIMEOUT /usr/bin/time  likwid-perfctr -C $PIN -g ENERGY -f ./$FILE $PARV; }  &> $FILEENERGY
					fi
				done
				
				cd $MDIR
			done
		done
	done
fi

./data.sh $TOT_THREADS $TOT_RUNS

exit

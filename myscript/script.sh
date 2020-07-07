#!/bin/bash

if [ ! $# -eq 2 ]; then
	echo ./script.sh NumOfSockets NumOfCoresPerSocket
	exit 1
fi

#from command line I need # of sockets, # of cores per socket and # of threads per core
NUM_SOCKETS=$1
NUM_CORES=$2

#to execute likwid-perfctr i need msr
CHECK_MSR="/dev/cpu/0/msr"
if [ ! -d "$CHECK_MSR" ]; then
	sudo modprobe msr
	sudo chmod +rw /dev/cpu/*/msr
fi

#RELATIVE PATH TO APP FOLDER
APPS="../splash3/codes/apps"

#LIST ALL BENCHMARKS
BENCHS="raytrace/RAYTRACE radiosity/RADIOSITY " #\
		#volrend/VOLREND water-nsquared/WATER-NSQUARED \
		#water-spatial/WATER-SPATIAL barnes/BARNES fmm/FMM \
		#ocean/contiguous_partitions/OCEAN ocean/non_contiguous_partitions/OCEAN"

INPUT_DIR="../splash3/codes/apps"

MDIR=`pwd`
cd $MDIR
cd $APPS
APPS=`pwd`
cd $MDIR
cd $INPUT_DIR
INPUT_DIR=`pwd`
cd $MDIR

(( END_THREADS = 2 * $NUM_CORES ))
THREADS=`seq 1 $END_THREADS`

(( END_SOCKETS = $NUM_SOCKETS - 1 ))
SOCKETS=`seq 0 $END_SOCKETS`

COMPILE=0
EXECUTE=1

RUNS="0" # 1 2 3 4 5 6 7 8 9"
FOLDER="likwid-output"

mkdir -p $FOLDER

OVERWRITE=1

PAR_RAYTRACE="-pPROCESS -m64 -a400 $INPUT_DIR/raytrace/inputs/car.env"
PAR_RADIOSITY="-p PROCESS -bf 0.0008 -room -batch" 
PAR_VOLREND="PROCESS $INPUT_DIR/volrend/inputs/head 8" #MODIFICATA 200
PAR_WATER_NSQUARED="$INPUT_DIR/water-nsquared/inputs/parsec_native" 
PAR_WATER_SPATIAL="$INPUT_DIR/water-spatial/inputs/parsec_native"
PAR_BARNES="$INPUT_DIR/barnes/inputs/parsec_native"
PAR_FMM="$INPUT_DIR/fmm/inputs/parsec_native"
PAR_OCEAN="-n258 -pPROCESS -e1e-07 -r20000 -t28800"  #MODIFICATA -n2050

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
	for s in $SOCKETS
	do
		for t in $THREADS
		do
			for b in $BENCHS
			do
				nb=${APPS}/$b		#../splash3/codes/apps/benchmark
				DIR=`dirname "$nb"`		#execute dirname
				FILE=`basename $nb`		#execute basename
				SUFF=`python -c "print '-'+'$b'.split('/')[1].upper().replace('_', '-') if 'ocean' in '$DIR' else ''"`
				PAR=`echo $FILE | tr '-' '_'`  	#substitute - with _
				PARV=`eval echo '$'PAR_$PAR`  #eval calculate before '$'PAR_$PAR -> accede ai parametri di ogni bench
				GREP=`eval echo '$'GREP_$PAR`
				PARV=${PARV//PROCESS/$t}
				FILECLOCK=$MDIR/$FOLDER/CLOCK/$FILE$SUFF/$FILE$SUFF-$t.txt
				FILEENERGY=$MDIR/$FOLDER/ENERGY/$FILE$SUFF/$FILE$SUFF-$t.txt
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
					likwid-perfctr -c E:S$s:$t -g CLOCK ./$FILE $PARV  > $FILECLOCK
				done
				
				while [ ! -f  $FILEENERGY ] || [ $(grep -c "$GREP" $FILEENERGY) -eq 0 ]
				do
					likwid-perfctr -c E:S$s:$t -g ENERGY ./$FILE $PARV  > $FILEENERGY
				done
				
				cd $MDIR
			done
		done
	done
fi

./data.sh $END_THREADS

exit

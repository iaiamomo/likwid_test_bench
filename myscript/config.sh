#!/bin/bash

COMPILE=0
EXECUTE=1
OVERWRITE=1
TIMEOUT=5m

NUM_SOCKETS=1
NUM_CORES=2

#core list - LIKWID PIN
(( TOT_THREADS = (2 * $NUM_CORES) - 1 ))	#3
#TOT_THREADS=4
THREADS=`seq 0 $TOT_THREADS`				#0,1,2,3

#number of runs
TOT_RUNS=2									#0
RUNS=`seq 1 $TOT_RUNS`						#0

#!/bin/bash

COMPILE=0
EXECUTE=1
OVERWRITE=1
TIMEOUT=5m

NUM_SOCKETS=1
NUM_CORES=2

#core list - LIKWID PIN
TOT_THREADS=40
THREAD_ID_LIST=`seq 0 $TOT_THREADS`

#number of runs
TOT_RUNS=2
RUNS=`seq 1 $TOT_RUNS`

#LIKWID group events
LIKWID_G="CLOCK ENERGY"

#FOLDER CONTAINING OUTPUT OF THE EXECUTION
FOLDER="likwid-output"
AVG_FOLDER="likwid-output/avg"

#SPLASH
APPS_SPLASH3="../Splash-3/codes/apps"
INPUT_DIR_SPLASH3="/mnt/Splash-3/codes/apps"
BENCHS_SPLASH3="raytrace/RAYTRACE radiosity/RADIOSITY"
BENCHS_NAME_SPLASH3="RAYTRACE RADIOSITY"

PAR_RAYTRACE="-pPROCESS -m64 -a400 $INPUT_DIR_SPLASH3/raytrace/inputs/car.env"
PAR_RADIOSITY="-p PROCESS -bf 0.0008 -room -batch"

GREP_RAYTRACE="TIMING STATISTICS MEASURED"
GREP_RADIOSITY="Elem(hierarchical)/Elem(uniform)"

#NPB_OMP
APPS_NPB="../NPB3.4.1/NPB3.4-OMP/bin"
BENCHS_NPB="bt.A.x cg.A.x ep.A.x ft.A.x is.A.x lu.A.x mg.A.x sp.A.x ua.A.x"
BENCHS_NAME_NPB="bt.A.x cg.A.x ep.A.x ft.A.x is.A.x lu.A.x mg.A.x sp.A.x ua.A.x"

GREP_bt_A_x="Verification Successful"
GREP_cg_A_x="VERIFICATION SUCCESSFUL"
GREP_ep_A_x="EP Benchmark Completed."
GREP_ft_A_x="Result verification successful"
GREP_is_A_x="IS Benchmark Completed"
GREP_lu_A_x="Verification Successful"
GREP_mg_A_x="VERIFICATION SUCCESSFUL"
GREP_sp_A_x="Verification Successful"
GREP_ua_A_x="Verification Successful"

#STAMP
MAX_THREAD=2		#parameter to pass to execution of benchmarks
PAR_N_THREAD=`seq 1 $MAX_THREAD`

APPS_STAMP="../stamp_tinySTM/stamp"
INPUT_DIR_STAMP="/mnt/stamp"
BENCHS_STAMP="bayes/bayes genome/genome intruder/intruder kmeans/kmeans labyrinth/labyrinth ssca2/ssca2 vacation/vacation yada/yada"
BENCHS_NAME_STAMP="bayes genome intruder kmeans labyrinth ssca2 vacation yada"

PAR_bayes="-v32 -r4096 -n10 -p40 -i2 -e8 -s1 thread"
PAR_genome="-g16384 -s64 -n16777216 thread"
PAR_intruder="-a10 -l128 -n262144 -s1 thread"
PAR_kmeans="-m15 -n15 -t0.00001 -i $INPUT_DIR_STAMP/kmeans/inputs/random-n65536-d32-c16.txt thread"
PAR_labyrinth="-i $INPUT_DIR_STAMP/labyrinth/inputs/random-x512-y512-z7-n512.txt thread"
PAR_ssca2="-s20 -i1.0 -u1.0 -l3 -p3 thread"
PAR_vacation="-n4 -q60 -u90 -r1048576 -t4194304 thread"
PAR_yada="-a15 -i $INPUT_DIR_STAMP/yada/inputs/ttimeu1000000.2 thread"

GREP_bayes="usefull time"
GREP_genome="usefull time"
GREP_intruder="usefull time"
GREP_kmeans="usefull time"
GREP_labyrinth="usefull time"
GREP_ssca2="usefull time"
GREP_vacation="usefull time"
GREP_yada="usefull time"

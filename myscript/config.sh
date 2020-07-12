#!/bin/bash

COMPILE=0
EXECUTE=1
OVERWRITE=1
TIMEOUT=5m

NUM_SOCKETS=1
NUM_CORES=2

#core list - LIKWID PIN
(( TOT_THREADS = (2 * $NUM_CORES) - 1 ))	#3	<- solo sul mio pc, sennò dare lista id a THREAD_ID_LIST
THREAD_ID_LIST=`seq 0 $TOT_THREADS`			#0,1,2,3
TOT_THREADS=4

#number of runs
TOT_RUNS=2									#0
RUNS=`seq 1 $TOT_RUNS`						#0

#LIKWID group events
LIKWID_G="CLOCK ENERGY"

#FOLDER CONTAINING OUTPUT OF THE EXECUTION
FOLDER="likwid-output"


#SPLASH
APPS="../splash3/codes/apps"
INPUT_DIR="/mnt/splash3/codes/apps"
BENCHS="raytrace/RAYTRACE radiosity/RADIOSITY volrend/VOLREND"
BENCHS_NAME="RAYTRACE RADIOSITY VOLREND"

PAR_RAYTRACE="-pPROCESS -m64 -a400 $INPUT_DIR/raytrace/inputs/car.env"
PAR_RADIOSITY="-p PROCESS -bf 0.0008 -room -batch" 
PAR_VOLREND="PROCESS $INPUT_DIR/volrend/inputs/head 8" #MODIFICATA 200
PAR_WATER_NSQUARED="$INPUT_DIR/water-nsquared/inputs/n512-pPROCESS" #MODIFICATA parsec_native
PAR_WATER_SPATIAL="$INPUT_DIR/water-spatial/inputs/n512-pPROCESS" #MODIFICATA parsec_native
PAR_BARNES="$INPUT_DIR/barnes/inputs/n16384-pPROCESS"
PAR_FMM="$INPUT_DIR/fmm/inputs/input.PROCESS.16384"
PAR_OCEAN="-n258 -pPROCESS -e1e-07 -r20000 -t28800"  #MODIFICATA -n2050

GREP_RAYTRACE="TIMING STATISTICS MEASURED"
GREP_RADIOSITY="Elem(hierarchical)/Elem(uniform)"
GREP_VOLREND="elapsed"
GREP_WATER_NSQUARED="Exited Happily with" 
GREP_WATER_SPATIAL="Exited Happily with"
GREP_BARNES="RESTTIME"
GREP_FMM="Total time for steps"
GREP_OCEAN="Total time without initialization"

#NPB
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

#!/bin/bash

COMPILE=0
EXECUTE=1
OVERWRITE=1
TIMEOUT=5m

NUM_SOCKETS=1
NUM_CORES=2

#core list - LIKWID PIN
N_PHISICAL_CORE=10
PHISICAL_CORE=`seq 1 $N_PHISICAL_CORE`

#number of runs
TOT_RUNS=1
RUNS=`seq 1 $TOT_RUNS`

#frequencies of cores
FREQ=`cat /sys/devices/system/cpu/cpu0/cpufreq/scaling_available_frequencies`
CORES="0 2 4 6 8 10 12 14 16 18 20 22 24 26 28 30 32 34 36 38"	#cores of socket 0 to modify

#LIKWID group events
LIKWID_G="MONTI"
MONTI_METRICS="execution_time runtime runtime_unhalted clock uncore_clock cpi temperature energy power energy_pp0 power_pp0 energy_dram power_dram l2_req_rate l2_miss_rate l2_miss_ratio l3_req_rate l3_miss_rate l3_miss_ratio"

#FOLDER CONTAINING OUTPUT OF THE EXECUTION
FOLDER="likwid-output"
CSV_AVG_RUN_FOLDER="likwid-output/avg_run"
PLOT_FOLDER="likwid-output/plot"

#NPB_OMP
APPS_NPB="../NPB3.4.1/NPB3.4-OMP/bin"
BENCHS_NPB="is.A.x cg.A.x ft.A.x mg.A.x bt.A.x ep.A.x sp.A.x lu.A.x ua.A.x"
BENCHS_NAME_NPB="is.A.x cg.A.x ft.A.x mg.A.x bt.A.x ep.A.x sp.A.x lu.A.x ua.A.x"

GREP_bt_A_x="Verification Successful"
GREP_cg_A_x="VERIFICATION SUCCESSFUL"
GREP_ep_A_x="EP Benchmark Completed."
GREP_ft_A_x="Result verification successful"
GREP_is_A_x="IS Benchmark Completed"
GREP_lu_A_x="Verification Successful"
GREP_mg_A_x="VERIFICATION SUCCESSFUL"
GREP_sp_A_x="Verification Successful"
GREP_ua_A_x="Verification Successful"

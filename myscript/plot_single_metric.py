import sys
import csv
import numpy as np 
import matplotlib.pyplot as plt

lines = {"runtime":0,
		"runtime_unhalted":1,
		"clock":2,
		"uncore_clock":3,
		"cpi":4,
		"temperature":5,
		"energy":6,
		"power":7,
		"energy_pp0":8,
		"power_pp0":9,
		"energy_dram":10,
		"power_dram":11,
		"l2_req_rate":12,
		"l2_miss_rate":13,
		"l2_miss_ratio":14,
		"l3_req_rate":15,
		"l3_miss_rate":16,
		"l3_miss_ratio":17}

metric = str(sys.argv[1])

tot_cores = int(sys.argv[2])
tot_threads = tot_cores*2

freq = str(sys.argv[3])

bench = ["cg.A.x", "ft.A.x", "is.A.x", "mg.A.x"]

d_avg_thread = "./likwid-output/avg_thread_run/monti/"

x = []
y = []

for i in range(len(bench)):
	x_i=[]
	y_i=[]
	for t in range(1, tot_threads+1):	
		csv_file = d_avg_thread + bench[i] + "_t_" + str(t) + "_f_" + freq + "_monti_avg.csv"
		with open(csv_file, 'r') as f:
		    reader = csv.reader(f,delimiter="|")
		    rows = list(reader)
		    y_i.append(float(rows[lines[metric]][1]))
		    x_i.append(t)
	x.append(x_i)
	y.append(y_i)

fig, axs = plt.subplots(2,2)

idx = 0
for i in range(2):
	for j in range(2):
		axs[i,j].plot(x[idx],y[idx])
		axs[i,j].set_xticks(np.arange(0,20,step=2))
		axs[i,j].set_title(metric + " " + str(bench[idx]))
		idx+=1

for ax in axs.flat:
    ax.set(xlabel='number of threads', ylabel="")

plt.show()


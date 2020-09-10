import matplotlib
matplotlib.use('Agg')

import sys
import csv
import numpy as np 
import matplotlib.pyplot as plt
from mpl_finance import candlestick2_ochl
import math

lines = {"execution_time":0,
		"cores":1,
		"runtime":2,
		"runtime_unhalted":3,
		"clock":4,
		"uncore_clock":5,
		"cpi":6,
		"temperature":7,
		"energy":8,
		"power":9,
		"energy_pp0":10,
		"power_pp0":11,
		"energy_dram":12,
		"power_dram":13,
		"l2_req_rate":14,
		"l2_miss_rate":15,
		"l2_miss_ratio":16,
		"l3_req_rate":17,
		"l3_miss_rate":18,
		"l3_miss_ratio":19}

metric = str(sys.argv[1])

tot_cores = int(sys.argv[2])
tot_threads = tot_cores*2

frequencies = ["2201000", "2200000", "2100000", "2000000", "1900000", "1800000", "1700000", "1600000", "1500000", "1400000", "1300000", "1200000", "1100000", "1000000"]

bench = ["bt.A.x", "cg.A.x", "ep.A.x", "ft.A.x", "is.A.x", "lu.A.x", "mg.A.x", "sp.A.x", "ua.A.x"]

d_avg = "./likwid-output/avg_run/monti/"

def plot_metric_bar():
	for b in bench:
		for fr in frequencies:
			y_lab = ""
			all_data = []
			for i in range(tot_cores*2): all_data.append([])
			for pc in range(1,tot_cores+1):
				for lc in range(pc+1):
					one_data = []
					csv_file = d_avg + str(b) + "-pc-" + str(pc) + "-lc-" + str(lc) + "-f-" + str(fr) + "_monti_avg.csv"
					with open(csv_file, 'r') as f:
					    reader = csv.reader(f,delimiter="|")
					    rows = list(reader)
					    if y_lab == "":
							y_lab = rows[lines[metric]][0]
					    y_value = float(rows[lines[metric]][1])
					    x_value = pc+lc
					    x_tick = "pc-" + str(pc) + " lc-" + str(lc)
					    one_data = [x_value, y_value, x_tick]
					all_data[pc+lc-1].append(one_data) #put in the right position depending on number of cores used

			x = []
			y = []
			x_tick = []
			for i in range(tot_cores*2):
				xx = []
				yy = []
				xx_tick = []
				for l in range(len(all_data[i])):
					xx.append(float(all_data[i][l][0]))
					yy.append(float(all_data[i][l][1]))
					xx_tick.append(all_data[i][l][2])
				x.append(xx)
				y.append(yy)
				x_tick.append(xx_tick)

			fig = plt.figure(figsize=(65 * 0.45, 10))
			ax = fig.add_subplot(111)

			total_x = []
			total_x_ticks = []
			width = 0.16
			for i in range(tot_cores*2):
				for l in range(len(x[i])):
					x[i][l]+=(l*width)
					total_x.append(x[i][l])
					total_x_ticks.append(x_tick[i][l])
				ax.bar(x[i],y[i], width=width)
					
			ax.set_xticks(total_x)
			ax.set_xticklabels(total_x_ticks, rotation=90, fontsize=10)
			ax.set_xlabel('Physical cores (pc) and Logical cores (lc)', fontsize=12)
			ax.set_ylabel(y_lab, fontsize=12)
			title = b + " - " + y_lab + "- Frequency " + fr
			ax.set_title(title, fontsize=20)

			name_plot = str(b) + "-" + str(metric) + "-f-" + str(fr) + ".png"
			plt.savefig("./likwid-output/plot/"+name_plot, dpi=199)

def min_max_sdev(elem):
	min_value = min(elem)
	max_value = max(elem)

	mean = 0.0
	for el in elem:
		mean+=el
	mean=mean/len(elem)

	s_dev = 0.0
	for el in elem:
		s_dev+=pow(el-mean, 2)
	s_dev=math.sqrt(s_dev/len(elem))

	return min_value, max_value, s_dev, mean


def plot_metric_candle():
	for b in bench:
		for fr in frequencies:
			y_lab = ""
			all_data = []
			for i in range(tot_cores*2): all_data.append([])
			for pc in range(1,tot_cores+1):
				for lc in range(pc+1):
					one_data = []

					csv_file = d_avg + str(b) + "-pc-" + str(pc) + "-lc-" + str(lc) + "-f-" + str(fr) + "_monti_avg.csv"
					with open(csv_file, 'r') as f:
					    reader = csv.reader(f,delimiter="|")
					    rows = list(reader)
					    if y_lab == "":
							y_lab = rows[lines[metric]][0]

					    y_value = rows[lines[metric]][1:]
					    for i in range(len(y_value)):
					    	y_value[i] = float(y_value[i])
					    x_value = pc+lc
					    x_tick = "pc-" + str(pc) + " lc-" + str(lc)
					    one_data = [x_value, y_value, x_tick]

					all_data[pc+lc-1].append(one_data)

			hv = []
			lv = []
			sdv = []
			h_sdv = []
			l_sdv = []
			x_tick = []
			for i in range(tot_cores*2):
				for l in range(len(all_data[i])):
					mi,ma,sd,me = min_max_sdev(all_data[i][l][1])
					hv.append(ma)
					lv.append(mi)
					sdv.append(sd)
					h_sdv.append(me+sd)
					l_sdv.append(me-sd)
					x_tick.append(all_data[i][l][2])

			lv[0] = hv[0]

			fig,ax = plt.subplots(figsize=(65 * 0.45, 10))

			candlestick2_ochl(ax, l_sdv, h_sdv, hv, lv, width=0.6, colorup='green', colordown='green', alpha=0.8)

			ax.set_xticks(np.arange(0,65, step=1))
			ax.set_xticklabels(x_tick, rotation=90, fontsize=10)
			ax.set_xlabel('Physical cores (pc) and Logical cores (lc)', fontsize=12)
			ax.set_ylabel(y_lab, fontsize=12)
			title = b + " - " + y_lab + "- Frequency " + fr
			ax.set_title(title, fontsize=20)

			name_plot = str(b) + "-" + str(metric) + "-f-" + str(fr) + ".png"
			plt.savefig("./likwid-output/plot/"+name_plot, dpi=199)


if metric == "execution_time" or metric == "uncore_clock" or metric == "energy" or metric == "power" or metric == "energy_pp0" or metric == "power_pp0" or metric == "energy_dram" or metric == "power_dram":
	plot_metric_bar()
else:
	plot_metric_candle()

import sys
import csv

group = str(sys.argv[1])
d_avg = "./likwid-output/avg_run/"
d_avg_thread = "./likwid-output/avg_thread_run/"

bench = ["cg.A.x", "ft.A.x", "is.A.x", "mg.A.x"]

tot_cores = int(sys.argv[2])
tot_threads = tot_cores*2
tot_runs = int(sys.argv[3])
freq = ["2201000", "2200000", "2100000", "2000000", "1900000", "1800000", "1700000", "1600000", "1500000", "1400000", "1300000", "1200000", "1100000", "1000000"]

def isfloat(value):
	try:
		float(value)
		return True
	except ValueError:
		return False

if "monti" in group:
	for thread in range(1,tot_threads+1):
		for fre in freq:
			count = 0
			for name in bench:
				for pc in range(1,tot_cores+1):
					for lc in range(0,pc+1):
						for fr in freq:
							t = pc + lc
							if t == thread and fre == fr:
								count+=1
								runtime = [0]*t
								runtime_unhalted = [0]*t
								clock = [0]*t
								uncore_clock = 0.0
								cpi = [0]*t
								temp = [0]*t
								energy = 0.0
								power = 0.0
								energy_pp0 = 0
								power_pp0 = 0
								energy_dram = 0 
								power_dram = 0 
								l2_req_rate = [0]*t
								l2_miss_rate = [0]*t
								l2_miss_ratio = [0]*t
								l3_req_rate = [0]*t
								l3_miss_rate = [0]*t
								l3_miss_ratio = [0]*t
								with open("./likwid-output/monti.txt", "r") as f:
									lines = f.readlines()
								step = 21
								subname = "-t-" + str(thread) + "-f-" + str(fre)
								for i in range(0, len(lines), step):
									lname = lines[i]
									if name in lname and subname in lname:
										lruntime = lines[i+2].strip().split("|")[1:-1]
										lruntime_unhalted = lines[i+3].strip().split("|")[1:-1]
										lclock = lines[i+4].strip().split("|")[1:-1]
										luncore_clock = lines[i+5].strip().split(" ")[3]
										lcpi = lines[i+6].strip().split("|")[1:-1]
										ltemp = lines[i+7].strip().split("|")[1:-1]
										lenergy = lines[i+8].strip().split(" ")[2]
										lpower = lines[i+9].strip().split(" ")[2]
										lenergy_pp0 = lines[i+10].strip().split(" ")[3]
										lpower_pp0 = lines[i+11].strip().split(" ")[3]
										lenergy_dram = lines[i+12].strip().split(" ")[3]
										lpower_dram = lines[i+13].strip().split(" ")[3]
										ll2_req_rate = lines[i+14].strip().split("|")[1:-1]
										ll2_miss_rate = lines[i+15].strip().split("|")[1:-1]
										ll2_miss_ratio = lines[i+16].strip().split("|")[1:-1]
										ll3_req_rate = lines[i+17].strip().split("|")[1:-1]
										ll3_miss_rate = lines[i+18].strip().split("|")[1:-1]
										ll3_miss_ratio = lines[i+19].strip().split("|")[1:-1]

										uncore_clock+=float(luncore_clock)
										energy+=float(lenergy)
										power+=float(lpower)
										energy_pp0+=float(lenergy_pp0)
										power_pp0+=float(lpower_pp0)
										energy_dram+=float(lenergy_dram)
										power_dram+=float(lpower_dram)
										
										for th in range(t):
											runtime[th]+=float(lruntime[th].strip())
											runtime_unhalted[th]+=float(lruntime_unhalted[th].strip())
											temp[th]+=float(ltemp[th].strip())
											if isfloat(lclock[th].strip()) and isfloat(lcpi[th].strip()) and \
													isfloat(ll2_req_rate[th].strip()) and isfloat(ll2_miss_rate[th].strip()) and isfloat(ll2_miss_ratio[th].strip()) and \
													isfloat(ll3_req_rate[th].strip()) and isfloat(ll3_miss_rate[th].strip()) and isfloat(ll3_miss_ratio[th].strip()):
												clock[th]+=float(lclock[th].strip())
												cpi[th]+=float(lcpi[th].strip())
												l2_req_rate[th]+=float(ll2_req_rate[th].strip())
												l2_miss_rate[th]+=float(ll2_miss_rate[th].strip())
												l2_miss_ratio[th]+=float(ll2_miss_ratio[th].strip())
												l3_req_rate[th]+=float(ll3_req_rate[th].strip())
												l3_miss_rate[th]+=float(ll3_miss_rate[th].strip())
												l3_miss_ratio[th]+=float(ll3_miss_ratio[th].strip())
								for i in range(len(runtime)): runtime[i]=str(runtime[i]/count/tot_runs)
								for i in range(len(runtime_unhalted)): runtime_unhalted[i]=str(runtime_unhalted[i]/count/tot_runs)
								for i in range(len(temp)): temp[i]=str(temp[i]/count/tot_runs)
								for i in range(len(clock)): clock[i]=str(clock[i]/count/tot_runs)
								for i in range(len(cpi)): cpi[i]=str(cpi[i]/count/tot_runs)
								for i in range(len(l2_req_rate)): l2_req_rate[i]=str(l2_req_rate[i]/count/tot_runs)
								for i in range(len(l2_miss_rate)): l2_miss_rate[i]=str(l2_miss_rate[i]/count/tot_runs)
								for i in range(len(l2_miss_ratio)): l2_miss_ratio[i]=str(l2_miss_ratio[i]/count/tot_runs)
								for i in range(len(l3_req_rate)): l3_req_rate[i]=str(l3_req_rate[i]/count/tot_runs)
								for i in range(len(l3_miss_rate)): l3_miss_rate[i]=str(l3_miss_rate[i]/count/tot_runs)
								for i in range(len(l3_miss_ratio)): l3_miss_ratio[i]=str(l3_miss_ratio[i]/count/tot_runs)
								uncore_clock = uncore_clock/count/tot_runs
								energy = energy/count/tot_runs
								power = power/count/tot_runs
								energy_pp0 = energy_pp0/count/tot_runs
								power_pp0 = power_pp0/count/tot_runs
								energy_dram = energy_dram/count/tot_runs
								power_dram = power_dram/count/tot_runs
								f.close()

								rows = []
								runtime.insert(0, "Runtime [s]")
								runtime_unhalted.insert(0, "Runtime unhalted [s]")
								clock.insert(0, "Clock [MHz]")
								cpi.insert(0, "CPI")
								temp.insert(0, "Temperature")
								l2_req_rate.insert(0, "L2 request rate")
								l2_miss_rate.insert(0, "L2 miss rate")
								l2_miss_ratio.insert(0, "L2 miss ratio")
								l3_req_rate.insert(0, "L3 request rate")
								l3_miss_rate.insert(0, "L3 miss rate")
								l3_miss_ratio.insert(0, "L3 miss ratio")
								rows.append(runtime)
								rows.append(runtime_unhalted)
								rows.append(clock)
								rows.append(["Uncore Clock [MHz]", uncore_clock])
								rows.append(cpi)
								rows.append(temp)
								rows.append(["Energy [J]", energy])
								rows.append(["Power [W]", power])
								rows.append(["Energy PP0 [J]", energy_pp0])
								rows.append(["Power PP0 [W]", power_pp0])
								rows.append(["Energy DRAM [J]", energy_dram])
								rows.append(["Power DRAM [W]", power_dram])
								rows.append(l2_req_rate)
								rows.append(l2_miss_rate)
								rows.append(l2_miss_ratio)
								rows.append(l3_req_rate)
								rows.append(l3_miss_rate)
								rows.append(l3_miss_ratio)

								csv_file = d_avg_thread + "monti/" + name + "_t_" + str(thread) + "_f_" + str(fre) + "_monti_avg.csv"
								with open(csv_file, 'wb') as f:
									writer = csv.writer(f, delimiter="|")
									writer.writerows(rows)

import sys

f_avg = str(sys.argv[1])
d_avg = "./likwid-output/avg/"

bench = ["RAYTRACE", "RADIOSITY", "VOLREND", \
		"bt.A.x", "cg.A.x", "ep.A.x", "ft.A.x", "is.A.x", "lu.A.x", "mg.A.x", "sp.A.x", "ua.A.x"]

stamp = ["bayes", "genome", "intruder", "kmeans", "labyrinth", "ssca2", "vacation", "yada"]
thread_stamp = 2

tot_threads = int(sys.argv[2])
tot_runs = int(sys.argv[3])

for elem in stamp:
	for n in range(1,thread_stamp+1):
		nome = elem + "-" + str(n) + "t"
		bench.append(nome)

def isfloat(value):
	try:
		float(value)
		return True
	except ValueError:
		return False

if "clock" in f_avg:
	for name in bench:
		for t in range(1,tot_threads+1):
			namefile = d_avg + "clock/" + name + "_" + str(t) + "threads_" + f_avg
			r = open(namefile, "a")
			lcores = ""
			runtime = [0]*t
			runtime_unhalted = [0]*t
			clock = [0]*t
			uncore_clock = 0.0
			cpi = [0]*t
			ipc = [0]*t
			energy = 0.0
			power = 0.0
			with open("./likwid-output/clock.txt", "r") as f:
				lines = f.readlines()
			step = 11
			for i in range(0, len(lines), step):
				lname = lines[i]
				if name in lname and str(t)+"threads" in lname:
					lcores = lines[i+1]
					lruntime = lines[i+2].strip().split("|")[1:-1]
					lruntime_unhalted = lines[i+3].strip().split("|")[1:-1]
					lclock = lines[i+4].strip().split("|")[1:-1]
					luncore_clock = lines[i+5].strip().split(" ")[3]
					lcpi = lines[i+6].strip().split("|")[1:-1]
					lipc = lines[i+7].strip().split("|")[1:-1]
					lenergy = lines[i+8].strip().split(" ")[2]
					lpower = lines[i+9].strip().split(" ")[2]
					uncore_clock+=float(luncore_clock)
					energy+=float(lenergy)
					power+=float(lpower)
					for th in range(t):
						runtime[th]+=float(lruntime[th].strip())
						runtime_unhalted[th]+=float(lruntime_unhalted[th].strip())
						if isfloat(lclock[th].strip()) and isfloat(lcpi[th].strip()) and isfloat(lipc[th].strip()):
							clock[th]+=float(lclock[th].strip())
							cpi[th]+=float(lcpi[th].strip())
							ipc[th]+=float(lipc[th].strip())
			for i in range(len(runtime)): runtime[i]=str(runtime[i]/tot_runs)
			for i in range(len(runtime_unhalted)): runtime_unhalted[i]=str(runtime_unhalted[i]/tot_runs)
			for i in range(len(clock)): clock[i]=str(clock[i]/tot_runs)
			for i in range(len(cpi)): cpi[i]=str(cpi[i]/tot_runs)
			for i in range(len(ipc)): ipc[i]=str(ipc[i]/tot_runs)
			uncore_clock = uncore_clock/tot_runs
			energy = energy/tot_runs
			power = power/tot_runs
			f.close()
			r.write(name+" "+str(t)+" threads\n")
			r.write(lcores)
			r.write("Runtime [s] "+" | ".join(runtime)+"\n")
			r.write("Runtime unhalted [s] "+" | ".join(runtime_unhalted)+"\n")
			r.write("Clock [MHz] "+" | ".join(clock)+"\n")
			r.write("Uncore Clock [MHz] "+str(uncore_clock)+"\n")
			r.write("CPI "+" | ".join(cpi)+"\n")
			r.write("IPC "+" | ".join(ipc)+"\n")
			r.write("Energy [J] "+str(energy)+"\n")
			r.write("Power [W] "+str(power)+"\n\n")
elif "energy" in f_avg:
	for name in bench:
		for t in range(1,tot_threads+1):
			namefile = d_avg + "energy/" + name + "_" + str(t) + "threads_" + f_avg
			r = open(namefile, "a")
			runtime = [0]*t
			runtime_unhalted = [0]*t
			clock = [0]*t
			cpi = [0]*t
			ipc = [0]*t
			temp = [0]*t
			lcores = ""
			energy = 0.0
			power = 0.0
			energy_pp0 = 0
			power_pp0 = 0
			energy_dram = 0 
			power_dram = 0 
			with open("./likwid-output/energy.txt", "r") as f:
				lines = f.readlines()
			step = 15
			for i in range(0, len(lines), step):
				lname = lines[i]
				if name in lname and str(t)+"threads" in lname:
					lcores = lines[i+1]
					lruntime = lines[i+2].strip().split("|")[1:-1]
					lruntime_unhalted = lines[i+3].strip().split("|")[1:-1]
					lclock = lines[i+4].strip().split("|")[1:-1]
					lcpi = lines[i+5].strip().split("|")[1:-1]
					lipc = lines[i+6].strip().split("|")[1:-1]
					lenergy = lines[i+7].strip().split(" ")[2]
					lpower = lines[i+8].strip().split(" ")[2]
					lenergy_pp0 = lines[i+9].strip().split(" ")[3]
					lpower_pp0 = lines[i+10].strip().split(" ")[3]
					lenergy_dram = lines[i+11].strip().split(" ")[3]
					lpower_dram = lines[i+12].strip().split(" ")[3]
					ltemp = lines[i+13].strip().split("|")[1:-1]
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
						if isfloat(lclock[th].strip()) and isfloat(lcpi[th].strip()) and isfloat(lipc[th].strip()):
							clock[th]+=float(lclock[th].strip())
							cpi[th]+=float(lcpi[th].strip())
							ipc[th]+=float(lipc[th].strip())
			for i in range(len(runtime)): runtime[i]=str(runtime[i]/tot_runs)
			for i in range(len(runtime_unhalted)): runtime_unhalted[i]=str(runtime_unhalted[i]/tot_runs)
			for i in range(len(temp)): temp[i]=str(temp[i]/tot_runs)
			for i in range(len(clock)): clock[i]=str(clock[i]/tot_runs)
			for i in range(len(cpi)): cpi[i]=str(cpi[i]/tot_runs)
			for i in range(len(ipc)): ipc[i]=str(ipc[i]/tot_runs)
			energy = energy/tot_runs
			power = power/tot_runs
			energy_pp0 = energy_pp0/tot_runs
			power_pp0 = power_pp0/tot_runs
			energy_dram = energy_dram/tot_runs
			power_dram = power_dram/tot_runs
			f.close()
			r.write(name+" "+str(t)+" threads\n")
			r.write(lcores)
			r.write("Runtime [s] "+" | ".join(runtime)+"\n")
			r.write("Runtime unhalted [s] "+" | ".join(runtime_unhalted)+"\n")
			r.write("Clock [MHz] "+" | ".join(clock)+"\n")
			r.write("CPI "+" | ".join(cpi)+"\n")
			r.write("IPC "+" | ".join(ipc)+"\n")
			r.write("Energy [J] "+str(energy)+"\n")
			r.write("Power [W] "+str(power)+"\n")
			r.write("Energy PP0 [J] "+str(energy_pp0)+"\n")
			r.write("Power PP0 [W] "+str(power_pp0)+"\n")
			r.write("Energy DRAM [J] "+str(energy_pp0)+"\n")
			r.write("Power DRAM [W] "+str(power_pp0)+"\n")
			r.write("Temperature "+" | ".join(temp)+"\n\n")
		

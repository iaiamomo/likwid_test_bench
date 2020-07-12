import sys

f_avg = sys.argv[1]
r = open(f_avg, "a")

bench = ["RAYTRACE", "RADIOSITY", "VOLREND", "bt.A.x", "cg.A.x", "ep.A.x", "ft.A.x", "is.A.x", "lu.A.x", "mg.A.x", "sp.A.x", "ua.A.x"]
tot_threads = int(sys.argv[2])
tot_runs = int(sys.argv[3])

if "clock" in f_avg:
	for name in bench:
		energy = 0.0
		power = 0.0
		with open("clock.txt", "r") as f:
			lines = f.readlines()
		step = 7	#step tra un risultato e l'altro in clock.txt
		for i in range(0, len(lines), step):
			lname = lines[i]
			if name in lname:
				lenergy = lines[i+4].strip().split(" ")[2]
				lpower = lines[i+5].strip().split(" ")[2]
				energy+=float(lenergy)
				power+=float(lpower)
		energy = energy/tot_runs
		power = power/tot_runs
		f.close()
		for t in range(1,tot_threads+1):
			cpi = [0]*t
			ipc = [0]*t
			lcores = ""
			with open("clock.txt", "r") as f:
				lines = f.readlines()
			for i in range(0, len(lines), step):
				lname = lines[i]
				if name in lname and str(t)+"threads" in lname:
					lcores = lines[i+1]
					lcpi = lines[i+2].strip().split("|")[1:-1]
					lipc = lines[i+3].strip().split("|")[1:-1]
					for th in range(t):
						cpi[th]+=float(lcpi[th].strip())
						ipc[th]+=float(lipc[th].strip())
			for i in range(len(cpi)): cpi[i]=str(cpi[i]/tot_runs)
			for i in range(len(ipc)): ipc[i]=str(ipc[i]/tot_runs)
			f.close()
			r.write(name+" "+str(t)+" threads\n")
			r.write(lcores)
			r.write("CPI "+" | ".join(cpi)+"\n")
			r.write("IPC "+" | ".join(ipc)+"\n")
			r.write("Energy [J] "+str(energy)+"\n")
			r.write("Power [W] "+str(power)+"\n\n")
elif "energy" in f_avg:
	for name in bench:
		energy = 0.0
		power = 0.0
		energy_pp0 = 0
		power_pp0 = 0
		energy_dram = 0 
		power_dram = 0 
		with open("energy.txt", "r") as f:
			lines = f.readlines()
		step = 12	#step tra un risultato e l'altro in energy.txt
		for i in range(0, len(lines), step):
			lname = lines[i]
			if name in lname:
				lenergy = lines[i+4].strip().split(" ")[2]
				lpower = lines[i+5].strip().split(" ")[2]
				lenergy_pp0 = lines[i+6].strip().split(" ")[3]
				lpower_pp0 = lines[i+7].strip().split(" ")[3]
				lenergy_dram = lines[i+8].strip().split(" ")[3]
				lpower_dram = lines[i+9].strip().split(" ")[3]
				energy+=float(lenergy)
				power+=float(lpower)
				energy_pp0+=float(lenergy_pp0)
				power_pp0+=float(lpower_pp0)
				energy_dram+=float(lenergy_dram)
				power_dram+=float(lpower_dram)
		energy = energy/tot_runs
		power = power/tot_runs
		energy_pp0 = energy_pp0/tot_runs
		power_pp0 = power_pp0/tot_runs
		energy_dram = energy_dram/tot_runs
		power_dram = power_dram/tot_runs
		f.close()
		for t in range(1,tot_threads+1):
			cpi = [0]*t
			ipc = [0]*t
			temp = [0]*t
			lcores = ""
			with open("energy.txt", "r") as f:
				lines = f.readlines()
			for i in range(0, len(lines), step):
				lname = lines[i]
				if name in lname and str(t)+"threads" in lname:
					lcores = lines[i+1]
					lcpi = lines[i+2].strip().split("|")[1:-1]
					lipc = lines[i+3].strip().split("|")[1:-1]
					ltemp = lines[i+10].strip().split("|")[1:-1]
					for th in range(t):
						cpi[th]+=float(lcpi[th].strip())
						ipc[th]+=float(lipc[th].strip())
						temp[th]+=float(ltemp[th].strip())
			for i in range(len(cpi)): cpi[i]=str(cpi[i]/tot_runs)
			for i in range(len(ipc)): ipc[i]=str(ipc[i]/tot_runs)
			for i in range(len(temp)): temp[i]=str(temp[i]/tot_runs)
			f.close()
			r.write(name+" "+str(t)+" threads\n")
			r.write(lcores)
			r.write("CPI "+" | ".join(cpi)+"\n")
			r.write("IPC "+" | ".join(ipc)+"\n")
			r.write("Energy [J] "+str(energy)+"\n")
			r.write("Power [W] "+str(power)+"\n")
			r.write("Energy PP0 [J] "+str(energy_pp0)+"\n")
			r.write("Power PP0 [W] "+str(power_pp0)+"\n")
			r.write("Energy DRAM [J] "+str(energy_pp0)+"\n")
			r.write("Power DRAM [W] "+str(power_pp0)+"\n")
			r.write("Temperature "+" | ".join(temp)+"\n\n")
		

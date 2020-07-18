import sys

report = sys.argv[2]

f = sys.argv[1]
namefile = f

print f

f = open(f)
r = open(report, "a")

bench = namefile.split("/")[-1]
bench = bench[:bench.rfind(".")]+"threads \n"
r.write(bench)

first_line=""
runtime="| "
runtime_unhalted="| "
clock="| "
cpi="| "
ipc="| "
energy=""
power=""
energy_pp0=""
power_pp0=""
energy_dram=""
power_dram=""
temperature="| "
n=0

def isfloat(value):
	try:
		float(value)
		return True
	except ValueError:
		return False

for l in f.readlines():
	if "Runtime (RDTSC) [s]" in l and "Runtime (RDTSC) [s] STAT" not in l:
		l=l.strip("|").strip().split("|")
		n=len(l)-1
		for i in range(1,len(l)):
			if len(l[i].strip())>0:
				runtime=runtime+l[i].strip()+" | "
	elif "Runtime unhalted [s]" in l and "Runtime unhalted [s] STAT" not in l:
		l=l.strip("|").strip().split("|")
		n=len(l)-1
		for i in range(1,len(l)):
			if len(l[i].strip()) > 0:
				runtime_unhalted=runtime_unhalted+l[i].strip()+" | "
	elif "Clock [MHz]" in l and "Clock [MHz] STAT" not in l:
		l=l.strip("|").strip().split("|")
		n=len(l)-1
		for i in range(1,len(l)):
			if len(l[i].strip())>0:
				if isfloat(l[i].strip()):
					clock=clock+l[i].strip()+" | "
				else:
					clock=clock+"- | "
	elif "CPI" in l and "CPI STAT" not in l:
		l=l.strip("|").strip().split("|")
		n=len(l)-1
		for i in range(1,len(l)):
			if len(l[i].strip())>0:
				if isfloat(l[i].strip()):
					cpi=cpi+l[i].strip()+" | "
					inv_cpi=1.0/(float(l[i].strip()))
					ipc=ipc+str(inv_cpi)+" | "
				else:
					cpi=cpi+"- | "
					ipc=ipc+"- | "
	elif "Energy [J]" in l and "Energy [J] STAT" not in l:
		l=l.strip("|").strip().split("|")
		energy=energy+l[1].strip()+" "
	elif "Power [W]" in l and "Power [W] STAT" not in l:
		l=l.strip("|").strip().split("|")
		power=power+l[1].strip()+" "
	elif "Energy PP0 [J]" in l and "Energy PP0 [J] STAT" not in l:
		l=l.strip("|").strip().split("|")
		energy_pp0=energy_pp0+l[1].strip()+" "
	elif "Power PP0 [W]" in l and "Power PP0 [W] STAT" not in l:
		l=l.strip("|").strip().split("|")
		power_pp0=power_pp0+l[1].strip()+" "
	elif "Energy DRAM [J]" in l and "Energy DRAM [J] STAT" not in l:
		l=l.strip("|").strip().split("|")
		energy_dram=energy_dram+l[1].strip()+" "
	elif "Power DRAM [W]" in l and "Power DRAM [W] STAT" not in l:
		l=l.strip("|").strip().split("|")
		power_dram=power_dram+l[1].strip()+" "
	elif "Temperature [C]" in l and "Temperature [C] STAT" not in l:
		l=l.strip("|").strip().split("|")
		for i in range(1, len(l)):
			if len(l[i]) > 0:
				temperature=temperature+l[i].strip()+" | "
	elif "Core 0" in l and first_line == "":
		first_line="\t| "
		l=l.strip("|").strip().split("|")
		for i in range(2, len(l)):
			first_line=first_line+" | "+l[i].strip()
		first_line=first_line+" |"

r.write(first_line+"\n")
r.write("Runtime [s] "+runtime+"\n")
r.write("Runtime unhalted [s] "+runtime_unhalted+"\n")
r.write("Clock [MHz] "+clock+"\n")
r.write("CPI "+cpi+"\n")
r.write("IPC "+ipc+"\n")
r.write("Energy [J] "+energy+"\n")
r.write("Power [W] "+power+"\n")
r.write("Energy PP0 [J] "+energy_pp0+"\n")
r.write("Power PP0 [W] "+power_pp0+"\n")
r.write("Energy DRAM [J] "+energy_dram+"\n")
r.write("Power DRAM [W] "+power_dram+"\n")
r.write("Temperature "+temperature+"\n\n")

r.close()

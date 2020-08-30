import sys
import csv

group = str(sys.argv[1])	#gruppo minunscolo
d_avg = "./likwid-output/avg/"
d_csv_avg = "./likwid-output/csv_avg/"

bench = ["cg.A.x", "ft.A.x", "is.A.x", "mg.A.x"]

tot_cores = int(sys.argv[2])
freq = ["2201000", "2200000", "2100000", "2000000", "1900000", "1800000", "1700000", "1600000", "1500000", "1400000", "1300000", "1200000", "1100000", "1000000"]

if "monti" in group:
	for name in bench:
		for pc in range(1,tot_cores+1):
			for lc in range(0,pc+1):
				for fr in freq:
					t = pc + lc
					subname = "-pc-" + str(pc) + "-lc-" + str(lc) + "-f-" + str(fr)
					namefile = d_avg + "monti/" + name + subname + "_monti_avg.txt"
					with open(namefile, "r") as f:
						lines = f.readlines()
					rows = []
					rows.append(['tot threads',t])
					rows.append(lines[3].strip().split("|"))
					rows.append(lines[4].strip().split("|"))
					rows.append(lines[5].strip().split("|"))
					rows.append(lines[6].strip().split("|"))
					rows.append(lines[7].strip().split("|"))
					rows.append(lines[8].strip().split("|"))
					rows.append(lines[9].strip().split("|"))
					rows.append(lines[10].strip().split("|"))
					rows.append(lines[11].strip().split("|"))
					rows.append(lines[12].strip().split("|"))
					rows.append(lines[13].strip().split("|"))
					rows.append(lines[14].strip().split("|"))
					rows.append(lines[15].strip().split("|"))
					rows.append(lines[16].strip().split("|"))
					rows.append(lines[17].strip().split("|"))
					rows.append(lines[18].strip().split("|"))
					rows.append(lines[19].strip().split("|"))
					rows.append(lines[20].strip().split("|"))
					csv_file = d_csv_avg + "monti/" + name + subname + "_monti_avg.csv"
					with open(csv_file, 'wb') as f:
						writer = csv.writer(f, delimiter="|")
						writer.writerows(rows)

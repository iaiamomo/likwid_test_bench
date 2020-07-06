import sys

report = sys.argv[2]

f = sys.argv[1]
namefile = f

print f

f = open(f)
r = open(report, "a")

bench = namefile.split("/")[-1]
bench = bench[:bench.find(".")]+"threads \n"
r.write(bench)

first_line=""
cpi=""
energy=""
power=""
n=0

for l in f.readlines():
    if "CPI" in l and "CPI STAT" not in l:
        l=l.strip("|").strip().split("|")
        n=len(l)-1
        for i in range(1,len(l)):
            cpi=cpi+l[i].strip()+" "
    elif "Energy [J]" in l and "Energy [J] STAT" not in l:
        l=l.strip("|").strip().split("|")
        energy=energy+l[1].strip()+" "
    elif "Power [W]" in l and "Power [W] STAT" not in l:
        l=l.strip("|").strip().split("|")
        power=power+l[1].strip()+" "
    elif "Core 0" in l and first_line == "":
        first_line="\t| "
        l=l.strip("|").strip().split("|")
        for i in range(2, len(l)):
            first_line=first_line+" | "+l[i].strip()
        first_line=first_line+" |"
        
r.write(first_line+"\n")
r.write("CPI "+cpi+"\n")
r.write("Energy "+energy+"\n")
r.write("Power "+power+"\n\n")

r.close()
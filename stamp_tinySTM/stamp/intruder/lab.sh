# Inizializzo le variabili relative ai parametri passati in ingresso allo script

#!/bin/bash

maxThread=32
runPerThread=8

nthread=1
array=(0 4 8 12 16 20 24 28 1 5 9 13 17 21 25 29 2 6 10 14 18 22 26 30 3 7 11 15 19 23 27 31 0 4 8 12 16 20 24 28 1 5 9 13 17 21 25 29 2 6 10 14 18 22 26 30 3 7 11 15 19 23 27 31)
while [ $nthread -lt $maxThread ]
	do
	k=0
	while [ $k -lt $runPerThread ]
		do
	        echo $nthread
	        j=1
	        affinity=0
	        while [ $j -lt $nthread ]
		do
	                affinity=$(echo $affinity,${array[$j]})
	                j=$[$j+1]
	        done
	        echo nice -20 taskset -c $affinity ./intruder -a10 -l128 -n262144 -s1 -p$nthread		
# with affinity	nice -20 taskset -c $affinity ./intruder -a10 -l128 -n262144 -s1 -t$nthread > ris0.txt		
		nice -20 ./intruder -a10 -l128 -n262144 -s1 -t$nthread > ris0.txt		
		grep "Elapsed" ris0.txt|sed -E -e "s/[a-zA-Z =]*//g" > ris1.txt
		grep "Starts" ris0.txt|sed -E -e "s/([a-zA-Z0-9= ]*)Starts=([0-9]*) Aborts[= a-zA-Z0-9]*/\2/" > ris2.txt
		grep "Starts" ris0.txt|sed -E -e "s/([a-zA-Z0-9= ]*)Aborts=([0-9]*)/\2/" > ris3.txt
		exec 4<ris1.txt
		read -u 4 tempo
		exec 5<ris2.txt
		read -u 5 transazioni
		exec 6<ris3.txt
		read -u 6 abort
		echo $nthread,$tempo,$transazioni,$abort >> risultati.csv 

		k=$[$k+1]
	done
	nthread=$[$nthread+1]
done


#ciclo:
#	Avvio il benchmark
#	intercetto la fine del benchmark
#	faccio il parsing dell'output
#	salvo i risultati su file
#	genero nuovi parametri per il benchmark
#fine ciclo

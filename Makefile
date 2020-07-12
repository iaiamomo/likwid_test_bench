all: splash3-c NPB3.4.1-c

splash3-c: splash3
	cd splash3/codes; make;
	
NPB3.4.1-c: NPB3.4.1
	cd NPB3.4.1/NPB3.4-OMP; make suite;
	
splash3:
	git clone https://github.com/SakalisC/Splash-3.git splash3

clean:
	cd splash3/codes; make clean
	cd NPB3.4.1/NPB3.4-OMP; make clean

rm:
	rm -r -f splash3 NPB3.4.1

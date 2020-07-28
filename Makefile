all: splash3-c NPB3.4.1-c stamp_tinySTM-c

splash3-c: splash3
	cd splash3/codes; make;
	
NPB3.4.1-c: NPB3.4.1
	cd NPB3.4.1/NPB3.4-OMP; make suite;
	
stamp_tinySTM-c: stamp_tinySTM
	cd stamp_tinySTM; ./make_all.sh

splash3:
	git clone https://github.com/SakalisC/Splash-3.git splash3

clean:
	cd splash3/codes; make clean
	cd NPB3.4.1/NPB3.4-OMP; make clean

rm:
	rm -r -f splash3 NPB3.4.1 stamp_tinySTM

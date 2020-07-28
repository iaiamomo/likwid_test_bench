all: Splash3-c NPB3.4.1-c stamp_tinySTM-c

Splash3-c: Splash-3
	cd Splash-3/codes; make;
	
NPB3.4.1-c: NPB3.4.1
	cd NPB3.4.1/NPB3.4-OMP; make suite;
	
stamp_tinySTM-c: stamp_tinySTM
	cd stamp_tinySTM; ./make_all.sh

clean:
	cd Splash-3/codes; make clean
	cd NPB3.4.1/NPB3.4-OMP; make clean

rm:
	rm -r -f Splash-3 NPB3.4.1 stamp_tinySTM

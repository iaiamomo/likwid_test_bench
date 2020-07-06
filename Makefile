all: lockbench-c splash3-c #sqlite-c 

libmutlock-c: libmutlock
	cd libmutlock; make

lockbench-c: libmutlock-c lockbench 
	cd libmutlock; make install INSTALL_SO_PATH=../lockbench/libs INSTALL_INC_PATH=../lockbench/include
	cd lockbench; make;
	cd lockbench/script; ./create_machine_conf.sh 

splash3-c: splash3 myscript
	cd splash3/codes; make;
	
splash3:
	git clone https://github.com/SakalisC/Splash-3.git splash3
	
libmutlock:
	git clone --single-branch --branch litl https://github.com/HPDCS/libmutlock.git

clean:
	cd lockbench; make clean
	cd splash3/codes; make clean

rm:
	rm -r -f lockbench splash3 
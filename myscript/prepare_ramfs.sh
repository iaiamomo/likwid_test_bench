mkdir -p /mnt/splash3/codes/apps
mkdir -p /mnt/stamp
mount -t ramfs -o size=20m ramfs /mnt/splash3/codes/apps
mount -t ramfs -o size=20m ramfs /mnt/stamp
chown $1:$2 /mnt/splash3/codes/apps		#passare utente:utente
chown $1:$2 /mnt/stamp					#passare utente:utente

#to execute likwid-perfctr i need access msr
CHECK_MSR="/dev/cpu/0/msr"
if [ ! -d "$CHECK_MSR" ]; then
	modprobe msr
fi
chmod +rw /dev/cpu/*/msr
chown $1:$2 /dev/cpu/*/msr 

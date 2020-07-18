mkdir -p /mnt/splash3/codes/apps
mkdir -p /mnt/stamp
mount -t ramfs -o size=20m ramfs /mnt/splash3/codes/apps
mount -t ramfs -o size=20m ramfs /mnt/stamp
chown $1:$2 /mnt/splash3/codes/apps		#passare utente:utente
chown $1:$2 /mnt/stamp					#passare utente:utente

mkdir -p /mnt/splash3/codes/apps
mount -t ramfs -o size=20m ramfs /mnt/splash3/codes/apps
chown $1:$2 /mnt/splash3/codes/apps

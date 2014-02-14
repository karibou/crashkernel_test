#!/bin/bash

cat << EOF > ~/0_kdump.patch
--- 0_kdump.orig	2014-02-13 11:41:13.266022716 +0000
+++ 0_kdump	2014-02-13 11:53:33.514883959 +0000
@@ -59,6 +59,10 @@
 
 mount -n --bind /proc \$rootmnt/proc
 
+uname -r >> \${rootmnt}/root/kdump_test
+echo "Before makedumpfile" >> \${rootmnt}/root/kdump_test
+cat /proc/meminfo | egrep "MemTotal|MemFree" >> \${rootmnt}/root/kdump_test
+
 # Delete it if the copy fails, mainly to keep from filling up filesystems
 # by accident.
 #
@@ -67,6 +71,9 @@
 
 chmod 400 \$rootmnt/\$CRASHFILE
 
+echo "After makedumpfile" >> \${rootmnt}/root/kdump_test
+cat /proc/meminfo | egrep "MemTotal|MemFree" >> \${rootmnt}/root/kdump_test
+
 # Unmount any extra filesystems we had to mount
 for target in \$mounted; do
 	umount -n \${rootmnt}\$target
EOF

echo "### Patching 0_kdump ###"
cd /usr/share/initramfs-tools/scripts/init-bottom
patch -p0 < ~/0_kdump.patch

echo "### Fixing 64M crashkernel issue ###"
sed -i s/64M/128M/g /etc/grub.d/10_linux
update-grub

echo "### Rebuilding initrd ###"
update-initramfs -u -k $(uname -r)

echo "echo c > /proc/sysrq-trigger" > /home/ubuntu/crashit
chown root:root /home/ubuntu/crashit
chmod 6777 /home/ubuntu/crashit

exit 0

# Optional Convenience Script - Default Dojo Setup
# Please note these scripts are intended for those that have similar hardware/OS and some experience
# ALWAYS analyze scripts before downloading and running them!!!

# Give the script permission and run it when you are ready
# Use command $ chmod 555 NAME.sh
# Use command $ ./NAME.sh

# system setup starts
echo ""
echo "***"
echo "Installing Updates"
echo "***"
echo ""
apt-get update
apt-get upgrade
apt-get dist-upgrade

echo ""
echo "***"
echo "Format the SSD"
echo "See comments of this script for help
echo "***"
echo ""
sleep 10s
fdisk /dev/sda
# delete existing drive partition
# Press 'd'
# Press 'w'
sleep 2s
fdisk /dev/sda
# create new primary drive partition
# Press 'n'
# Press 'p'
# Press '1'
# Press 'enter'
# Press 'enter'
# Press 'w'

echo ""
echo "***"
echo "Displaying the NAME on the external disk"
echo "About to try formatting ext4 partition1 /dev/sda1"
echo "***"
echo ""
lsblk -o UUID,NAME,FSTYPE,SIZE,LABEL,MODEL
# double-check that /dev/sda exists, and that its storage capacity is what you expected
sleep 10s
mkfs.ext4 /dev/sda1
# format partion 1 to ext4
lsblk -o UUID,NAME, | grep sda1 >> ~/uuid.txt
# look up uuid of sda1 and make txt file with that value
sed -i 's/ sda1//g' ~/uuid.txt
# removes the text sda1 after the uuid in txt file
sed 1's|$| /mnt/usb ext4 rw,nosuid,dev,noexec,noatime,nodiratime,auto,nouser,async,nofail 0 2 &|' ~/uuid.txt
# adds path and other options after the uuid in txt file
cat ~/uuid.txt >> /etc/fstab
# adds the line to fstab
rm ~/uuid.txt
# delete txt file

echo ""
echo "***"
echo "Creating /mnt/usb and mounting all drives"
echo "Check output for /dev/sda1"
echo "***"
echo ""
mkdir /mnt/usb
mount -a
sleep 5s
df /mnt/usb
sleep 10s

echo ""
echo "***"
echo "Installing fail2ban, git, curl, unzip, net-tools"
echo "***"
echo ""
apt-get install fail2ban
apt-get install git
apt-get install curl
apt-get install unzip
apt-get install net-tools

echo ""
echo "***"
echo "Set your timezone."
echo "***"
echo ""
dpkg-reconfigure tzdata

echo ""
echo "***"
echo "Running setup-odroid in 10 seconds"
echo "Change root password, hostname, move rootfs, etc." 
echo "This tool may ask you to reboot to apply the changes once you are finished"
echo "***"
echo ""
sleep 10s
setup-odroid
#system setup ends

# ufw setup starts
echo ""
echo "***"
echo "Installing ufw and setting up rules"
echo "***"
echo ""
apt-get install ufw
ufw default deny incoming
ufw default allow outgoing
# Take note of the following lines that start with ufw allow from 192.168.0.0/24
# These 2 lines assume that the IP address of your ODROID is something like 192.168.0.???
# If your IP address is 12.34.56.78, you must adapt this line to ufw allow from 12.34.56.0/24
ufw allow from 192.168.0.0/24 to any port 22 comment 'SSH access restricted to local LAN only'
ufw allow from 192.168.0.0/24 to any port 8899 comment 'allow whirlpool-gui on local network to access whirlpool-cli on Odroid'

echo ""
echo "***"
echo "Enabling ufw, check settings if connection failure"
echo "***"
echo ""
sleep 5s
ufw enable
systemctl enable ufw

echo ""
echo "***"
echo "Running ufw status"
echo "***"
echo ""
ufw status
sleep 5s

echo ""
echo "***"
echo "Take a moment to look at the rules that were just created"
echo "***"
echo ""
sleep 20s
# ufw setup ends



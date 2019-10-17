# Optional Convenience Script - Default Dojo Setup
# Please note these scripts are intended for those that have similar hardware/OS and some experience
# ALWAYS analyze scripts before downloading and running them!!!

# Use a search function like Ctrl + F in browser to find "EDIT 1", "EDIT 2", "EDIT 3"...
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
echo "See comments of this script for help"
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
echo "Using ext4 format, partition1, /dev/sda1"
echo "***"
echo ""
mkfs.ext4 /dev/sda1
# format partion 1 to ext4

echo ""
echo "***"
echo "Displaying the name on the external disk"
echo "***"
echo ""
lsblk -o UUID,NAME,FSTYPE,SIZE,LABEL,MODEL
# double-check that /dev/sda exists, and that its storage capacity is what you expected
sleep 10s

echo ""
echo "***"
echo "Editing /etc/fstab to input UUID for sda1 and settings"
echo "***"
echo ""
sleep 5s
lsblk -o UUID,NAME | grep sda1 >> ~/uuid.txt
# look up uuid of sda1 and make txt file with that value
sed -i 's/ └─sda1//g' ~/uuid.txt
# removes the text sda1 after the uuid in txt file
sed -i 1's|$| /mnt/usb ext4 rw,nosuid,dev,noexec,noatime,nodiratime,auto,nouser,async,nofail 0 2 &|' ~/uuid.txt
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
sleep 5s
mkdir /mnt/usb
mount -a
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
sleep 5s
dpkg-reconfigure tzdata
#system setup pauses here, and resumes at the very end of this script

# ufw setup starts
echo ""
echo "***"
echo "Installing ufw and setting up rules"
echo "***"
echo ""
apt-get install ufw
ufw default deny incoming
ufw default allow outgoing
# EDIT 1
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

# pip setup starts
echo ""
echo "***"
echo "Installing the Python Package Installer and its dependencies"
echo "***"
echo ""
sleep 5s
cd ~
apt-get install python3-dev 
apt-get install libffi-dev 
apt-get install libssl-dev 
apt-get install build-essential
# these are useful libs in general for your system
curl https://bootstrap.pypa.io/get-pip.py -o get-pip.py
# this is a convenient script, be sure to check it before running!!!
python3 get-pip.py
# pip setup ends

# docker setup starts
echo ""
echo "***"
echo "Installing docker and docker-compose"
echo "***"
echo ""

echo ""
echo "***"
echo "Downloading docker install script"
echo "Check git commit on line 19 https://github.com/docker/docker-install/blob/master/install.sh before executing"
echo "***"
echo ""
cd ~
curl -fsSL https://get.docker.com -o get-docker.sh
# check git commit on line 19 here https://github.com/docker/docker-install/blob/master/install.sh

echo ""
echo "***"
echo "Make sure to verify the contents of the script just you downloaded!!!"
echo "Open a new window now to verify the authenticity of the scripts"
echo "Enter Y if ready to proceed after verfying scripts, any other key to exit"
echo "***"
echo ""
read input
if [ $input != "Y" -o $input != "y" ]; then

echo ""
echo "***"
echo "Exiting now"
echo "***"
echo ""
fi

if [ $input == "Y" -o $input == "y" ]; then
echo ""
echo "***"
echo "Proceeding with install"
echo "***"
echo ""

echo ""
echo "***"
echo "Installing docker and docker-compose"
echo "***"
echo ""
sh get-docker.sh
sleep 5s
python3 -m pip install --upgrade docker-compose
sleep 5s

echo ""
echo "***"
echo "Checking docker version"
echo "***"
echo ""
docker -v
sleep 5s

echo ""
echo "***"
echo "Take a look at what PIP has installed on your system"
echo "***"
echo ""
python3 -m pip list
sleep 10s

echo ""
echo "***"
echo "Now to configuring docker to use the external SSD"
echo "***"
echo ""
echo "{ 
                  "data-root": "/mnt/usb/docker" 
}" > /etc/docker/daemon.json

echo ""
echo "***"
echo "Restarting docker"
echo "***"
echo ""
systemctl daemon-reload
systemctl start docker

echo ""
echo "***"
echo "Check that docker is using the SSD"
echo "***"
echo ""
docker info | grep "Docker Root Dir:"
sleep 5s

echo ""
echo "***"
echo "Try rebooting if you do not see your SSD listed"
echo "***"
echo ""
fi
# docker setup ends

#system setup resumes here
echo ""
echo "***"
echo "Running setup-odroid in 10 seconds"
echo "Change root password, hostname" 
echo "This tool may ask you to reboot to apply the changes once you are finished"
echo "***"
echo ""
sleep 10s
setup-odroid
#system setup ends


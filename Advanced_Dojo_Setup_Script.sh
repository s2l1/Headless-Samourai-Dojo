# Optional Convenience Script: Please note these scripts are intended for those that are using similar hardware/OS
# ALWAYS analyze scripts before downloading and running them!

# Give the script permission and run it 
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
ufw allow proto tcp from 172.28.0.0/16 to any port 8332 comment 'allow dojo to talk to external bitcoind'
ufw allow from 192.168.0.0/24 to any port 8899 comment 'allow whirlpool-gui on local network to access whirlpool-cli on Odroid'
ufw allow 28333
ufw allow 28334

echo ""
echo "***"
echo "Please check settings if you have failure after next operation"
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

# tor setup starts
echo ""
echo "***"
echo "Adding Tor Repos"
echo "***"
echo ""
echo "deb https://deb.torproject.org/torproject.org stretch main" >> /etc/apt/sources.list
echo "deb-src https://deb.torproject.org/torproject.org stretch main" >> /etc/apt/sources.list
# go to /etc/apt/sources.list to verify what repos you have added

echo ""
echo "***"
echo "Installing dirmngr, apt-transport-https, and getting torproject pgp public key"
echo "***"
echo ""
apt install dirmngr 
apt install apt-transport-https
curl https://deb.torproject.org/torproject.org/A3C4F0F979CAA22CDBA8F512EE8CBC9E886DDD89.asc | gpg --import
gpg --export A3C4F0F979CAA22CDBA8F512EE8CBC9E886DDD89 | apt-key add -
apt update

echo ""
echo "***"
echo "Installing tor, tor-arm"
echo "***"
echo ""
apt install tor
apt install tor-arm

echo ""
echo "***"
echo "Modifying the Tor configuration"
echo "***"
echo ""
sed -i '56d' /etc/tor/torrc
sed -i "56i ControlPort 9051" /etc/tor/torrc
sed -i '60d' /etc/tor/torrc
sed -i "60i CookieAuthentication 1" /etc/tor/torrc
sed -i "61i CookieAuthFileGroupReadable 1" /etc/tor/torrc
# method used with the sed command is to delete entire lines 56, 60 and add new line without a comment marker
# double check /etc/tor/torrc

echo ""
echo "***"
echo "Restarting Tor"
echo "***"
echo ""
systemctl restart tor
sleep 5s

echo ""
echo "***"
echo "Check the version of Tor and that the service is up and running"
echo "***"
echo ""
tor --version
sleep 5s
systemctl status tor
sleep 10s
# tor setup ends

# bitcoind setup starts 
mkdir ~/download
cd ~/download

echo ""
echo "***"
echo "Downloading bitoin and verifying it is authentic"
echo "***"
echo ""
wget https://bitcoincore.org/bin/bitcoin-core-0.18.1/bitcoin-0.18.1-aarch64-linux-gnu.tar.gz
wget https://bitcoincore.org/bin/bitcoin-core-0.18.1/SHA256SUMS.asc
wget https://bitcoin.org/laanwj-releases.asc
# be sure to check if this is the latest version

echo ""
echo "***"
echo "Check that the reference checksum matches the real checksum"
echo "Ignore the 'lines are improperly formatted' warning."
echo "***"
echo ""
sleep 3s
sha256sum --check SHA256SUMS.asc --ignore-missing
sleep 10s
gpg --import ./laanwj-releases.asc
gpg --refresh-keys
gpg --verify SHA256SUMS.asc

echo ""
echo "***"
echo "Using grep to to look for good signature and fingerprint"
echo "***"
echo ""
sleep 10s

gpg --verify SHA256SUMS.asc | grep 'Primary key fingerprint: 01EA 5486 DE18 A882 D4C2 6845 90C8 019E 36C2 E964'
echo ""
echo "***"
echo "Verify a good signature above"
echo "***"
echo ""
sleep 10s

echo ""
echo "***"
echo "Extracting and installing Bitcoin Core binaries"
echo "***"
echo ""
tar -xvf bitcoin-0.18.1-aarch64-linux-gnu.tar.gz
install -m 0755 -o root -g root -t /usr/local/bin bitcoin-0.18.1/bin/*

echo ""
echo "***"
echo "Checking version"
echo "***"
echo ""
bitcoind --version
sleep 5s

echo ""
echo "***"
echo "Now prepare Bitcoin Core directory"
echo "***"
echo ""

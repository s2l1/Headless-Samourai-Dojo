# Advanced Dojo Setup - Optional Convenience Script 02 
# Please note these scripts are intended for those that have similar hardware/OS and some experience
# ALWAYS analyze scripts before downloading and running them

# Give the script permission and run it when you are ready
# Use command $ chmod 555 NAME.sh
# Use command $ ./NAME.sh

# This script is for after Step 10 in the Advanced Dojo Setup guide
# The blockchain data must already be downloaded or copied over before starting bitcoind
# Check the script at line 59 before running!!!

# start validation
echo ""
echo "***"
echo "Starting bitcoind"
echo "***"
echo ""
bitcoind
sleep 10s

echo ""
echo "***"
echo "Let's check if all connections are truly routed over Tor"
echo "***"
echo ""
cat ~/.bitcoin/debug.log | grep --max-count=11 tor
cat ~/.bitcoin/debug.log | grep --max-count=3 Init
sleep 10s

echo ""
echo "***"
echo "Displaying the bitcoin network info for verification"
echo "Check the network protocols are bound to proxy 127.0.0.1:9050, which is Tor on your localhost"
echo "***"
echo ""
bitcoin-cli getnetworkinfo
sleep 20s

echo ""
echo "***"
echo "Displaying the bitcoin network info for verification"
echo "Check the network protocols are bound to proxy 127.0.0.1:9050, which is Tor on your localhost"
echo "***"
echo ""
# end validation

# pip setup starts
echo ""
echo "***"
echo "Installing the Python Package Installer and its dependencies"
echo "***"
echo ""
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

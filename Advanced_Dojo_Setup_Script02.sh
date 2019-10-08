# Optional Convenience Script - Advanced Dojo Setup
# Please note these scripts are intended for those that have similar hardware/OS and some experience
# ALWAYS analyze scripts before downloading and running them

# Give the script permission and run it when you are ready
# Use command $ chmod 555 NAME.sh
# Use command $ ./NAME.sh

# This script is for after Step 10 in the Advanced Dojo Setup guide
# The blockchain data must already be downloaded or copied over before starting bitcoind

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
python3 get-pip.py
# pip setup ends

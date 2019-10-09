# Advanced Dojo Setup - Optional Convenience Script 03
# Please note these scripts are intended for those that have similar hardware/OS and some experience
# ALWAYS analyze scripts before downloading and running them

# Give the script permission and run it when you are ready
# Use command $ chmod 555 NAME.sh
# Use command $ ./NAME.sh

# This is the final script for after Step 13 in the Advanced Dojo Setup guide
# Check that each value below is properly filled in (where XXX appears)
# Check that you have the right version of bitcoin
# Step 13 ends with a check that docker is using the SSD, and a reboot may be needed

# start dojo setup
echo ""
echo "***"
echo "Verifying bitcoind is not running. Will output an error if it is not running"
echo "***"
echo ""
sleep 5s
bitcoin-cli stop
sleep 5s

echo ""
echo "***"
echo "Downloading and extracting latest Dojo release"
echo "***"
echo ""
cd ~
curl -fsSL https://github.com/Samourai-Wallet/samourai-dojo/archive/master.zip -o master.zip
unzip master.zip
mkdir dojo_dir
cp -rv samourai-dojo-master/* dojo_dir/

echo ""
echo "***"
echo "Removing all the files we no longer need"
echo "***"
echo ""
$ rm -rvf samourai-dojo-master/ bitcoin-0.18.1/ master.zip SHA256SUMS.asc laanwj-releases.asc get-pip.py get-docker.sh bitcoin-0.18.1-aarch64-linux-gnu.tar.gz
sleep 5s

echo ""
echo "***"
echo "Editing the bitcoin docker file, goin to use the aarch64-linux-gnu.tar.gz source"
echo "***"
echo ""
sed -i '9d' ~/dojo_dir/docker/my-dojo/bitcoin/Dockerfile
sed -i '9i             ENV     BITCOIN_URL        https://bitcoincore.org/bin/bitcoin-core-0.18.1/bitcoin-0.18.1-aarch64-linux-gnu.tar.gz' ~/dojo_dir/docker/my-dojo/bitcoin/Dockerfile
sed -i '10d' ~/dojo_dir/docker/my-dojo/bitcoin/Dockerfile
sed -i '10i             ENV     BITCOIN_SHA256     88f343af72803b851c7da13874cc5525026b0b55e63e1b5e1298390c4688adc6' ~/dojo_dir/docker/my-dojo/bitcoin/Dockerfile
sleep 5s
# method used with the sed command is to delete entire lines 9, 10 and add new lines 9, 10
# double check ~/dojo_dir/docker/my-dojo/bitcoin/Dockerfile
# check that the version and hash are up to date

echo ""
echo "***"
echo "Editing mysql dockerfile to use a compatible database"
echo "***"
echo ""
sed -i '1d' ~/dojo_dir/docker/my-dojo/mysql/Dockerfile
sed -i '1i             FROM    mariadb:latest' ~/dojo_dir/docker/my-dojo/mysql/Dockerfile
sleep 5s
# method used with the sed command is to delete line 1 and add new line 1
# double check ~/dojo_dir/docker/my-dojo/mysql/Dockerfile

echo ""
echo "***"
echo "Configuring your Dojo installation by editing all 3 .conf.tpl files"
echo "***"
echo ""
# this script may be broken during updates if changes are made to the .conf.tpl files
# example is username and password are on lines 7 and 11, if that changed the sed commands would not work properly
# may need to go back and check line by line for if there is failure here, or different method

sed -i '7d' ~/dojo_dir/docker/my-dojo/conf/docker-bitcoind.conf.tpl
sed -i '7i BITCOIND_RPC_USER=XXX' ~/dojo_dir/docker/my-dojo/conf/docker-bitcoind.conf.tpl
sed -i '11d' ~/dojo_dir/docker/my-dojo/conf/docker-bitcoind.conf.tpl
sed -i '11i BITCOIND_RPC_PASSWORD=XXX' ~/dojo_dir/docker/my-dojo/conf/docker-bitcoind.conf.tpl
# replace the XXX in BITCOIND_RPC_USER=XXX and BITCOIND_RPC_PASSWORD=XXX
# method used with the sed command is to delete lines 7, 11 and add new lines 7, 11
# make it secure like any other password
# keep in mind that BITCOIND_RPC_USER and BITCOIND_RPC_PASSWORD need to match what is in the ~/.bitcoin/bitcoin.conf

sed -i '83d' ~/dojo_dir/docker/my-dojo/conf/docker-bitcoind.conf.tpl
sed -i '83i BITCOIND_INSTALL=off' ~/dojo_dir/docker/my-dojo/conf/docker-bitcoind.conf.tpl
# turns off the install of bitcoind inside docker
# method used with the sed command is to delete line 83 and add new line 83

sed -i '88d' ~/dojo_dir/docker/my-dojo/conf/docker-bitcoind.conf.tpl
sed -i '88i BITCOIND_IP=172.28.0.1' ~/dojo_dir/docker/my-dojo/conf/docker-bitcoind.conf.tpl
# Set the value of BITCOIND_IP with the IP address of you bitcoin full node which is 172.28.0.1
# IP address source - https://github.com/Samourai-Wallet/samourai-dojo/blob/develop/docker/my-dojo/docker-compose.yaml#L92
# method used with the sed command is to delete line 88 and add new line 88

sed -i '93d' ~/dojo_dir/docker/my-dojo/conf/docker-bitcoind.conf.tpl
sed -i '93i BITCOIND_RPC_PORT=8332' ~/dojo_dir/docker/my-dojo/conf/docker-bitcoind.conf.tpl
# Set the value of BITCOIND_RPC_PORT with the port used by your bitcoin full node for the RPC API (8332 default)
# method used with the sed command is to delete line 93 and add new line 93

sed -i '98d' ~/dojo_dir/docker/my-dojo/conf/docker-bitcoind.conf.tpl
sed -i '98i BITCOIND_ZMQ_RAWTXS=28333' ~/dojo_dir/docker/my-dojo/conf/docker-bitcoind.conf.tpl
sed -i '103d' ~/dojo_dir/docker/my-dojo/conf/docker-bitcoind.conf.tpl
sed -i '103i BITCOIND_ZMQ_BLK_HASH=28334' ~/dojo_dir/docker/my-dojo/conf/docker-bitcoind.conf.tpl
# Set the value of BITCOIND_ZMQ_RAWTXS with the port used by your bitcoin full node for ZMQ notifications of raw transactions
#   (i.e. port defined for -zmqpubrawtx in the bitcoin.conf of your full node)
# Set the value of BITCOIND_ZMQ_BLK_HASH with the port used by your bitcoin full node for ZMQ notifications of block hashes
#   (i.e. port defined for -zmqpubhashblock in the bitcoin.conf of your full node)
# method used with the sed command is to delete lines 98,103 and add new line 98, 103

sed -i '7d' ~/dojo_dir/docker/my-dojo/conf/docker-mysql.conf.tpl
sed -i '7i MYSQL_ROOT_PASSWORD=XXX' ~/dojo_dir/docker/my-dojo/conf/docker-mysql.conf.tpl
sed -i '11d' ~/dojo_dir/docker/my-dojo/conf/docker-mysql.conf.tpl
sed -i '11i MYSQL_USER=XXX' ~/dojo_dir/docker/my-dojo/conf/docker-mysql.conf.tpl
sed -i '15d' ~/dojo_dir/docker/my-dojo/conf/docker-mysql.conf.tpl
sed -i '15i MYSQL_PASSWORD=XXX' ~/dojo_dir/docker/my-dojo/conf/docker-mysql.conf.tpl
# replace each XXX with your desired value
# method used with the sed command is to delete lines 7, 11, 15 and add new lines 7, 11, 15

sed -i '9d' ~/dojo_dir/docker/my-dojo/conf/docker-node.conf.tpl
sed -i '9i NODE_API_KEY=XXX' ~/dojo_dir/docker/my-dojo/conf/docker-node.conf.tpl
sed -i '15d' ~/dojo_dir/docker/my-dojo/conf/docker-node.conf.tpl
sed -i '15i NODE_ADMIN_KEY=XXX' ~/dojo_dir/docker/my-dojo/conf/docker-node.conf.tpl
sed -i '21d' ~/dojo_dir/docker/my-dojo/conf/docker-node.conf.tpl
sed -i '21i NODE_JWT_SECRET=XXX' ~/dojo_dir/docker/my-dojo/conf/docker-node.conf.tpl
# replace each XXX with your desired value
# method used with the sed command is to delete lines 9, 15, 21 and add new lines 9, 15, 21

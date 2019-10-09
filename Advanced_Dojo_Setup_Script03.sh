# Advanced Dojo Setup - Optional Convenience Script 03
# Please note these scripts are intended for those that have similar hardware/OS and some experience
# ALWAYS analyze scripts before downloading and running them

# Give the script permission and run it when you are ready
# Use command $ chmod 555 NAME.sh
# Use command $ ./NAME.sh

# This is the final script for after Step 13 in the Advanced Dojo Setup guide
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
echo "Editing all 3 .conf.tpl files needed for dojo setup"
echo "***"
echo ""
# ~/dojo_dir/docker/my-dojo/conf/docker-bitcoind.conf.tpl
# ~/dojo_dir/docker/my-dojo/conf/docker-mysql.conf.tpl
# ~/dojo_dir/docker/my-dojo/conf/docker-node.conf.tpl

# bitcoind-setup script

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

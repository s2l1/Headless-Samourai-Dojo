# tor-setup script

echo ""
echo "***"
echo "Adding Tor Repos"
echo "***"
echo ""
echo "deb https://deb.torproject.org/torproject.org stretch main" >> /etc/apt/sources.list
echo "deb-src https://deb.torproject.org/torproject.org stretch main" >> /etc/apt/sources.list
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

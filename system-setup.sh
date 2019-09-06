# system-setup script

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
echo "Running setup-odroid in 10 seconds"
echo "Change root password, hostname, etc." 
echo "This tool will usually ask you to reboot to apply the changes"
echo "***"
echo ""
sleep 10s
setup-odroid

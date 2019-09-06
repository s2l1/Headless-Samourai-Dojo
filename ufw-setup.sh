# ufw-setup script

apt-get install ufw
ufw default deny incoming
ufw default allow outgoing
ufw allow from 192.168.0.0/24 to any port 22 comment 'SSH access restricted to local LAN only'
ufw allow proto tcp from 172.28.0.0/16 to any port 8332 comment 'allow dojo to talk to external bitcoind'
ufw allow from 192.168.0.0/24 to any port 8899 comment 'allow whirlpool-gui on local network to access whirlpool-cli on Odroid'
ufw allow 28333
ufw allow 28334
echo ""
echo "***"
echo "Please check your settings if you have failure after next operation"
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

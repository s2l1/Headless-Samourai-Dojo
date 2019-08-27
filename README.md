# Headless-Samourai-Dojo
**for  ODROID N2**
<sub><sup>by @GuerraMoneta</sup></sub>

This guide is for Samourai Dojo on a headless server. Samourai Dojo is the backing server for Samourai Wallet. It provides HD account, loose addresses (BIP47) balances, and transactions lists. Also provides unspent output lists to the wallet. PushTX endpoint broadcasts transactions through the backing bitcoind node. 

MyDojo is a set of Docker containers providing a full Samourai backend composed of:
* a bitcoin full node accessible as an ephemeral Tor hidden service,
* a backend database,
* a backend modules with an API accessible as a static Tor hidden service,
* a maintenance tool accessible through a Tor web browser.

This setup will be running bitcoind externally, versus leaving the default option enabled where bitcoind runs inside Dojo. I have chosen this setup which requires a little more work because it is faster than waiting for a full blockchain sync with ODROID N2. First I must say thanks to @hashamadeus @laurentmt @PuraVlda from the Dojo Telegram chat. Also thank you to @stadicus and Burcak Baskan for the Raspibolt guide and the Dojo Pi4 guide. This is a compiled trial and error effort of myself trying to chop together guides, and a lot of help from the Dojo chat. 
```
Sources:
Dojo Docs - https://github.com/Samourai-Wallet/samourai-dojo/blob/master/doc/DOCKER_setup.md#first-time-setup
Advanced Setups - https://github.com/Samourai-Wallet/samourai-dojo/blob/master/doc/DOCKER_advanced_setups.md
Raspibolt - https://stadicus.github.io/RaspiBolt/
Pi 4 Dojo Guide - https://burcak-baskan.gitbook.io/workspace/
```
**NEWBIE TIPS:** Each command has $ before it, and the outputs of the command are marked > to avoid confusion. # is a comment. Do not enter these as part of a command. If you are not sure about commands, stuck, learning, etc. try visiting the information links and doing the Optional Reading. Look up terms that you do not know. The Dojo Telegram chat is also very active and helpful. I am trying my best to educate anyone new throughout this guide. 


## 1. [HARDWARE REQUIREMENTS]
- https://forum.odroid.com/viewtopic.php?f=176&t=33781
I am using this with a 500gb Samsung Portable SSD + USB3.0 and SD card. I reccommend quality SD card. I am also using hardline internet connection. You will need a Windows / Linux / Mac with good specs that is on the same network as the ODROID. Before this I have tried to get running on a Pi3b+ but had a problem. Hypothesis for problem "nodejs can communicate with bitcoind but it doesn't get a response fast enough." If you get Dojo running on Pi3b+ please contact or post a guide.


## 2. [OPERATING SYSTEM]
- https://forum.odroid.com/viewtopic.php?f=179&t=33865
By meveric » Tue Feb 19, 2019 8:29 AM: This is the first version of my Debian Stretch image for the ODROID N2. It is uses the 4.9 LTS Kernel from Hardkernel. It's a headless server image only with user root. It has all my repositories included, which allows for easy installation and updates of packages such as Kernel and Headers and other packages. The image has my usual setup: means on first boot it's resizing the rootfs partition and configures SSH. It will automatically reboot after the initial setup after which this image is ready to use. Kernel and headers are already installed if you need to build your own drivers. A few basic tools such as htop, mc, vim and bash-completion are already installed.
```
DOWNLOAD: https://oph.mdrjr.net/meveric/images/Stretch/Debian-Stretch64-1.0.1-20190519-N2.img.xz 
MD5: https://oph.mdrjr.net/meveric/images/Stretch/Debian-Stretch64-1.0.1-20190519-N2.img.xz.md5
SHA512: https://oph.mdrjr.net/meveric/images/Stretch/Debian-Stretch64-1.0.1-20190519-N2.img.xz.sha512
SIG: https://oph.mdrjr.net/meveric/images/Stretch/Debian-Stretch64-1.0.1-20190519-N2.img.xz.sig

MIRROR: http://fuzon.co.uk/meveric/images/Stretch/Debian-Stretch64-1.0.1-20190519-N2.img.xz
MD5: http://fuzon.co.uk/meveric/images/Stretch/Debian-Stretch64-1.0.1-20190519-N2.img.xz.md5
SHA512: http://fuzon.co.uk/meveric/images/Stretch/Debian-Stretch64-1.0.1-20190519-N2.img.xz.sha512
SIG: http://fuzon.co.uk/meveric/images/Stretch/Debian-Stretch64-1.0.1-20190519-N2.img.xz.sig
```
Use the md5, sha512, sig, files to check that the .img is authentic. Do not trust, verify! If you are not sure please look up “md5 to verify software” and “gpg to verify software.” Please take some time to learn. Watch this entire playlist below if you are a newbie.
```
Size compressed: 113MB
Size uncompressed: 897 MB

Default Login: root
Default Password: odroid

Newbie Playlist: 
https://www.youtube.com/watch?v=plUQ3ZRBL54&list=PLmoQ11MXEmajkNPMvmc8OEeZ0zxOKbGRa

Optional Reading: https://www.dewinter.com/gnupg_howto/english/GPGMiniHowto-3.html
Optional Reading: https://www.lifewire.com/validate-md5-checksum-file-4037391 
```
It's ready to be used as a server image. Flash the image on to an SD card and boot up. Give the ODROID some time. As mentioned by meveric above "it will automatically reboot" then it is ready for use.


## 3. [BLOCKCHAIN DATA]

The Bitcoin blockchain records all transactions and basically defines who owns how many bitcoin. This is the most crucial of all information and we should not rely on someone else to provide this data. To set up our Bitcoin Full Node on mainnet, we need to download the whole blockchain (~ 250 GB), verify every Bitcoin transaction that ever occurred, every block ever mined, create an index database for all transactions, so that we can query it later on, calculate all bitcoin address balances (called the UTXO set). Look up Running a Full Node for additional information.

The ODROID is up to the big task of downloading the blockchain so you may wonder why we are downloading on a faster machine, and copying over the data. The download is not the problem, but to initially process the whole blockchain would take a long time due to its computing power and memory. We need to download and verify the blockchain with Bitcoin Core on your regular computer, and then transfer the data to the ODROID. This needs to be done only once. After that the ODROID can easily keep up with new blocks.

This guide assumes that you will use a Windows machine for this task, but it works with most operating systems. You need to have about 250 GB free disk space available, internally or on an external hard disk (but not the SSD reserved for the ODROID). As indexing creates heavy read/write traffic, the faster your hard disk the better. 

Using SCP, we will copy the blockchain from the Windows computer over the local network later in this guide.

For now download the Bitcoin Core installer from bitcoincore.org and store it in the directory you want to use to download the blockchain. To check the authenticity of the program, we calculate its checksum and compare it with the checksums provided.

In Windows, I’ll preface all commands you need to enter with $, so with the command $ cd bitcoin just type cd bitcoin and hit enter.

Open the Windows command prompt (Start Menu and type cmd directly and hit Enter), navigate to the bitcoin directory (for me, it’s on drive C:, check in Windows Explorer) and create the new directory bitcoin_mainnet. Then calculate the checksum of the already downloaded program.
```
$ cd C:\bitcoin
$ mkdir bitcoin_mainnet
$ dir
$ certutil -hashfile bitcoin-0.18.1-win64-setup.exe sha256
>3bac0674c0786689167be2b9f35d2d6e91d5477dee11de753fe3b6e22b93d47c
```
Check this hash 3bac067... against the file SHA256SUMS.asc once you are on step #9 of this guide to verify that it is authentic.

## 4. [NETWORK]

!!!ADD PORTFORWARD 8333 FOR MAINNET!!!

The ODROID got a new IP address from your home network. This address can change over time. To make the ODROID reachable from the internet, we assign it a fixed address.

The fixed address is configured in your network router, this can be the cable modem or the Wifi access point. So we first need to access the router. To find out your routers address start the Command Prompt on a computer that is connected to your home network. 
```
#Windows:
#Open Start Menu and type cmd directly and hit Enter
$ ipconfig

#Linux/Mac:
#Open Terminal
$ ifconfig

#look for “Default Gateway” and note the address (eg. “192.168.0.1”)
```
Now open your web browser and access your router by entering the address, like a regular web address. You need to sign in, and now you can look up all network clients in your home network. Your ODROID should be listed here, together with its IP address (eg. “192.168.0.240”).

We now need to set the fixed (static) IP address for the ODROID. Normally, you can find this setting under “DHCP server”. The manual address should be the same as the current address, just change the last part to a lower number (e.g. 192.168.0.240 → 192.168.0.20).

Apply changes. 


## 5. [SSH]

Take note of the of your ODROID's static IP address on your local network. 

Go ahead and SSH into your ODROID by opening terminal on any Linux machine connected to your local network.
```
#Windows: 
#Download - https://www.putty.org/
Enter the ODROID IP and password to connect. 

#In Linux Terminal:
$ ssh root@IP.OF.ODROID.HERE
#Example: root@192.168.0.5
>Enter password:
```
Now you are connected to your ODROID and can use the terminal. 
```
Optional Reading: https://www.raspberrypi.org/documentation/installation/installing-images/
Optional Reading: https://www.raspberrypi.org/magpi/back-up-raspberry-pi/
```

## 6. [SYSTEM SETUP]

There's constantly new development for this image and ODROIDs in general. The first thing you should do after the image is up and running is to install all updates.

`$ apt update && apt upgrade && apt dist-upgrade`

Setup tool can be accessed by using the following command.

`$ setup-odroid`

Here you can change root password, hostname, etc. This tool will usually ask you to reboot to apply the changes.

Set your timezone.

`$ dpkg-reconfigure tzdata`

Install fail2ban.

`$ apt-get install fail2ban curl`

Mount external hard disk. Use ext4 format NTFS will not work! See below.
```
Optional Reading - https://stadicus.github.io/RaspiBolt/raspibolt_20_pi.html#mounting-external-hard-disk 
Optional Reading - https://stadicus.github.io/RaspiBolt/raspibolt_20_pi.html#moving-the-swap-file
```


## 7. [UFW] Uncomplicated Firewall.

Enable the Uncomplicated Firewall which controls what traffic is permitted and closes possible security holes. 

The line "ufw allow from 192.168.0.0/24…" below assumes that the IP address of your ODROID is something like 192.168.0.???, the ??? being any number from 0 to 255. If your IP address is 12.34.56.78, you must adapt this line to "ufw allow from 12.34.56.0/24…"
```
$ apt-get install ufw
$ ufw default deny incoming
$ ufw default allow outgoing
$ ufw allow from 192.168.0.0/24 to any port 22 comment 'SSH access restricted to local LAN'
$ ufw enable
$ systemctl enable ufw
$ ufw status
$ exit
```
```
Optional Reading: Connecting to the Network - https://stadicus.github.io/RaspiBolt/raspibolt_20_pi.html#connecting-to-the-network
Optional Reading:  Connecting to ODROID - https://stadicus.github.io/RaspiBolt/raspibolt_20_pi.html#connecting-to-the-pi
Optional Reading:  Access restricted for local LAN - https://stadicus.github.io/RaspiBolt/raspibolt_20_pi.html#enabling-the-uncomplicated-firewall
Optional Reading: Login with SSH keys - https://stadicus.github.io/RaspiBolt/raspibolt_20_pi.html#login-with-ssh-keys
```


## 8. [TOR]

Why run Tor?

Tor is mainly useful as a way to impede traffic analysis, which means analyzing your internet activity (logging your IP address on websites you’re browsing and services you’re using) to learn about you and your interests. Traffic analysis is useful for advertisement and you might want to hide this kind of information merely out of privacy concerns. But it might also be used by outright malevolent actors, criminals or governments to harm you in a lot of possible ways.

Tor allows you to share data on the internet without revealing your location or identity, which can definitely be useful when running a Bitcoin node.

Out of all the reasons why you should run Tor, here are the most relevant to Bitcoin.

By exposing your home IP address with your node, you are literally saying the whole planet “in this home we run a node”. That’s only one short step from “in this home, we do have bitcoins”, which could potentially turn you and your loved ones into a target for thieves. In the eventuality of a full fledged ban and crackdown on Bitcoin owners in the country where you live, you will be an obvious target for law enforcement. Coupled with other privacy methods like CoinJoin you can gain more privacy for your transactions, as it eliminates the risk of someone being able to snoop on your node traffic, analyze which transactions you relay and try to figure out which UTXOs are yours, for example.

All the above mentioned arguments are also relevant when using Lightning, as someone that sees a Lightning node running on your home IP address could easily infer that there’s a Bitcoin node at the same location.

If you run a different operating system, you may need to build Tor from source and paths may vary. For additional reference, the original instructions are available on the Tor project website.

Add the following two lines to sources.list to add the torproject repository.

`$ nano /etc/apt/sources.list`
```
deb https://deb.torproject.org/torproject.org stretch main
deb-src https://deb.torproject.org/torproject.org stretch main
```
In order to verify the integrity of the Tor files, download and add the signing keys of the torproject using the network certificate management service (dirmngr).
```
$ apt install dirmngr apt-transport-https
$ curl https://deb.torproject.org/torproject.org/A3C4F0F979CAA22CDBA8F512EE8CBC9E886DDD89.asc | gpg --import
$ gpg --export A3C4F0F979CAA22CDBA8F512EE8CBC9E886DDD89 | sudo apt-key add -
```
The latest version of Tor can now be installed. While not required, tor-arm provides a dashboard that you might find useful.

`$ apt update`

`$ apt install tor tor-arm`

Check the version of Tor and that the service is up and running.
```
$ tor --version
> Tor version 0.3.4.9 (git-074ca2e0054fded1).
$ systemctl status tor
```
Modify the Tor configuration by uncommenting (removing the #) or adding the following lines.
`$ nano /etc/tor/torrc`
```
# uncomment:
ControlPort 9051
CookieAuthentication 1

# add:
CookieAuthFileGroupReadable 1
```
Restart Tor to activate modifications.

`$ systemctl restart tor`


# 9. [BITCOIN]

Now download the software directly from bitcoin.org to your ODROID, verify its signature to make sure that we use an official release, and then install it.
```
$ mkdir ~/download
$ cd ~/download
```
We download the latest Bitcoin Core binaries (the application) and compare the file with the signed checksum. This is a precaution to make sure that this is an official release and not a malicious version trying to steal our money.

Get the latest download links at bitcoincore.org/en/download (ARM Linux 64 Bit), they change with each update. Then run the following commands (with adjusted filenames where needed).
```
# download Bitcoin Core binary

$ wget https://bitcoincore.org/bin/bitcoin-core-0.18.1/bitcoin-0.18.1-aarch64-linux-gnu.tar.gz
$ wget https://bitcoincore.org/bin/bitcoin-core-0.18.1/SHA256SUMS.asc
$ wget https://bitcoin.org/laanwj-releases.asc
```
Check that the reference checksum matches the real checksum. 
Ignore the "lines are improperly formatted" warning.
```
$ sha256sum --check SHA256SUMS.asc --ignore-missing
> bitcoin-0.18.1-aarch64-linux-gnu.tar.gz: OK
```
Import the public key of Wladimir van der Laan, verify the signed  checksum file.  Check the fingerprint again in case of malicious keys.
```
$ gpg --import ./laanwj-releases.asc
$ gpg --refresh-keys
$ gpg --verify SHA256SUMS.asc
> gpg: Good signature from "Wladimir J. van der Laan ..."
> Primary key fingerprint: 01EA 5486 DE18 A882 D4C2 6845 90C8 019E 36C2 E964
```
Now we know that the keys from bitcoin.org are valid. Extract the Bitcoin Core binaries, install them and check the version.
```
tar -xvf bitcoin-0.18.1-aarch64-linux-gnu.tar.gz
$ sudo install -m 0755 -o root -g root -t /usr/local/bin bitcoin-0.18.1/bin/*
$ bitcoind --version
> Bitcoin Core Daemon version v0.18.1
```
Now prepare Bitcoin Core directory.

We use the Bitcoin daemon, called “bitcoind”, that runs in the background without user interface and stores all data in a the directory ~/.bitcoin. Instead of creating a real directory, we create a link that points to a directory on the external hard disk.

We add a symbolic link that points to the SSD hard disk.

`$ ln -s /TYPE_DESIRED_SSD_PATH_HERE/bitcoin ~/.bitcoin`

Navigate to the home directory an d check the symbolic link (the target must not be red). The content of this directory will actually be on the external hard disk.

`$ ls -la`

Now, the configuration file for bitcoind needs to be created. Open it with Nano and paste the configuration below. Save and exit.

`$ nano ~/.bitcoin/bitcoin.conf`

```
# bitcoind configuration
# ~/.bitcoin/bitcoin.conf

rpcbind=127.0.0.1 (needed for other services running on nodl)
rpcbind=10.0.1.95 (local ip of where bitcoind is)
rpcport=8332(port used to access rpc)
rpcuser=xxxxxxxx(username for rpc access)
rpcpassword=xxxxxx(password for rpc access)
rpcallowip=127.0.0.1(may not be but was there already so left)
rpcallowip=10.0.1.2 (local ip of where Dojo is)
rpcallowip=192.168.65.0/24 (needed this specifically with Mac as Docker container uses local IP inside)

txindex=1 (builds bitcoin transaction index)

zmqpubhashblock=tcp://0.0.0.0:29000 (no idea what any of these mean). Needed per Dojo guides
zmqpubrawblock=tcp://0.0.0.0:29000 (existing from nodl for services)
zmqpubrawtx=tcp://0.0.0.0:29001 (same)

$ sudo nano /home/bitcoin/.bitcoin/bitcoin.conf
# add / change:
proxy=127.0.0.1:9050
bind=127.0.0.1
listenonion=1
```
Let’s start “bitcoind” manually. Monitor the log file a few minutes to see if it works fine It may stop at “dnsseed thread exit”, that’s ok. Exit the logfile monitoring with Ctrl-C, check the blockchain info, if there are no errors, then stop “bitcoind” again.
```
$ bitcoind
$ tail -f ~/bitcoin/.bitcoin/debug.log
$ bitcoin-cli getblockchaininfo
$ bitcoin-cli stop
```
Right at the beginning, however, we started downloading the Bitcoin mainnet blockchain on your regular computer. Check the verification progress directly in Bitcoin Core on this computer. To proceed, it should be fully synced (see status bar).

As soon as the verification is finished, shut down Bitcoin Core on Windows. We will now copy the whole data structure to the ODROID. This takes about 6 hours.


## 10. [COPY]

We are using “Secure Copy” (SCP), so download and install WinSCP, a free open-source program.

With WinSCP, you can now connect to your ODROID.

Accept the server certificate and navigate to the local and remote bitcoin directories:
```
Local: C:\bitcoin\bitcoin_mainnet\
Remote: PATH_TO_SSD\bitcoin\
```
You can now copy the two subdirectories (folders) named blocks and chainstate from Local to Remote. This will take about 6 hours. The transfer must not be interupted. Make sure your computer does not go to sleep.

!!!ADD LINUX INSTRUCTIONS HERE!!!

## 11. [AUTOSTART BITCOIND]


The system needs to run the bitcoin daemon automatically in the background, even when nobody is logged in. We use “systemd“, a daemon that controls the startup process using configuration files.

Create the configuration file in the Nano text editor and copy the following paragraph.

`$ nano /etc/systemd/system/bitcoind.service`

```
# systemd unit for bitcoind
# /etc/systemd/system/bitcoind.service

[Unit]
Description=Bitcoin daemon
After=network.target

[Service]
ExecStartPre=/bin/sh -c 'sleep 30'
ExecStart=/usr/local/bin/bitcoind -daemon -conf=~/.bitcoin/bitcoin.conf -pid=~/.bitcoin/bitcoind.pid
PIDFile=/home/bitcoin/.bitcoin/bitcoind.pid
User=bitcoin
Group=bitcoin
Type=forking
KillMode=process
Restart=always
TimeoutSec=120
RestartSec=30

[Install]
WantedBy=multi-user.target
```
Save and exit.

Enable the configuration file.

`$ systemctl enable bitcoind.service`

Restart the ODROID

`$ shutdown -r now`

After rebooting, the bitcoind should start and begin to sync and validate the Bitcoin blockchain. 

Wait a bit, reconnect via SSH.

Check the status of the bitcoin daemon that was started by systemd (exit with Ctrl-C).

`$ systemctl status bitcoind.service`

Use the Bitcoin Core client bitcoin-cli to get information about the current blockchain

`$ bitcoin-cli getblockchaininfo`

See bitcoind in action by monitoring its log file (exit with Ctrl-C)

`$ tail -f ~/.bitcoin/debug.log`

When “bitcoind” is still starting, you may get an error message like “verifying blocks”. That’s normal, just give it a few minutes. Among other infos, the “verificationprogress” is shown. Once this value reaches almost 1 (0.999…), the blockchain is up-to-date and fully validated.

If everything is running smoothly, this is the perfect time to familiarize yourself with Bitcoin Core, try some bitcoin-cli commands, and do some reading or videos until the blockchain is up-to-date.

A great point to start is the book Mastering Bitcoin by Andreas Antonopoulos which is open source.

## 12. [VALIDATION]

We now need to check if all connections are truly routed over Tor.

Verify operations in the debug.log file. You should see your onion address after about one minute.
```
$ tail ~/bitcoin/.bitcoin/debug.log -f -n 200

> InitParameterInteraction: parameter interaction: -proxy set -> setting -upnp=0
> InitParameterInteraction: parameter interaction: -proxy set -> setting -discover=0
...
> torcontrol thread start
...
> tor: Got service ID [YOUR_ID] advertising service [YOUR_ID].onion:8333
> addlocal([YOUR_ID].onion:8333,4)
```
Use CTRL + C to exit logs.

Display the Bitcoin network info to verify that the different network protocols are bound to proxy 127.0.0.1:9050, which is Tor on your localhost. Note the onion network is now reachable: true.

`$ bitcoin-cli getnetworkinfo`


## 13. [PIP] 

Install the Python Package Installer. Change to the home directory of the root user.

`$ cd ~`

`$ apt-get install python3-dev libffi-dev libssl-dev build-essential`

**TIP:** You will also need these libs if you wanted to install bitcoind standalone. Useful to have them in the system. Also python 2 is end of life so we are using python3.

`Optional Reading - https://pip.pypa.io/en/stable/installing/`

To install pip, securely download get-pip.py. “Secure” in this context means using a modern browser or a tool like curl that verifies SSL certificates when downloading from https URLs.

`$ curl https://bootstrap.pypa.io/get-pip.py -o get-pip.py`

Then run the following.

`$ python3 get-pip.py`


## 14. [DOCKER]

Use pip to install docker-compose, apt-get can install an old version. Better to use the docker-compose install instructions which you can look at in Optional Reading. I will walk you through the pip install approach, there are a few ways to install the latest version.

`$ python3 -m pip install --upgrade docker-compose`

`Optional Reading - https://docs.docker.com/compose/install/`

Now check your docker version. An old version can cause problems.

`$ docker -v`

Take a look at what PIP has installed on your system.

`$ python3 -m pip list`

Now to configure docker to use the external SSD. Create a new file in text editor. 

`$ nano /etc/docker/daemon.json`

Add the following 3 lines.
```
{ 
                  "data-root": "/PATH_TO_SSD/docker" 
} 
```
Save and exit Nano text editor.

Restart docker to accept changes.

`$ systemctl daemon-reload`

`$ systemctl start docker`

Check that docker is using the SSD.
```
$ docker info | grep "Docker Root Dir:" 
> "data-root": "/PATH_TO_SSD/docker/"
```
Try rebooting if you do not see your external SSD listed.

`$ shutdown -r now`


## 15. [DOJO] Download and unzip latest Dojo release.

```
$ cd ~
$ curl -fsSL https://github.com/Samourai-Wallet/samourai-dojo/archive/master.zip -o master.zip
$ unzip master.zip
```
Create a directory for Dojo (named dojo_dir in this doc)

`$ mkdir dojo_dir`

Copy samourai-dojo-master directory contents to dojo_dir directory. 

`$ cp -rv samourai-dojo-master/* dojo_dir/`

Remove what will no longer be used.

`$ rm -rvf samourai-dojo-master/ master.zip`

Open Bitcoin Dockerfile in text editor. We are going to use the "aarch64-linux-gnu.tar.gz" source.

`$ nano ~/dojo_dir/docker/my-dojo/bitcoin/Dockerfile`
```
         #Change line #9 to: 
            ENV     BITCOIN_URL        https://bitcoincore.org/bin/bitcoin-core-0.18.1/bitcoin-0.18.1-aarch64-linux-gnu.tar.gz

         #Change line #10 to:
            ENV     BITCOIN_SHA256     88f343af72803b851c7da13874cc5525026b0b55e63e1b5e1298390c4688adc6
```
Edit mysql Dockerfile to use a compatible database.

`$ nano ~/dojo_dir/docker/my-dojo/mysql/Dockerfile`
```
         #Change line #1 to:
            FROM    mariadb:latest
```
Go to the ~/dojo_dir/docker/my-dojo/conf directory.

Configure your dojo installation by editing all 3 .conf.tpl files.

`$ nano docker-bitcoind.conf.tpl`
```
BITCOIND_RPC_USER = login protecting the access to the RPC API of your full node,
BITCOIND_RPC_PASSWORD = password protecting the access to the RPC API of your full node.
If your machine has a lot of RAM, it's recommended that you increase the value of BITCOIND_DB_CACHE for a faster Initial Block Download. This file also provides a few additional settings for advanced setups like static onion address for your full node, bitcoind RPC API exposed to external apps, use of an external full node.
```
`$ nano docker-mysql.conf.tpl`
```
Edit docker-mysql.conf.tpl and provide a new value for the following parameters:
MYSQL_ROOT_PASSWORD = password protecting the root account of MySQL,
MYSQL_USER = login of the account used to access the database of your Dojo,
MYSQL_PASSWORD = password of the account used to access the database of your Dojo.
```
`$ nano docker-node.conf.tpl`
```
Edit docker-node.conf.tpl and provide a new value for the following parameters:
NODE_API_KEY = API key which will be required from your Samourai Wallet / Sentinel for its interactions with the API of your Dojo,
NODE_ADMIN_KEY = API key which will be required from the maintenance tool for accessing a set of advanced features provided by the API of your Dojo,
NODE_JWT_SECRET = secret used by your Dojo for the initialization of a cryptographic key signing Json Web Tokens. These parameters will protect the access to your Dojo. Be sure to provide alphanumeric values with enough entropy.
```
Open the docker quickstart terminal or a terminal console and go to the ~/dojo_dir/docker/my-dojo directory. This directory contains a script named dojo.sh which will be your entrypoint for all operations related to the management of your Dojo.
```
$ cd ~/dojo_dir/docker/my-dojo
$ ./dojo.sh install
```
After successful install the following command should show containers as up.

`$ docker-compose ps`

`./dojo.sh logs bitcoind`
`./dojo.sh logs tor`

ADD END: SSH Key Login https://stadicus.github.io/RaspiBolt/raspibolt_20_pi.html#login-with-ssh-keys

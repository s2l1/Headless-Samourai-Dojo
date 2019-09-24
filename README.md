# Introduction
**for  ODROID N2**
<sub><sup>by @GuerraMoneta</sup></sub>

Check out `https://github.com/s2l1/Headless-Samourai-Dojo/wiki` for a better format of this guide!

Want to ask questions, troubleshoot, contribute, or just chat about Dojo? Check out `https://t.me/samourai_dojo`.

First I must say thanks to @hashamadeus @laurentmt @PuraVlda from Dojo Telegram chat. Also thanks to @stadicus and Burcak Baskan for the Raspibolt guide and the Dojo Pi4 guide. 

Looking to run a full node that can interact with a mobile wallet over Tor 24/7? Don't want to leave some dusty old laptop running in the corner with wires hanging about? This guide is for Samourai Dojo on a headless server. Samourai Dojo is the backing server for Samourai Wallet. It provides HD account, loose addresses (BIP47) balances, and transactions lists. Also provides unspent output lists to the wallet. PushTX endpoint broadcasts transactions through the backing bitcoind node. 

MyDojo is a set of Docker containers providing a full Samourai backend composed of:
* a bitcoin full node accessible as an ephemeral Tor hidden service
* a backend database
* a backend modules with an API accessible as a static Tor hidden service
* a maintenance tool accessible through a Tor web browser

This setup will be running bitcoind externally, which is a little bit more advanced, versus leaving the default option enabled where bitcoind will run inside Docker. I have chosen this setup because it is faster than waiting for a full blockchain sync with ODROID N2. If you have experience this deployment should take around 8 hours. 

If you have some spare time please make a github account and edit this guide. You can also fork the guide to your own version, maybe for a purpose such as adding more detailed notes, or perhaps for making more drastic changes like a different method of deployment. It was a community effort that helped me bring this guide together, and it may take the same effort to keep this guide polished and up to date.  Feel free to revise things, make suggestions, update versions, et cetera. Thank you!
 
# Table of Contents
* [**HARDWARE REQUIREMENTS**](https://github.com/s2l1/Headless-Samourai-Dojo/blob/master/README.md#1-hardware-requirements) 
* [**OPERATING SYSTEM**](https://github.com/s2l1/Headless-Samourai-Dojo/blob/master/README.md#2-operating-system)
* [**BLOCKCHAIN DATA**](https://github.com/s2l1/Headless-Samourai-Dojo/blob/master/README.md#3-blockchain-data)
* [**NETWORK**](https://github.com/s2l1/Headless-Samourai-Dojo/blob/master/README.md#4-network)
* [**SSH**](https://github.com/s2l1/Headless-Samourai-Dojo/blob/master/README.md#5-ssh)
* [**SYSTEM SETUP**](https://github.com/s2l1/Headless-Samourai-Dojo/blob/master/README.md#6-system-setup)
* [**UFW**](https://github.com/s2l1/Headless-Samourai-Dojo/blob/master/README.md#7-ufw)
* [**TOR**](https://github.com/s2l1/Headless-Samourai-Dojo/blob/master/README.md#8-tor)
* [**BITCOIN**](https://github.com/s2l1/Headless-Samourai-Dojo/blob/master/README.md#9-bitcoin)
* [**SCP**](https://github.com/s2l1/Headless-Samourai-Dojo/blob/master/README.md#10-scp)
* [**VALIDATION**](https://github.com/s2l1/Headless-Samourai-Dojo/blob/master/README.md#11-validation)
* [**PIP**](https://github.com/s2l1/Headless-Samourai-Dojo/blob/master/README.md#12-pip)
* [**DOCKER**](https://github.com/s2l1/Headless-Samourai-Dojo/blob/master/README.md#13-docker)
* [**DOJO**](https://github.com/s2l1/Headless-Samourai-Dojo/blob/master/README.md#14-dojo)
* [**PAIRING WALLET WITH DOJO**](https://github.com/s2l1/Headless-Samourai-Dojo/blob/master/README.md#15-pairing-wallet-with-dojo)

```
# Don't want to bother with this advanced setup?
# Looking for some guides for other OS, hardware, etc?
# Check out what the community is up to!


A few sources:
Dojo Docs - https://github.com/Samourai-Wallet/samourai-dojo/blob/master/doc/DOCKER_setup.md#first-time-setup
Advanced Setups - https://github.com/Samourai-Wallet/samourai-dojo/blob/master/doc/DOCKER_advanced_setups.md
Raspibolt - https://stadicus.github.io/RaspiBolt/
Pi 4 Dojo Guide - https://burcak-baskan.gitbook.io/workspace/
```

**NEWBIE TIPS:** Each command has $ before it, and the outputs of the command are marked > to avoid confusion. # is a comment. Do not enter these as part of a command. If you are not sure about commands, stuck, learning, etc. try visiting the information links and doing the Optional Reading. Look up terms that you do not know. The Dojo Telegram chat is also very active and helpful. I am trying my best to educate anyone new throughout this guide. 


## 1. [HARDWARE REQUIREMENTS]
- https://forum.odroid.com/viewtopic.php?f=176&t=33781
You will need an ODROID N2 with a hard plastic case. I am using this with a 500gb Samsung Portable SSD, USB3.0, hardline ethernet connection, and SD card. Add a battery back up later on to be sure your ODROID wont lose power during bad weather. You will also need a Windows / Linux / Mac with good specs that is on the same network as the ODROID. This setup will take up about as much room as a standard home router/modem and look clean clean once finished.

Before this I have tried to get running on a Pi3b+ but had a problem. Hypothesis for problem "nodejs can communicate with bitcoind but it doesn't get a response fast enough." If you get Dojo running on Pi3b+ please contact or post a guide to the Dojo community.


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

PGP PUBLIC KEY: https://oph.mdrjr.net/meveric/meveric.asc
```
Use the md5, sha512, sig, and the PGP public key to check that the Debian `.img.xz` you have downloaded is authentic. Do not trust, verify! If you are not sure on this please look up “md5 to verify software” and “gpg to verify software.” Please take some time to learn as this is used to verify things often. Watch the entire playlist below if you are a newbie and work on getting comfotable using the cmd or terminal.
```
Size compressed: 113MB
Size uncompressed: 897 MB

Default Login: root
Default Password: odroid

Newbie Playlist: 
https://www.youtube.com/watch?v=plUQ3ZRBL54&list=PLmoQ11MXEmajkNPMvmc8OEeZ0zxOKbGRa

Optional Reading: How To gpg - https://www.dewinter.com/gnupg_howto/english/GPGMiniHowto-3.html
Optional Reading: How To md5 - https://www.lifewire.com/validate-md5-checksum-file-4037391 
```
It's ready to be used as a server image. Flash the image on to an SD card and boot up. Give the ODROID some time. As mentioned by meveric above "it will automatically reboot" then it is ready for use.


## 3. [BLOCKCHAIN DATA]

The Bitcoin blockchain records all transactions and basically defines who owns how many bitcoin. This is the most crucial of all information and we should not rely on someone else to provide this data. To set up our Bitcoin Full Node on mainnet, we need to download the whole blockchain (~ 250 GB), verify every Bitcoin transaction that ever occurred, every block ever mined, create an index database for all transactions, so that we can query it later on, calculate all bitcoin address balances (called the UTXO set). Look up "running a bitcoin full node" for additional information.

The ODROID is up to the big task of downloading the blockchain so you may wonder why we are downloading on a faster machine, and copying over the data. The download is not the problem, but to initially process the whole blockchain would take a long time due to its computing power and memory. We need to download and verify the blockchain with Bitcoin Core on your regular computer, and then transfer the data to the ODROID. This needs to be done only once. After that the ODROID can easily keep up with new blocks.

This guide assumes that many will use a Windows machine, but it works with most operating systems. I have done my best to provide linux/max instructions where possible. You need to have about 250 GB free disk space available, internally or on an external hard disk (but not the SSD reserved for the ODROID). As indexing creates heavy read/write traffic, the faster your hard disk the better. If you are using linux as a main machine I will assume that you are comfortable lookup up how to download Bitcoin Core.

Using SCP, we will copy the blockchain from the Windows computer over the local network later in this guide.

For now download the Bitcoin Core installer from bitcoincore.org and store it in the directory you want to use to download the blockchain. To check the authenticity of the program, we calculate its checksum and compare it with the checksums provided.

In Windows, I’ll preface all commands you need to enter with $, so with the command $ cd bitcoin just type cd bitcoin and hit enter.

Open the Windows command prompt (Start Menu and type cmd directly and hit Enter), navigate to the directory where you downloaded bitcoin setup.exe file. For me, it’s `C:\Users\USERNAME\Desktop` but you can double check in Windows Explorer. Then use certutil calculate the checksum of the already downloaded program.
```
$ cd C:\Users\USERNAME\Desktop
$ mkdir bitcoin_mainnet
$ dir
$ certutil -hashfile bitcoin-0.18.1-win64-setup.exe sha256
>3bac0674c0786689167be2b9f35d2d6e91d5477dee11de753fe3b6e22b93d47c
```
Save and later on check this hash 3bac067... against the file SHA256SUMS.asc once you are on step #9 of this guide to verify that it is authentic.

Open Bitcoin Core and leave it to sync.


## 4. [NETWORK]

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

If you have not changed your router login password from the default, please do so now. 

Apply and log out of your router. 

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
Optional Reading: Installing Images - https://www.raspberrypi.org/documentation/installation/installing-images/
Optional Reading: Backup - https://www.raspberrypi.org/magpi/back-up-raspberry-pi/
```


## 6. [SYSTEM SETUP]

There's constantly new development for this image and ODROIDs in general. The first thing you should do after the image is up and running is to install all updates and a few things needed later on in the guide.

`$ apt-get update && apt-get upgrade && apt-get dist-upgrade`

Install fail2ban, curl, and unzip.

`$ apt-get install fail2ban git curl unzip net-tools`

Setup tool can be accessed by using the following command.

`$ setup-odroid`

Here you can change root password, hostname, etc. This tool will usually ask you to reboot to apply the changes.
```
# Optional Convenience Script: Please note these scripts are intended for those that are using similar hardware/OS 
# ALWAYS analyze scripts before running them!
$ wget https://github.com/s2l1/Headless-Samourai-Dojo/raw/master/system-setup.sh
$ chmod 555 system-setup.sh
$ ./system-setup.sh
```
Set your timezone.

`$ dpkg-reconfigure tzdata`

Now we will format the hard disk, erasing all previous data. The external SSD is then attached to the file system and can be accessed as a regular folder (this is called mounting). We will use ext4 format, NTFS will not work.

Make sure your SSD is plugged in. Get the NAME for main partition on the external hard disk

`$ lsblk -o UUID,NAME,FSTYPE,SIZE,LABEL,MODEL`

Format the external hard disk with Ext4. Use `NAMEHERE` from above, e.g `/dev/sda1`.

`$ mkfs.ext4 /dev/NAMEHERE`

Copy the UUID that is provided as a result of this format command to your notepad.

Edit the fstab file and the following as a new line (replace UUID=123456) at the end.

`$ nano /etc/fstab`

`UUID=123456 /mnt/usb ext4 rw,nosuid,dev,noexec,noatime,nodiratime,auto,nouser,async,nofail 0 2`

Create the directory to add the hard disk and set the correct owner. Here we will use `/mnt/usb` as an example.
`$ mkdir /mnt/usb`

**NEWBIE TIPS:** `/mnt/usb/` is simply my desired path, and you can choose any path you want for the mounting of your SSD. If you did choose path, any time you see `/mnt/usb/` they should know to change it to their SSD's file path.

Mount all drives and check the file system. Is `/mnt/usb` listed?
```
$ mount -a
$ df /mnt/usb
> Filesystem     1K-blocks  Used Available Use% Mounted on
> /dev/sda1      479667880 73756 455158568   1% /mnt/hdd
```
```
# move swapfile to ssd or disable swap to extend life of SD card
Optional Reading: Swap File - https://stadicus.github.io/RaspiBolt/raspibolt_20_pi.html#moving-the-swap-file
Optional Reading: Extend Life of SD Card - https://raspberrypi.stackexchange.com/questions/169/how-can-i-extend-the-life-of-my-sd-card
Optional Reading: Mounting External Drive - https://stadicus.github.io/RaspiBolt/raspibolt_20_pi.html#mounting-external-hard-disk 
Optional Reading: Fstab Guide -https://www.howtogeek.com/howto/38125/htg-explains-what-is-the-linux-fstab-and-how-does-it-work/
```


## 7. [UFW]

Enable the Uncomplicated Firewall which controls what traffic is permitted and closes possible security holes. 

The line "ufw allow from 192.168.0.0/24…" below assumes that the IP address of your ODROID is something like 192.168.0.???, the ??? being any number from 0 to 255. If your IP address is 12.34.56.78, you must adapt this line to "ufw allow from 12.34.56.0/24…"
```
$ apt-get install ufw
$ ufw default deny incoming
$ ufw default allow outgoing
$ ufw allow from 192.168.0.0/24 to any port 22 comment 'SSH access restricted to local LAN only'
$ ufw allow proto tcp from 172.28.0.0/16 to any port 8332 comment 'allow dojo to talk to external bitcoind'
$ ufw allow from 192.168.0.0/24 to any port 8899 comment 'allow whirlpool-gui on local network to access whirlpool-cli on Odroid'
$ ufw allow 28333
$ ufw allow 28334
$ ufw enable
$ systemctl enable ufw
$ ufw status
```
```
# Optional Convenience Script:
$ wget https://github.com/s2l1/Headless-Samourai-Dojo/raw/master/ufw-setup.sh
$ chmod 555 ufw-setup.sh
$ ./ufw-setup.sh
```
```
Optional Reading: Connecting to the Network - https://stadicus.github.io/RaspiBolt/raspibolt_20_pi.html#connecting-to-the-network
Optional Reading: Connecting to ODROID - https://stadicus.github.io/RaspiBolt/raspibolt_20_pi.html#connecting-to-the-pi
Optional Reading: Access restricted for local LAN - https://stadicus.github.io/RaspiBolt/raspibolt_20_pi.html#enabling-the-uncomplicated-firewall
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
$ gpg --export A3C4F0F979CAA22CDBA8F512EE8CBC9E886DDD89 | apt-key add -
```
The latest version of Tor can now be installed. While not required, tor-arm provides a dashboard that you might find useful.

`$ apt update`

`$ apt install tor tor-arm`

Now modify the Tor configuration by uncommenting (removing the #) and adding the following line. 

`$ nano /etc/tor/torrc`
```
# scroll down a bit and find the section you need to edit

# remove the # symbol in front of these 2 lines:
ControlPort 9051
CookieAuthentication 1

# now add the following line:
CookieAuthFileGroupReadable 1
```
Restart Tor to activate modifications.

`$ systemctl restart tor`

Check the version of Tor and that the service is up and running.
```
$ tor --version
> Tor version 0.3.4.9 (git-074ca2e0054fded1).
$ systemctl status tor
```
```
# Optional Convenience Script:
$ wget https://github.com/s2l1/Headless-Samourai-Dojo/raw/master/tor-setup.sh
$ chmod 555 tor-setup.sh
$ ./tor-setup.sh
```


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
Import the public key of Wladimir van der Laan, which is the key used to sign each release, and verify the signed checksum file. Check the fingerprint again in case of malicious keys.
```
$ gpg --import ./laanwj-releases.asc
$ gpg --refresh-keys
$ gpg --verify SHA256SUMS.asc
> gpg: Good signature from "Wladimir J. van der Laan ..."
> Primary key fingerprint: 01EA 5486 DE18 A882 D4C2 6845 90C8 019E 36C2 E964
```
Now we know that what we have downloaded from bitcoin.org is authentic. Proceed to extract the Bitcoin Core binaries, install them and check the version.
```
$ tar -xvf bitcoin-0.18.1-aarch64-linux-gnu.tar.gz
$ install -m 0755 -o root -g root -t /usr/local/bin bitcoin-0.18.1/bin/*
$ bitcoind --version
> Bitcoin Core Daemon version v0.18.1
```
```
# Optional Convenience Script:
$ wget https://github.com/s2l1/Headless-Samourai-Dojo/raw/master/bitcoind-setup.sh
$ chmod 555 bitcoind-setup.sh
$ ./bitcoind-setup.sh
```
Now prepare Bitcoin Core directory.

We use the Bitcoin daemon, called “bitcoind”, that runs in the background without user interface and stores all data in a the directory ~/.bitcoin. Instead of creating a real directory, we create a link that points to a directory on the external hard disk.

First make the bitcoin directory on your external SSD.

`$ mkdir /mnt/usb/bitcoin`

Now add a symbolic link that points to the external SSD.

`$ ln -s /mnt/usb/bitcoin ~/.bitcoin`

Navigate to the home directory and check the symbolic link (the target must not be red). The content of this directory will actually be on the external SSD.

`$ ls -la`

Now, the configuration file for bitcoind needs to be created. Open it with Nano and paste the configuration below. Modify where needed and exit.

`$ nano ~/.bitcoin/bitcoin.conf`

Here is an example of bitcoin.conf without comments. 
```
# ~/.bitcoin/bitcoin.conf

# Bitcoind options
server=1
daemon=1
txindex=1

# Connection settings
rpcuser=XXX
rpcpassword=XXX
rpcallowip=172.28.0.1/16
rpcallowip=127.0.0.1
rpcport=8332
rpcbind=192.168.0.70
rpcbind=127.0.0.1
rpcbind=172.28.0.1
zmqpubrawblock=tcp://0.0.0.0:28332
zmqpubrawtx=tcp://0.0.0.0:28333
zmqpubhashblock=tcp://0.0.0.0:28334

# add / change:
proxy=127.0.0.1:9050
bind=127.0.0.1
listenonion=1

```
```
# ~/.bitcoin/bitcoin.conf
# bitcoind configuration - with comment to explain each section

server=1 
# force bitcoind to accept JSON-RPC commands

daemon=1
# starts bitcoind in the background as a daemon

txindex=1 
# builds bitcoin transaction index

rpcuser=XXX
# put any username you prefer for rpc access, please make sure this is the same as BITCOIND_RPC_USER in Section 15

rpcpassword=XXX 
# put any password you prefer for rpc access, please make sure is the same as BITCOIND_RPC_PASSWORD in Section 15

rpcallowip=172.28.0.1/16 
# for max security, I think the accesses to the RPC API should be restricted as much as possible by using rpcallowip=
# the idea is to restrict this access to IP addresses of machines on the LAN which absolutely need to access the RPC API

rpcallowip=127.0.0.1
# add this since you will have clients running directly on the ODROID (not inside docker/dojo)
# adding a line rpcallowip=127.0.0.1 should help bitcoind and these clients communicate
# https://www.lifewire.com/network-computer-special-ip-address-818385
# if you have other clients (lnd, Electrum, etc) running on other local machines you'll need to add a new rpcallowip for them too

rpcport=8332 
# port used to access rpc, 8332 is the default so do not change this

rpcbind=192.168.0.70
# type in local ip of your ODROID, 192.168.0.70 is just an example

rpcbind=127.0.0.1 
# needed for other services, do not change this

rpcbind=172.28.0.1
# host and bitcoind IP from dojo docker network, github source below
# https://github.com/Samourai-Wallet/samourai-dojo/blob/develop/docker/my-dojo/docker-compose.yaml#L92

zmqpubrawblock=tcp://0.0.0.0:28332
zmqpubrawtx=tcp://0.0.0.0:28333
zmqpubhashblock=tcp://0.0.0.0:28334
# zmq 0.0.0.0 settings will broadcast zmq messages on all available ports from bitcoind, since it is used by Dojo, lnd, and other services 
# zmq ports are less sensitive (they are push only and they push very general information). At worse, they may reveal that a bitcoind is running on this machine. 
# if you feel "paranoid", may be you'll want to restrict the access to these ports to  specific machines, by adding specific rules on your firewall.

proxy=127.0.0.1:9050
bind=127.0.0.1
listenonion=1
# tor settings
```
Basically, your bitcoind can serve many clients hosted on your local network. You just have to be sure that you "whitelist" the IP addresses of these clients in bitcoin.conf by adding an rpcallowip line if it's needed.

Let’s start “bitcoind” manually. Monitor the log file a little while to see if it works fine.  
```
$ bitcoind
$ tail -f ~/.bitcoin/debug.log
# Exit the logfile monitoring with Ctrl-C

Check the blockchain info.
$ bitcoin-cli getblockchaininfo
```
Stop bitcoind once you have verified that startup looks good. You will see it start to gather peers, by that point you know that connection is working.

`$ bitcoin-cli stop`

Let's take a step back and check on your other computer that is syncing Bitcoind Core. During the 3rd step of this guide you saved a hash that looks like the following. 

`> 3bac0674c0786689167be2b9f35d2d6e91d5477dee11de753fe3b6e22b93d47c`

Let's check that this hash is indeed authentic by comparing it to the `SHA256SUMS.asc`. We must make sure it matches the hash listed with `bitcoin-0.18.1-win64-setup.exe`.
```
$ cd ~/download
$ cat SHA256SUMS.asc
```


## 10. [SCP]

Right at the beginning we started downloading the Bitcoin mainnet blockchain on your regular computer. Check the verification progress directly in Bitcoin Core on this computer. To proceed, it should be fully synced (see status bar).

As soon as the verification is finished, shut down Bitcoin Core on Windows. We will now copy the whole data structure to the ODROID. This takes about 6 hours.

We are using “Secure Copy” (SCP), so download and install WinSCP, a free open-source program. Linux instructions are below.

With WinSCP, you can now connect to your ODROID.

Accept the server certificate and navigate to the `Local` and `Remote` bitcoin directories.
```
Local: C:\bitcoin\bitcoin_mainnet\
Remote: PATH_TO_SSD\bitcoin\
```
You can now copy the two subdirectories (folders) named `blocks` and `chainstate` from `Local` to `Remote`. This will take about 6 hours. The transfer must not be interupted. Make sure your computer does not go to sleep.

Once the data transfer is finished you can close WinSCP and start bitcoind.

`$ bitcoind`

When bitcoind is still starting and you are watching the logs, you may get an error message like “verifying blocks”. That’s normal, just give it a few minutes. Among other infos the “verificationprogress” is shown. Once this value reaches almost 1 (0.999…), the blockchain is up-to-date and fully validated. Since `txindex=1` was specified in the `bitcoin.conf` file it will take an hour or more for bitcoin to build the transaction index.

If everything is running smoothly, this is the perfect time to familiarize yourself with Bitcoin Core, try some bitcoin-cli commands, and do some reading or videos until the blockchain is up-to-date. A great point to start is the book Mastering Bitcoin by Andreas Antonopoulos which is open source. Now is also a great time to backup your system.

Once you are sync'd up continue to step 11. You can go ahead and close Bitcoin Core on your other machine and delete later on once you have a stable system with proper backups. 

For linux it would look something like the following.

Go to `.bitcoin` directory on your linux machine, usually `/home/user/.bitcoin`.

`$ cd  /home/user/.bitcoin`

Copy the bitcoin data from this Linux machine to your ODROID. Here we are using `root@192.168.0.35` as and example. You need to put your ODROID local (internal) IP address here.

`$ scp -r blocks/ root@192.168.0.35:~/.bitcoin/blocks`

`$ scp -r chainstate/ root@192.168.0.35:~/.bitcoin/chainstate`

```
Optional Reading: SCP on Linux - https://www.computerhope.com/unix/scp.htm
Optional Reading: WinSCP Windows - https://winscp.net/eng/docs/start
```

Now that you are done copying the data over, let's make sure of our Tor connection.

## 11. [VALIDATION]

We now need to check if all connections are truly routed over Tor.

Verify operations in the debug.log file.
```
$ cat ~/.bitcoin/debug.log | grep --max-count=11 tor
$ cat ~/.bitcoin/debug.log | grep --max-count=3 Init

> InitParameterInteraction: parameter interaction: -proxy set -> setting -upnp=0
> InitParameterInteraction: parameter interaction: -proxy set -> setting -discover=0
...
> torcontrol thread start
...
> tor: Got service ID [YOUR_ID] advertising service [YOUR_ID].onion:8333
> addlocal([YOUR_ID].onion:8333,4)
```
Clear things out once you are done viewing.

`$ clear`

Display the Bitcoin network info to verify that the different network protocols are bound to proxy 127.0.0.1:9050, which is Tor on your localhost. Note the onion network is now `"reachable": true,`.

`$ bitcoin-cli getnetworkinfo`


## 12. [PIP] 

Now install the Python Package Installer which we will utilize soon.

First go to the home directory of the root user and then install the necessary dependencies. 

`$ cd ~`

`$ apt-get install python3-dev libffi-dev libssl-dev build-essential`

**NEWBIE TIPS:** Useful libs to have in the system. Also python2 is end of life so we are using python3.

`Optional Reading: Installing PIP - https://pip.pypa.io/en/stable/installing/`

To install pip, securely download get-pip.py. “Secure” in this context means using a modern browser or a tool like curl that verifies SSL certificates when downloading from https URLs.

`$ curl https://bootstrap.pypa.io/get-pip.py -o get-pip.py`

Then run the following.

`$ python3 get-pip.py`

In the future, when you need to update software with PIP you will use a command similar to the following. 

`pip install SoftwareName --upgrade`


## 13. [DOCKER]

Now install docker using this method the convenience script. This script is meant for quick and easy install. 

`$ curl -fsSL https://get.docker.com -o get-docker.sh` 

`$ sh get-docker.sh`

**NEWBIE TIPS:** Make sure to verify the contents of the script you downloaded matches the contents of `install.sh` located at https://github.com/docker/docker-install before executing. Take this and all security measures seriously by doing some research when necessary.
```
# git commit from https://github.com/docker/docker-install
SCRIPT_COMMIT_SHA="6bf300318ebaab958c4adc341a8c7bb9f3a54a1a"
```
Now we will use pip to install docker-compose, I have noticed that apt-get can install an old version. Better to use the docker-compose install instructions which you can look at in Optional Reading. I will walk you through the pip install approach, though there are a few ways to install the latest version.
```                         
$ python3 -m pip install --upgrade docker-compose
# Let the install finish
# --upgrade part is only useful if you already have it, which some people may.
```
```
Optional Reading - Install docker-compose - https://docs.docker.com/compose/install/
Optional Reading - Install docker-compose using pip - https://docs.docker.com/compose/install/#install-using-pip
```
Now check your docker version. An outdated version can cause problems. 

`$ docker -v`

Take a look at what PIP has installed on your system.

`$ python3 -m pip list`

Now to configure docker to use the external SSD. Create a new file in text editor. 

`$ nano /etc/docker/daemon.json`

Add the following 3 lines.
```
{ 
                  "data-root": "/mnt/usb/docker" 
} 
```
Save and exit Nano text editor.

Restart docker to accept changes.

`$ systemctl daemon-reload`

`$ systemctl start docker`

Check that docker is using the SSD.
```
$ docker info | grep "Docker Root Dir:" 
> "data-root": "/mnt/usb/docker/"
```
Try rebooting if you do not see your external SSD listed.

`$ shutdown -r now`


## 14. [DOJO] 

Please verify bitcoind is not running. Will output an error if it is not running.

`$ bitcoin-cli stop`

Download and unzip latest Dojo release.
```
$ cd ~
$ curl -fsSL https://github.com/Samourai-Wallet/samourai-dojo/archive/master.zip -o master.zip
$ unzip master.zip
```
Create a directory for Dojo. We will name it `dojo_dir` for this guide.

`$ mkdir dojo_dir`

Copy samourai-dojo-master directory contents to `dojo_dir` directory. 

`$ cp -rv samourai-dojo-master/* dojo_dir/`

Now remove all the old downloads that you used earlier in the guide.
```
$ rm -rvf samourai-dojo-master/ bitcoin-0.18.1/ master.zip SHA256SUMS.asc laanwj-releases.asc get-pip.py get-docker.sh bitcoin-0.18.1-aarch64-linux-gnu.tar.gz
```
Open bitcoin docker file in text editor. We are going to use the `aarch64-linux-gnu.tar.gz` source.

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
Configure your Dojo installation by editing all 3 `.conf.tpl` files. For each line i.e "USER, PASSWORD, KEY, SECRET" type in anything you prefer. Make it secure like any other password. Please keep in mind that BITCOIND_RPC_USER and BITCOIND_RPC_PASSWORD need to match what is in the `bitcoin.conf` in Section 9 above.

`$ cd ~/dojo_dir/docker/my-dojo/conf`

`$ nano docker-bitcoind.conf.tpl`
```
BITCOIND_RPC_USER = login protecting the access to the RPC API of your full node
BITCOIND_RPC_PASSWORD = password protecting the access to the RPC API of your full node
#
# Set the value of BITCOIND_INSTALL to "off"
# Set the value of BITCOIND_IP with the IP address of you bitcoin full node which is 172.28.0.1
# IP address source - https://github.com/Samourai-Wallet/samourai-dojo/blob/develop/docker/my-dojo/docker-compose.yaml#L92
# Set the value of BITCOIND_RPC_PORT with the port used by your bitcoin full node for the RPC API (8332 default)
# Set the value of BITCOIND_ZMQ_RAWTXS with the port used by your bitcoin full node for ZMQ notifications of raw transactions
#   (i.e. port defined for -zmqpubrawtx in the bitcoin.conf of your full node)
# Set the value of BITCOIND_ZMQ_BLK_HASH with the port used by your bitcoin full node for ZMQ notifications of block hashes
#   (i.e. port defined for -zmqpubhashblock in the bitcoin.conf of your full node)
#
```
`$ nano docker-mysql.conf.tpl`
```
Edit docker-mysql.conf.tpl and provide a new value for the following parameters:
MYSQL_ROOT_PASSWORD = password protecting the root account of MySQL
MYSQL_USER = login of the account used to access the database of your Dojo
MYSQL_PASSWORD = password of the account used to access the database of your Dojo
```
`$ nano docker-node.conf.tpl`
```
Edit docker-node.conf.tpl and provide a new value for the following parameters:
NODE_API_KEY = API key which will be required from your Samourai Wallet / Sentinel for its interactions with the API of your Dojo
NODE_ADMIN_KEY = API key which will be required from the maintenance tool for accessing a set of advanced features provided by the API of your Dojo
NODE_JWT_SECRET = secret used by your Dojo for the initialization of a cryptographic key signing Json Web Tokens. These parameters will protect the access to your Dojo. Be sure to provide alphanumeric values with enough entropy
```
Open the docker quickstart terminal or a terminal console and go to the my-dojo/ directory.

`$ ~/dojo_dir/docker/my-dojo`

This directory contains a script named dojo.sh which will be your entrypoint for all operations related to the management of your Dojo.

Docker and Docker Compose are going to build the images and containers of your Dojo. This operation will take a few minutes (download and setup of all required software components). After completion, your Dojo will be launched and will be ready for connection to your "external" bitcoin full node on your ODROID. 
```
$ cd ~/dojo_dir/docker/my-dojo
$ ./dojo.sh install
```
After successful install, exit the logs with CTRL+C, and start bitcoind.

`$ bitcoind`

**PLEASE NOTE TO START DOJO BEFORE BITCOIND EVERY TIME** If you do not do this, the docker network is not created by Dojo for bitcoind to bind to, so it is ignored.

Check that all containers are up.

`$ docker ps`

You can bring up the logs for all containers at any time by using this command.

`$ ./dojo.sh logs`

Monitor the progress made for the initialization of the database with this command. It is scanning your external bitcoind node. This will take about an hour to complete.

`$ ./dojo.sh logs tracker`

Remember that bitcoind is running externally. This command will remind you when you go to look for logs.
```
$ ./dojo.sh logs bitcoind
> Command not supported for your setup.
> Cause: Your Dojo is using an external bitcoind
```
Did Tor bootstrap 100%?

` $ ./dojo.sh logs tor`

When the syncing of the database has completed retrieve the Tor onion addresses (v2 and v3) of the API of your Dojo.

`$ ./dojo.sh onion`

A maintenance tool is accessible through your Tor browser at this onion address you have just obtained. Other than maintenance, this tool is what you will use to pair a Samourai Wallet on mobile to your Dojo on ODROID. The tool requires that you allow javascript for the site.

A few lines ago you edited `docker-node.conf.tpl` entered a value for `NODE_ADMIN_KEY`. Go to the v3_address.onion (maintenance tool) and log in using the `NODE_ADMIN_KEY` value. Click the pairing tab and you will see a QR code for pairing. We will utilize in the next step where you will pair your Samourai Wallet with your Dojo.

Take some time to get familiar with Dojo commands and docs below.

```
# dojo command help
./dojo.sh command [module] [options]

Available commands:

  help                          Display the help message.

  bitcoin-cli                   Launch a bitcoin-cli console for interacting with bitcoind RPC API.

  clean                         Free disk space by deleting docker dangling images and images of previous versions.

  install                       Install your Dojo.

  logs [module] [options]       Display the logs of your Dojo. Use CTRL+C to stop the logs.

                                Available modules:
                                  dojo.sh logs                : display the logs of all containers
                                  dojo.sh logs bitcoind       : display the logs of bitcoind
                                  dojo.sh logs db             : display the logs of the MySQL database
                                  dojo.sh logs tor            : display the logs of tor
                                  dojo.sh logs api            : display the logs of the REST API (nodejs)
                                  dojo.sh logs tracker        : display the logs of the Tracker (nodejs)
                                  dojo.sh logs pushtx         : display the logs of the pushTx API (nodejs)
                                  dojo.sh logs pushtx-orchest : display the logs of the Orchestrator (nodejs)

                                Available options (for api, tracker, pushtx and pushtx-orchest modules):
                                  -d [VALUE]                  : select the type of log to be displayed.
                                                                VALUE can be output (default) or error.
                                  -n [VALUE]                  : display the last VALUE lines

  onion                         Display the Tor onion address allowing your wallet to access your Dojo.

  restart                       Restart your Dojo.

  start                         Start your Dojo.

  stop                          Stop your Dojo.

  uninstall                     Delete your Dojo. Be careful! This command will also remove all data.

  upgrade                       Upgrade your Dojo.

  version                       Display the version of dojo.
```
```
Dojo Docs - https://github.com/Samourai-Wallet/samourai-dojo/blob/master/doc/DOCKER_setup.md#first-time-setup
Advanced Setups - https://github.com/Samourai-Wallet/samourai-dojo/blob/master/doc/DOCKER_advanced_setups.md
```
## 15. [PAIRING WALLET WITH DOJO]

Install Samourai Wallet on your mobile device. Enable Tor when you open the app but do not start a new wallet. Tap the 3 dots in the top right corner and choose to pair with a new Dojo. Now scan your pairing QR code.

Use api logs to watch pairing, it can take a couple minutes to pair.

`$ ./dojo.sh logs api`

Please keep in mind that any time Dojo is started it must be started **BEFORE** bitcoind. 

Make sure you have a back up of your system. I will also suggest at this point that you harden your system further using the SSH Keys to login and disabling the password.

Congratulations! Your mobile Samourai Wallet is now paired to Dojo.
```
Optional Reading: Login with SSH Key - https://stadicus.github.io/RaspiBolt/raspibolt_20_pi.html#login-with-ssh-keys
Optional Reading: SSH Key Setup - https://www.digitalocean.com/community/tutorials/how-to-set-up-ssh-keys--2
```


------------------------------------------------------------------------------------------


# Bonus Guides
* [**WHIRLPOOL**](https://github.com/s2l1/Headless-Samourai-Dojo#1-whirlpool) 
* [**ELECTRS**](https://github.com/s2l1/Headless-Samourai-Dojo#2-electrs)

To do:
~~1. Test part 13 "DOCKER" on fresh minimal setup~~

~~2. Bonus - Whirlpool cli + gui~~

3. Bonus - lnd
4. Bonus - eps
5. Redo "AUTOSTART BITCOIND"

~~6. Add bonus sections to the TOC ~~

~~7. Redo format~~


## 1. [WHIRLPOOL]

https://samouraiwallet.com/whirlpool

Let's mix some bitcoin. Normally you need to keep the Whirlpool GUI running on your machine at all times, but we are going to choose a little more advanced of a setup that allows us to utilize the ODROID. We will still use the GUI to interact with Whirlpool from other machines on our local network.

You will need openjdk 8+ and download the Whirlpool runtimes 0.8.

If you followed this guide for setup then you have already made the required Firewall rule which looked like this.
```
$ ufw allow from 192.168.0.0/24 to any port 8899 comment 'allow whirlpool-gui on local network to access whirlpool-cli on Odroid'
```

Since that is already taken care of we can move on to downloading and installing.

```
$ cd ~
$ mkdir whirlpool
$ cd whirlpool
$ wget https://github.com/Samourai-Wallet/whirlpool-runtimes/releases/download/cli-0.8.0/whirlpool-client-cli-0.8.0-run.jar
$ apt-get install openjdk-8-jdk
```

Note the path to `whirlpool-client-cli-0.8.0-run.jar` and enter it in the initialization command.

`$ java -jar /path/to/whirlpool-client-cli-0.8.0-run.jar --init`

You'll follow the prompts. Pair your wallet. Which I just sent the pairing code via email to myself and then pasted that when prompted. 

It should restart. The second time you use the following command.

`$ java -jar /path/to/whirlpool-client-cli-0.8.0-run.jar --authenticate --listen --tor --automix`

Make sure you safely record the API key as you'll need it to pair with GUI. You can use GUI to edit all the settings you want. You will need to leave this terminal window running when mixing. I will try to update this section 

Now download GUI on any machine you prefer that is connected to your local network.

https://github.com/Samourai-Wallet/whirlpool-gui/releases

Launch the GUI and choose to connect using external cli. Input the local IP of youR ODROID which should be similar to `192.168.0.44` and leave the port default. Enter the API key you just recorded.

You can now deposit and begin your first Tx0 to get started mixing with Whirlpool. Congrats! I also suggest joining the "Whirlpool CoinJoin by Samourai Wallet" chatroom on telegram if you need support. 

`Suggested Reading: Whirlpool - https://support.samourai.io/section/38-whirlpool`


## 2. [ELECTRS]

https://github.com/romanz/electrs/blob/master/doc/usage.md

First we need to download and install some things.

Debian does not have Python 3.6+ in its repositories, which is required by Electrum.

python3.6 -m pip install --user Electrum-3.3.8.tar.gz

Now we must allow incoming requests to port 50001.

```
$ ufw allow 50001 comment 'allow incoming requests to electrs'
$ ufw disable
$ ufw enable 
```

Install latest Rust (1.32+) and latest Electrum wallet (3.3+).

curl https://sh.rustup.rs -sSf | sh

Also, install the following packages (on Debian):
```
$ apt-get update
$ apt-get install clang cmake  # for the $ git clone below and for building 'rust-rocksdb'
```

More packages need to be installed to avoid some known problems.

```
$ apt-get install -y make build-essential libssl-dev zlib1g-dev libbz2-dev \
libreadline-dev libsqlite3-dev wget curl llvm libncurses5-dev libncursesw5-dev \
xz-utils tk-dev libffi-dev liblzma-dev
```

ELECTRUM INSTALL HERE

Now build it. First build should take ~20 minutes.
```
$ cd ~
$ git clone https://github.com/romanz/electrs
$ cd electrs
$ cargo build --release
```


## XX. ~~[AUTOSTART BITCOIND]~~

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
PIDFile=~/.bitcoin/bitcoind.pid
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


## XX. ~~[LND]~~

$tmux new -s lnd

So to start out let’s get the dependencies. Reference: https://github.com/lightningnetwork/lnd/blob/master/docs/INSTALL.md#bitcoind-options for more information. But lets get started. 

$wget https://dl.google.com/go/go1.12.3.linux-armv6l.tar.gz sha256sum go1.12.3.linux-armv6l.tar

Verify checksum:
efce59fac5ebc7302263ca1093fe2c3252c1b936f5b1ae08afc328eea0403c79
-----
$tar -C /usr/local -xzf go1.12.3.linux-armv6l.tar.gz export PATH=$PATH:/usr/local/go/bin
----
$export GOPATH=~/gocode
$export PATH=$PATH:$GOPATH/bin
-----
Add to $PATH from above to .profile to bottom of doc

$nano .profile

export GOPATH=~/gocode
export PATH=$PATH:$GOPATH/bin

Ctrl+X , y
----
Installing LND

Ok so now that dependencies are installed. Next thing we need to do is install LND. Again, reference https://github.com/lightningnetwork/lnd/blob/master/docs/INSTALL.md#bitcoind-options for more information.

$go get -d github.com/lightningnetwork/lnd
$cd $GOPATH/src/github.com/lightningnetwork/lnd 
$make && make install

Once complete:
$make check
----
Pairing with dojo 

So for this next part we need some information prepared ahead of time. 
Installed tor (see tor section)
Dojo configured for external apps
See external apps section
You have your external IP address from docker-bitcoind.conf
(assumes Tor is configured outside of docker, external apps setting in conf file is set to 'on' ,  & dojo was restarted and is running)

Get your external facing IP address of your dojo machine by visiting --> https://www.iplocation.net/

Now lets use tmux to create a split a second terminal
$tmux new -s lnd

$ lnd --bitcoin.active --bitcoin.mainnet --debuglevel=debug --bitcoin.node=bitcoind --bitcoind.rpchost=127.0.0.1:28256 --bitcoind.rpcuser=your_dojo_rpc_username --bitcoind.rpcpass=your_dojo_rpc_password --bitcoind.zmqpubrawblock=127.0.0.1:9502 --bitcoind.zmqpubrawtx=127.0.0.1:9501 --externalip=xxx.xxx.x.xxx (IP you looked up)

(Note if you are running on seperate machine. You must change the IP in docker-bitcoind.conf to the IP of the machine) 

Ie if your IP on your Dojo Pi is 192.168.1.XX your command would be:

$ lnd --bitcoin.active --bitcoin.mainnet --debuglevel=debug --bitcoin.node=bitcoind --bitcoind.rpchost=192.168.1.XX:28256 --bitcoind.rpcuser=your_dojo_rpc_username --bitcoind.rpcpass=your_dojo_rpc_password --bitcoind.zmqpubrawblock=192.168.1.XX:9502 --bitcoind.zmqpubrawtx=192.168.1.XX:9501 --externalip=xxx.xxx.x.xxx (IP you looked up)

At this point it will ask you to use the command $lncli create or unlock to create new wallet. This is a requirement everytime you start LND. But must be in a separate window.

So lets switch out of this tmux session:
Ctrl+b d 

***In current terminal ***
$lncli create
Create new password - (Write down password created, you will need it)
Follow prompts
Write down 24-word seed.
Enter
Enter
**You can choose to encrypt the file when prompted or enter thru it.

$lncli unlock
Enter password.

(Prompt "successfully unlocked wallet")

Now that we have successfully unlocked the wallet. LND will begin to verify all the blocks from your Dojo. This generally takes a few hours. So take a break and comeback. With the tmux window it will continue running so no fears on leaving it. But lets get back to LND window and verify.

***Back in terminal "LND"***
$tmux a -t ‘lnd’

Verify it is running and let it process all blocks.
----

Now that the blocks are caught up and LND is running. We need to configure our lnd.conf file.
Switch out of ‘lnd’ session.

Ctrl+b d

**Original Terminal**
$lncli stop

Time to edit lnd.conf to connect over Tor.

$cd .lnd
$nano lnd.conf

--------------------------lnd.conf-------------------------
alias=***your_choice***
debuglevel=debug

## Bitcoin Settings
bitcoin.active=1
bitcoin.mainnet=1
bitcoin.node=bitcoind

## Bitcoind Settings (**Note-must match your Dojo’s docker-bitcoind.conf for external apps***)

bitcoind.rpchost=127.0.0.1:28256
bitcoind.rpcuser=***your_dojo_rpc_username***
bitcoind.rpcpass=***your_dojo_rpc_password***
bitcoind.zmqpubrawblock=127.0.0.1:9502
bitcoind.zmqpubrawtx=127.0.0.1:9501

## Tor Settings

tor.active=1
tor.socks=127.0.0.1:9050
tor.control=127.0.0.1:9051
tor.streamisolation=1
tor.v3=1

## Application Options

listen=localhost
#tlsextraip=192.168.1.0/24 # <-- uncomment if you plan to use Zap Android/iOS and replace with your (adjust according to your local IP 192.168.0.0/24)
#rpclisten=0.0.0.0:10009 # <-- uncomment if you plan to use Zap Android/iOS

--------------------------------------------------------------------------------
End lnd.conf file
Save and exit 
^X , y

**Remember the bitcoind setting IP address must match that if your dojo docker-bitcoind.conf external app IP
---------------

Ok so now that we have reconfigured your lnd.conf. We need to delete the TLS cert and re-spin up LND.

Delete the tls.cert file and restart LND to recreate it.

$ sudo rm /home/***pi***/.lnd/tls.* (replace ***pi*** with your username)

Start LND

$tmux a -t 'lnd'
$lnd

*Wait till prompted to unlock wallet*
Ctrl+b d

**Original terminal**
$lncli unlock
Enter wallet password

**Successfully Unlocked prompt)

Let’s verify LND is successfully running:

$tmux a -t ‘lnd’

You should now be Riding the Lightning.. over Tor...backed by your own personal Dojo Node


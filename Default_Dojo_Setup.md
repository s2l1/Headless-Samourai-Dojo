# Introduction
**for ODROID N2**

# Table of Contents
* [**HARDWARE REQUIREMENTS**]() 
* [**OPERATING SYSTEM**]()
* [**BLOCKCHAIN DATA**]()
* [**NETWORK**]()
* [**SSH**]()
* [**SYSTEM SETUP**]()
* [**UFW**]()
* [**SCP**]()
* [**PIP**]()
* [**DOCKER**]()
* [**DOJO**]()
* [**PAIRING WALLET WITH DOJO**]()

```
# My sources:

Dojo Telegram - https://t.me/samourai_dojo
Dojo Docs - https://github.com/Samourai-Wallet/samourai-dojo/blob/master/doc/DOCKER_setup.md#first-time-setup
Advanced Setups - https://github.com/Samourai-Wallet/samourai-dojo/blob/master/doc/DOCKER_advanced_setups.md
Raspibolt - https://stadicus.github.io/RaspiBolt/
Pi 4 Dojo Guide - https://burcak-baskan.gitbook.io/workspace/
```

This is inspired by what is considered to be the "default dojo deployment". This setup is recommended to Samourai users who feel comfortable with a few command lines. More advanced users may find [this guide](https://github.com/s2l1/Headless-Samourai-Dojo/blob/master/Advanced_Dojo_Setup.md) helpful for things like running external bitcoind. 

**NEWBIE TIPS:** Each command has `$` before it, and the outputs of the command are marked `>` to avoid confusion. `#` is symbol fo a comment. Do not enter these as part of a command. If you are not sure about commands, stuck, learning, etc. try visiting the information links and doing the Optional Reading. Look up terms that you do not know. The Dojo Telegram chat is also very active and helpful. I am trying my best to educate anyone new throughout this guide. 

## 1. [HARDWARE REQUIREMENTS]
- `https://forum.odroid.com/viewtopic.php?f=176&t=33781`

You will need an ODROID N2 with a hard plastic case. I am using this with a 1tb Samsung Portable SSD, USB3.0, hardline ethernet connection, and SD card. Add a UPS battery back up later on to be sure your ODROID wont lose power during bad weather. You will also need a Windows / Linux / Mac with good specs that is on the same network as the ODROID. This setup will take up about as much room as a standard home router/modem and look clean clean once finished.


## 2. [OPERATING SYSTEM]
- `https://forum.odroid.com/viewtopic.php?f=179&t=33865`

By meveric » Tue Feb 19, 2019 8:29 AM: "This is the first version of my Debian Stretch image for the ODROID N2. It is uses the 4.9 LTS Kernel from Hardkernel. It's a headless server image only with user root. It has all my repositories included, which allows for easy installation and updates of packages such as Kernel and Headers and other packages. The image has my usual setup: means on first boot it's resizing the rootfs partition and configures SSH. It will automatically reboot after the initial setup after which this image is ready to use. Kernel and headers are already installed if you need to build your own drivers. A few basic tools such as htop, mc, vim and bash-completion are already installed."
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
Use the md5, sha512, sig, and the PGP public key to check that the Debian `.img.xz` you have downloaded is authentic. Do not trust, verify! If you are not sure on this please look up “md5 to verify software” and “gpg to verify software.” Please take some time to learn as this is used to verify things often. Watch the entire playlist below if you are a newbie and working on getting comfortable using the Windows CMD or Linux Terminal.
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

This guide assumes that many will use a Windows machine, but it should also work with most operating systems. I have done my best to provide linux or mac instructions where possible. You need to have about 250+ GB free disk space available, internally or on an external hard disk (but not the SSD reserved for the ODROID). As indexing creates heavy read/write traffic, the faster your hard disk the better. If you are using linux as a main machine I will assume that you are comfortable lookup up how to download Bitcoin Core.

Using SCP, we will copy the blockchain from the Windows computer over the local network later in this guide.

For now download the Bitcoin Core installer from bitcoincore.org and store it in the directory you want to use to download the blockchain. To check the authenticity of the program, we will calculate its checksum and compare it with the checksums provided.

In Windows, I’ll preface all commands you need to enter with `$`, so with the command `$ cd bitcoin` just type `cd bitcoin` and hit enter.

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

Take note of this new static IP address for your ODROID and apply changes. 

If you have not changed your router's default login password from the default, please do so now. 

Apply and log out of your router. 


## 5. [SSH]

Go ahead and SSH into your ODROID by using Putty on Windows or Terminal on Linux. The machine must be connected to your local network.
```
# Login info:
# Default Username - root
# Default Password - odroid

# Windows: 
# Download - https://www.putty.org/
# Enter the ODROID IP you just took note of, connect, and enter the password.

# In Linux Terminal:
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

Install fail2ban, git, curl, unzip, and net-tools.

`$ apt-get install fail2ban git curl unzip net-tools`

Now we will format the SSD, erasing all previous data. Make sure your SSD is plugged in. The external SSD is then attached to the file system and can be accessed as a regular folder (this is called mounting). We will use ext4 format, NTFS will not work.
```
# Delete existing flash drive partition:
$ fdisk /dev/sda
# Press 'd'
# Press 'w'
```
```
# Create new primary flash drive partition:
$ fdisk /dev/sda
# Press 'n'
# Press 'p'
# Press '1'
# Press 'enter'
# Press 'enter'
# Press 'w'
```
Take note of the `NAME` for main partition on the external hard disk using the following command.

`$ lsblk -o UUID,NAME,FSTYPE,SIZE,LABEL,MODEL`

Assuming you only have one drive connected, the `NAME` will be `/dev/sda`. Double-check that `/dev/sda` exists, and that its storage capacity is what you expected.

Format the external SSD with Ext4. Use `NAME` from above, example is `/dev/sda1`.

`$ mkfs.ext4 /dev/sda1`

Copy the `UUID` that is provided as a result of this format command to your notepad.

Edit the fstab file using nano, then add the line at the end replacing the `UUID` with your own. 
```
$ nano /etc/fstab
# replace `UUID=123456` with the `UUID` that you just took note of
UUID=123456 /mnt/usb ext4 rw,nosuid,dev,noexec,noatime,nodiratime,auto,nouser,async,nofail 0 2
```
Create the directory to add the SSD to and set the correct owner. Here we will use `/mnt/usb` as an example.

`$ mkdir /mnt/usb`

**NEWBIE TIPS:** `/mnt/usb/` is simply my desired path, and you can choose any path you want for the mounting of your SSD. If you did choose path, any time you see `/mnt/usb/` they should know to change it to their SSD's file path.

Mount all drives and then check the file system. Is `/mnt/usb` listed?
```
$ mount -a
$ df /mnt/usb
> Filesystem     1K-blocks  Used Available Use% Mounted on
> /dev/sda1      479667880 73756 455158568   1% /mnt/hdd
```

Set your timezone.

`$ dpkg-reconfigure tzdata`

Setup tool can be accessed by using the following command.

`$ setup-odroid`

Here you can change root password from the default, hostname, and move rootfs to HDD/SSD etc. This tool may ask you to reboot to apply the changes.
```
# Optional Convenience Script: Please note these scripts are intended for those that are using similar hardware/OS 
# ALWAYS analyze scripts before running them!
$ wget https://github.com/s2l1/Headless-Samourai-Dojo/raw/master/system-setup.sh
$ chmod 555 system-setup.sh
$ ./system-setup.sh
```

```
# during setup you can move the swapfile to SSD or disable swap to extend life of your SD card
Optional Reading: Swap File - https://stadicus.github.io/RaspiBolt/raspibolt_20_pi.html#moving-the-swap-file
Optional Reading: Extend Life of SD Card - https://raspberrypi.stackexchange.com/questions/169/how-can-i-extend-the-life-of-my-sd-card
Optional Reading: Mounting External Drive - https://stadicus.github.io/RaspiBolt/raspibolt_20_pi.html#mounting-external-hard-disk 
Optional Reading: Fstab Guide -https://www.howtogeek.com/howto/38125/htg-explains-what-is-the-linux-fstab-and-how-does-it-work/
```

## 7. [UFW]

Enable the Uncomplicated Firewall which controls what traffic is permitted and closes some possible security holes. 

The lines that start with `ufw allow from 192.168.0.0/24...` below assumes that the IP address of your ODROID is something like 192.168.0.???, the ??? being any number from 0 to 255. If your IP address is 12.34.56.78, you must adapt this line to `ufw allow from 12.34.56.0/24...`. 
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


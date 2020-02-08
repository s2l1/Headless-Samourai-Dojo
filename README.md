# Headless-Samourai-Dojo
## for Odroid N2

This guide is out of date! Please see https://code.samourai.io/Ronin/RoninDojo

First I must say thanks to @Nicholas @BTCxZelko @hashamadeus @laurentmt @PuraVlda from Dojo Telegram chat. This would not have been possible without @Nicholas + Burcak Baskan and the Dojo Pi4 guide.  @stadicus and his "Raspibolt" guide was my first bitcoin full node.

Are you looking to run a full node that can interact with a mobile wallet over Tor 24/7? Don't want to leave some dusty old laptop running in the corner with wires hanging about?

If you are new to many of these concepts that is ok, no prior experience is required. This guide should help you get started and point you in the right directions for researching.

Choose between the 2 guides [Default_Dojo_Setup.md](https://github.com/s2l1/Headless-Samourai-Dojo/blob/master/Default_Dojo_Setup.md) or [Advanced_Dojo_Setup.md](https://github.com/s2l1/Headless-Samourai-Dojo/blob/master/Advanced_Dojo_Setup.md) below. This choice is based on your needs and preferences. If you need to do something more advanced like run bitcoind outside of Docker then I do recommend the Advanced Setup guide.

## 1. [Default Dojo Setup](https://github.com/s2l1/Headless-Samourai-Dojo/blob/master/Default_Dojo_Setup.md)

This is inspired by what is considered to be the "default dojo deployment". This setup is recommended to Samourai users who feel comfortable with a few command lines. If you are not willing to learn these basic command line steps this is not for you and you might want to check out a "plug 'n play" Dojo like [this one](https://shop.nodl.it). Samourai Dojo is the backing server for Samourai Wallet. It provides HD account, loose addresses (BIP47) balances, and transactions lists. Also provides unspent output lists to the wallet. PushTX endpoint broadcasts transactions through the backing bitcoind node. 

MyDojo is a set of Docker containers providing a full Samourai backend composed of:
* a bitcoin full node accessible as an ephemeral Tor hidden service
* a backend database
* a backend modules with an API accessible as a static Tor hidden service
* a maintenance tool accessible through a Tor web browser

## 2. [Advanced Dojo Setup](https://github.com/s2l1/Headless-Samourai-Dojo/blob/master/Advanced_Dojo_Setup.md)

This setup will be running bitcoind externally, which is a bit more advanced, versus leaving the default option enabled where bitcoind will run inside Docker. This setup is useful for a many reasons like using pre-existing full node, it is faster than waiting for a full blockchain sync with ODROID N2, and Docker can be confusing to connect things like an electrum server to. This setup will also teach new users some very useful skills involving networking, hardware, linux, and bitcoin. Samourai Dojo is the backing server for Samourai Wallet. It provides HD account, loose addresses (BIP47) balances, and transactions lists. Also provides unspent output lists to the wallet. PushTX endpoint broadcasts transactions through the backing bitcoind node. 

In this case MyDojo is a set of Docker containers providing a full Samourai backend composed of:
* a backend database
* a backend modules with an API accessible as a static Tor hidden service
* a maintenance tool accessible through a Tor web browser

If you have some spare time please make a github account and edit these guide. You can also fork the guide to your own version, maybe for a purpose such as adding more detailed notes, or perhaps for making more drastic changes like a different method of deployment. It was a community effort that helped me bring this guide together, and it may take the same effort to keep this guide polished and up to date.  Feel free to revise things, make suggestions, become contributor, update versions, et cetera. Thank you!

```
# Looking for some guides for other OS, hardware, etc?
# Check out some other guides, see what the community is up to!

Plug and Play Dojo @nodl_it - https://twitter.com/nodl_it
Bitcoin Transactional Privacy @Pura_Vlda - https://twitter.com/Pura_Vlda/status/1180856868966670336?s=09
PyDojo Library @alphaazeta - https://github.com/pxsocs/pyDojo
Electrs ontop of Dojo @BTCxZelko - https://bitcoin-on-raspberry-pi-4.gitbook.io/workspace/installing-electrs-ontop-of-dojo
Dojo on a Raspberry Pi 4 @burcakbaskan - https://bitcoin-on-raspberry-pi-4.gitbook.io/workspace/
Dojo on a Raspberry Pi 4 @BtcnFtrs - https://medium.com/@btcftrs/samourai-dojo-bitcoin-full-node-on-raspberry-pi-2b6713c2ebfb
```

```
# My sources:

Dojo Telegram - https://t.me/samourai_dojo
Dojo Docs - https://github.com/Samourai-Wallet/samourai-dojo/blob/master/doc/DOCKER_setup.md#first-time-setup
Advanced Setups - https://github.com/Samourai-Wallet/samourai-dojo/blob/master/doc/DOCKER_advanced_setups.md
Raspibolt - https://stadicus.github.io/RaspiBolt/
Pi 4 Dojo Guide - https://burcak-baskan.gitbook.io/workspace/
```

# Headless-Samourai-Dojo
## for Odroid N2

First I must say thanks to @BTCxZelko @hashamadeus @laurentmt @PuraVlda from Dojo Telegram chat. Also thanks to @stadicus and Burcak Baskan for the Raspibolt guide and the Dojo Pi4 guide. 

Are you looking to run a full node that can interact with a mobile wallet over Tor 24/7? Don't want to leave some dusty old laptop running in the corner with wires hanging about?

If you are new to many of these concepts that is ok, no prior experience is required. This guide should help you get started and point you in the directions for researching.

Choose between the 2 guides [Default_Dojo_Setup.md](https://github.com/s2l1/Headless-Samourai-Dojo/blob/master/Default_Dojo_Setup.md) or [Advanced_Dojo_Setup.md](https://github.com/s2l1/Headless-Samourai-Dojo/blob/master/Advanced_Dojo_Setup.md) based on your needs and preferences. If you need bitcoind to run outside of Docker then I do recommend the Advanced Setup guide.

Samourai Dojo is the backing server for Samourai Wallet. It provides HD account, loose addresses (BIP47) balances, and transactions lists. Also provides unspent output lists to the wallet. PushTX endpoint broadcasts transactions through the backing bitcoind node. 

MyDojo is a set of Docker containers providing a full Samourai backend composed of:
* a bitcoin full node accessible as an ephemeral Tor hidden service
* a backend database
* a backend modules with an API accessible as a static Tor hidden service
* a maintenance tool accessible through a Tor web browser

If you have some spare time please make a github account and edit this guide. You can also fork the guide to your own version, maybe for a purpose such as adding more detailed notes, or perhaps for making more drastic changes like a different method of deployment. It was a community effort that helped me bring this guide together, and it may take the same effort to keep this guide polished and up to date.  Feel free to revise things, make suggestions, become contributor, update versions, et cetera. Thank you!

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

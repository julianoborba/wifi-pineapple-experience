![Project Logo](assets/logo.png)

# Universal Wifi pineapple hardware cloner v3

The Pineapple NANO and TETRA were excellent security hardware but in 2020 they reached their end of life.<br>
So to give a new life to this platform in more modern hardware, I've made these scripts.<br>

Sometime between 2019 and 2020 we started using the private beta of this project which we called "Pineapple Termidor".<br>
When I started to redo this project to launch a new version I decided to rescue the original name and logo for fun 🤣


## About this project

This project is the result of everything I've experienced from 2018 to 2022 to successfully clone the NANO and TETRA.<br>

For this I've develop:
* The lists of files to copy and also the script to copy them.
* A script to patch the filesystem, so it works on any hardware.
* Completely updated [panel](https://github.com/xchwarze/wifi-pineapple-panel) with fixes and improvements.
* Completely updated [packages repository](https://github.com/xchwarze/wifi-pineapple-community/tree/main/packages).
* New [module repository](https://github.com/xchwarze/wifi-pineapple-community/tree/main/modules).
* New modules: [PMKIDAttack](https://github.com/xchwarze/wifi-pineapple-community/tree/main/modules/src/PMKIDAttack) and [Terminal](https://github.com/xchwarze/wifi-pineapple-community/tree/main/modules/src/Terminal)

![Panel](assets/termidor-mipsel.png)


## Builds

You can find the complete steps to build this project in [this document](build.md).


## Supported devices

There are 211 devices supported by the project. You can see the full [list here](devices.md).
<br>

Also I made a second repo for [downloads](https://github.com/xchwarze/wifi-pineapple-cloner-builds) where you can find the firmwares already made for the most common devices of the Supported devices list.
<br>

If you want to collaborate by adding a new device to the list or adding improvements to them, you can do it through a pull request to this repo.


## Install steps

1. Install OpenWrt version 19.07.7 on your router
<br>

2. Use SCP to upload the image in your device
```bash
scp archer-c7-v5-tetra-sysupgrade.bin root@192.168.1.1:/tmp 
root@192.168.1.1's password: 
archer-c7-v5-tetra-sysupgrade.bin                                                                        100%   13MB   2.2MB/s   00:05 
```
<br>

3. Once the image is uploaded, execute sysupgrade command to update firmware
```bash
ssh root@192.168.1.1
sysupgrade -n -F /tmp/archer-c7-v5-tetra-sysupgrade.bin
```
Now wait few minutes until the device install the new firmware
<br>

4. Enter to pineapple panel and enjoy! `http://172.16.42.1:1471/` <br>
At this point you could only have one of two problems:<br>

A) You are stuck at the message "The WiFi Pineapple is still booting" don't panic.
All you have to do is SSH into the router with the username root and password you set originally
```bash
ssh root@172.16.42.1
jffs2reset -y && reboot
```

B) The live scan mode does not work but the others do.
This happens because you don't have python installed, it will be installed automatically when you connect the device to the internet and reboot it.
As long as you have the minimum space needed or a pendrive connected.<br>

In the download repo there are more notes about it that might interest you if you have problems.
<br>

5. Once installed, you can also change the default theme of the panel if you wish:
```bash
wget https://raw.githubusercontent.com/xchwarze/wifi-pineapple-community/main/themes/install.sh -O /tmp/theme-install.sh
chmod +x /tmp/theme-install.sh && /tmp/theme-install.sh darkmode
```
<br>


## Recomended setup

1. [GL-AR150](https://www.gl-inet.com/products/gl-ar150/) or [GL-AR750S](https://www.gl-inet.com/products/gl-ar750s)
2. USB 2.0 [2 ports hub](https://www.ebay.com/itm/144520475350)
3. Generic [RT5370 WIFI adapter](https://www.ebay.com/itm/284904442887) or [MT7612U WIFI adapter](https://www.ebay.com/itm/175219205235) **you're really going to need this on hardware that doesn't have two wifi adapters**
4. Please support Hak5 work and buy the original hardware!


## If you want to collaborate with hardware 

Those who want to help buy testing hardware or just give me a tip, you can do it by sending donations to my binance account:

![binance-qr](assets/binance-qr.png)

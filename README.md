# voxwifi

Inspiration

* [homeroam.wikidot.com](http://homeroam.wikidot.com/designated-driver-captive-portal)

# Buy a GL-AR300M router

From [GL inet.](https://www.gl-inet.com/ar300m/)

# Connecting

* Power on with USB Power
* Plug LAN cable from internet router LAN to AR300M WAN port
* Plug LAN cable from AR300 LAN port to computer LAN port

# Access AR300M

Visit in browser: [192.168.8.1](http://192.168.8.1)

* Check if Firmware should be upgraded (Remember to tick **on** to keep settings)

Go to the advanced page [192.168.8.1/cgi-bin/luci](http://192.168.8.1/cgi-bin/luci)

Access with ssh
```bash
ssh root@192.168.8.1
```

With ssh terminal, see basic info
```bash
uci show network.lan
```

## Install common tools

The 'bash' shell has some better tools for scripts and functions.

```bash
# Update and see if bash is available
opkg update
opkg list | grep ^bash
# Install
opkg install bash git git-http curl wget 
opkg install nano diffutils grep ca-certificates

# Fix git-merge
ln -s `which git` `which git | sed 's/git/git-merge/' `
```

Log out of ssh and log in again. This is update any path changes.

# Get setup scripts

In the router, clone the folder with setup scripts

```bash
git clone --depth=1 https://github.com/tlinnet/voxwifi.git
cd voxwifi
```

## Install 4G driver

We will install the drivers for the "HUAWEI E3372 LTE” 4G USB modem.

Before installing, try to find the IP you have now

```bash
wget http://ipinfo.io/ip -qO -
```

Then install
```bash
source 01_install_4G_driver.sh
```

The "HUAWEI E3372 LTE” 4G USB modem will make it's own subnet 192.168.8.1.<br>
Therefore we need to change to another subnet. Remember, the subnet on your own internet router is probably 192.168.0.x or 192.168.1.x or similar. <br>
So the script will automatically change to 192.168.5.x

The script will also reboot the router and make your SSH terminal freeze.

Wait 5 min, close your terminal window, and start another terminal.

Access with ssh
```bash
ssh root@192.168.5.1
```

Now do some checks

```bash
# see log
logread
# see network
ifconfig
netstat -nr
# See the current external IP
wget http://ipinfo.io/ip -qO -
```

Now, plugin the 4G modem in the USB.

```bash
# see log
logread | grep wan2
# see network
ifconfig | grep -B 1 -A 7 192.168.8
netstat -nr
# See the current external IP
wget http://ipinfo.io/ip -qO -
```

The last 2 commands should show, that you have changed your gateway
and external IP address. Congratulations, the 4G modem is working.

# Setup hotspotsystem.com

## Make account
Go to [hotspotsystem](http://www.hotspotsystem.com/).

Make an account. Sign up. 
You may need to send a signed document to them.
Wait some days.

## Make new PRO location for router
Go to
* MANAGE --> Locations
* Click "Add a New HotSpot Location"
* Chose "Hotspot Pro"
* Write in info about the place
* Find Latitude and Longitude from: http://www.mapcoordinates.net/en
* Set "Default Bandwidth limit (download):" to 4096 Kbis/sec.
* The same for Download
* Set "Offer Pay-Per-Use packages in this Currency" to "Danish Krone" (or similar)

When completed, a list should be shown:
* In the table, look for the number in the column "Loc. ID". We need this number in the later install.

## Install and setup chilli for hotspotsystem

Access with ssh
```bash
ssh root@192.168.5.1
```

Then go to the folder with setup scripts
```bash
cd voxwifi
# Now install
source 02_hotspotsystem.sh
```

Then reboot.

```bash
reboot
```

Wait 3 min for router to restart.  Unpluck and repluck
LAN cable to computer, to reset IP information in computer. Then visit any homepage. This should show the splash login page for hotspotsystem

## Configure PRO location and tickets at hotspotsystem.com

We want to make a setup like this
* Make free access for the user
* Re-direct to a questionnaire after successful login

With your computer, unpluck from the router, and use Wifi to get access to 
[hotspotsystem](http://www.hotspotsystem.com/).


First make a 12 H free internet ticket
* CUSTOMIZE -> Packages
* Create new package 
* Name of Package : "12H Wifi Voucher"
* Period of Access: 12 HOUR 
* Type Of Package: Time-Based 
* Price: 0
* Create New package 

Enable "Free" module
* MANAGE --> Locations
* Click the newly created location
* Click "Modify Hotspot Data & Settings"
* Click "Free Trial"
* Enable "Free Trial Module"
* Click "Submit"

Change Voucher for Free module
* MANAGE --> Locations
* Click the newly created location
* In the table "FREE HOTSPOT PACKAGE" click "Modify Free Package"
* Chose "12H Wifi Voucher" and then "Assignment of packages"

Remove the payment module
* MANAGE --> Locations
* Click the newly created location
* Click "Modify Hotspot Data & Settings"
* In ONLINE PAYMENTS, deselect "Primary Payment Module"
* Submit

Reorder modules. 
* MANAGE --> Locations
* Click the newly created location
* Click "Modify Hotspot Data & Settings"
* In MODULE ORDER, drag "Free Trial module" to the top.
* Submit

Inspect ACCESS METER and landing page
* MANAGE --> Locations
* Click the newly created location
* In the table "ACCESS METER" you can see how many remaining free logins you have, and you can buy more.
* Click " VIEW HOTSPOT FRONT PAGE"

Change which information to capture on login
* MANAGE --> Locations
* Click the newly created location
* Click "Modify Hotspot Data & Settings"
* In CUSTOMIZE DATA CAPTURE, deselect everything possible

Change landing page after login
* MANAGE --> Locations
* Click the newly created location
* Click "Modify Hotspot Data & Settings"
* In SPLASH PAGE SETTINGS, add the url to "Redirect URL after Successful Login"
* Deselect "Launch information popup in case of redirection". This is annoying.

Now plugin the LAN cable, and try to go on a homepage. The landing page should appear.

## Try making a Free Basic spot.

In the router:

Access with ssh
```bash
ssh root@192.168.5.1
```

Then change location to new "Loc. ID" X
```bash
uci show chilli | grep nasid
uci set chilli.@chilli[0].radiusnasid='USERNAME_X'
uci commit chilli
```

Then activate new place
```bash
cd voxwifi
./03_hotspotsystem_uplink.sh
```

#!/bin/bash

DEFPERFORM=y
# Install packages for 4 G usb dongle “HUAWEI E3372 LTE” and make new eth2 interface on the USB port
mk4g() {
    echo -e "\nThis will install packages for 4 G usb dongle 'HUAWEI E3372 LTE' and make new eth2 interface on the USB port"
    unset PERFORM
    read -p "Should I perform this? [$DEFPERFORM]:" PERFORM
    PERFORM=${PERFORM:-$DEFPERFORM}
    echo -e "You entered: $PERFORM"
    if [ "$PERFORM" == "y" ]; then
        echo -e "\nInstalling packages: kmod-usb-net-cdc-ether usb-modeswitch"
        opkg update && opkg install kmod-usb-net-cdc-ether usb-modeswitch

        echo -e "\nNow making an 'wan2' interface for eth2"
        uci set network.wan2=interface
        uci set network.wan2.ifname='eth2'
        uci set network.wan2.proto='dhcp'
        uci commit network
        ifup wan2

        echo -e "\nNow adding 'wan2' to the firewall zone 'lan'"
        uci set firewall.@zone[1].network='wan wan2 wan6'
        uci commit firewall
        /etc/init.d/firewall restart
    else
        echo -e "\nSkipping"
    fi

}

# Perform
mk4g
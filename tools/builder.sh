#!/bin/bash
# by DSR! from https://github.com/xchwarze/wifi-pineapple-cloner

ARCHITECTURE="$1"
FLAVOR="$2"
IMAGEBUILDER_FOLDER="$3"
PROFILE="$4"
declare -a ARCHITECTURE_TYPES=("mips" "mipsel")
declare -a FLAVOR_TYPES=("nano" "tetra" "universal")
if [[ ! -d "$IMAGEBUILDER_FOLDER" || "$PROFILE" == "" ]] || ! grep -q "$ARCHITECTURE" <<< "${ARCHITECTURE_TYPES[*]}" || ! grep -q "$FLAVOR" <<< "${FLAVOR_TYPES[*]}"; then
    echo "Run with \"builder.sh [ARCHITECTURE] [FLAVOR] [IMAGEBUILDER_FOLDER] [PROFILE]\""
    echo "    ARCHITECTURE        -> must be one of these values: mips, mipsel"
    echo "    FLAVOR              -> must be one of these values: nano, tetra, universal"
    echo "    IMAGEBUILDER_FOLDER -> path to openwrt imagebuilder"
    echo "    PROFILE             -> profile for use in imagebuilder build"

    exit 1
fi

# dependencies installed, uninstalled and the order in which they are installed is for a reason!
# no rtl-sdr, no kmod-usb-net-*, no kmod-rtl8192cu, no kmod-usb-acm
PACKAGES_NANO="iw at autossh base-files block-mount ca-certificates chat dnsmasq e2fsprogs ethtool firewall hostapd-utils ip6tables iperf3 iwinfo kmod-crypto-manager kmod-fs-ext4 kmod-fs-nfs kmod-fs-vfat kmod-gpio-button-hotplug kmod-ipt-offload kmod-leds-gpio kmod-ledtrig-default-on kmod-ledtrig-netdev kmod-ledtrig-timer kmod-mt76x2u kmod-nf-nathelper kmod-rt2800-usb kmod-rtl8187 kmod-scsi-generic kmod-usb-ohci kmod-usb-storage-extras kmod-usb-uhci kmod-usb2 libbz2-1.0 libcurl4 libelf1 libffi libgmp10 libiconv-full2 libintl libltdl7 libnet-1.2.x libnl200 libreadline8 libustream-mbedtls20150806 libxml2 logd macchanger mtd nano ncat netcat nginx openssh-client openssh-server openssh-sftp-server openssl-util php7-cgi php7-fpm php7-mod-hash php7-mod-json php7-mod-mbstring php7-mod-openssl php7-mod-session php7-mod-sockets php7-mod-sqlite3 ppp ppp-mod-pppoe procps-ng-pkill procps-ng-ps python-logging python-openssl python-sqlite3 ssmtp tcpdump-mini uci uclibcxx uclient-fetch urandom-seed urngd usb-modeswitch usbreset usbutils wget wireless-tools wpad busybox libatomic1 libstdcpp6 -wpad-basic -dropbear -swconfig -odhcpd-ipv6only -odhcp6c"

# no rtl-sdr, no kmod-usb-net-*, no kmod-usb-serial-*, no kmod-rtl8192cu, no kmod-usb-acm, no kmod-usb-wdm, no kmod-lib-crc-itu-t
PACKAGES_TETRA="iw at autossh base-files bash block-mount ca-certificates chat dnsmasq e2fsprogs ethtool firewall hostapd-utils ip6tables iwinfo kmod-crypto-manager kmod-fs-ext4 kmod-fs-nfs kmod-fs-vfat kmod-gpio-button-hotplug kmod-ipt-offload kmod-leds-gpio kmod-ledtrig-default-on kmod-ledtrig-netdev kmod-ledtrig-timer kmod-mt76x2u kmod-nf-nathelper kmod-rt2800-usb kmod-rtl8187 kmod-scsi-generic kmod-usb-ohci kmod-usb-storage-extras kmod-usb-uhci kmod-usb2 libbz2-1.0 libcurl4 libelf1 libffi libgdbm libgmp10 libiconv-full2 libltdl7 libnet-1.2.x libnl200 libustream-mbedtls20150806 libxml2 logd macchanger mtd nano ncat netcat nginx openssh-client openssh-server openssh-sftp-server openssl-util php7-cgi php7-fpm php7-mod-hash php7-mod-json php7-mod-mbstring php7-mod-openssl php7-mod-session php7-mod-sockets php7-mod-sqlite3 ppp ppp-mod-pppoe procps-ng-pkill procps-ng-ps python-logging python-openssl python-sqlite3 ssmtp tcpdump-mini uci uclibcxx uclient-fetch urandom-seed urngd usb-modeswitch usbreset usbutils wget wireless-tools wpad busybox libatomic1 libstdcpp6 -wpad-basic -dropbear -odhcp6c -odhcpd-ipv6only"

# if you don't install a custom build of busybox you have to install fdisk
# no rtl-sdr, no kmod-usb-net-*, no kmod-usb-serial-*, no kmod-rtl8192cu, no kmod-usb-acm, no kmod-usb-wdm, no kmod-lib-crc-itu-t, no ppp*, no python-*
PACKAGES_UNIVERSAL="iw at autossh base-files bash block-mount ca-certificates chat dnsmasq e2fsprogs ethtool firewall hostapd-utils ip6tables iwinfo kmod-crypto-manager kmod-fs-ext4 kmod-fs-nfs kmod-fs-vfat kmod-gpio-button-hotplug kmod-ipt-offload kmod-leds-gpio kmod-ledtrig-default-on kmod-ledtrig-netdev kmod-ledtrig-timer kmod-mt76x2u kmod-nf-nathelper kmod-rt2800-usb kmod-rtl8187 kmod-scsi-generic kmod-usb-ohci kmod-usb-storage-extras kmod-usb-uhci kmod-usb2 libbz2-1.0 libcurl4 libelf1 libffi libgdbm libgmp10 libiconv-full2 libltdl7 libnet-1.2.x libnl200 libustream-mbedtls20150806 libxml2 logd macchanger mtd nano ncat netcat nginx openssh-client openssh-server openssh-sftp-server openssl-util php7-cgi php7-fpm php7-mod-hash php7-mod-json php7-mod-mbstring php7-mod-openssl php7-mod-session php7-mod-sockets php7-mod-sqlite3 procps-ng-pkill procps-ng-ps ssmtp tcpdump-mini uci uclibcxx uclient-fetch urandom-seed urngd usb-modeswitch usbreset usbutils wget wireless-tools wpad busybox libatomic1 libstdcpp6 -wpad-basic -dropbear -odhcpd-ipv6only -ppp -ppp-mod-pppoe"

# add missing deps and custom busybox build
declare -a FORCE_PACKAGES=("libubus20191227_2019-12-27-041c9d1c-1" "busybox_1.30.1-6")

IMAGEBUILDER_FOLDER="$(realpath $IMAGEBUILDER_FOLDER)"
TOOL_FOLDER="$(realpath $(dirname $0)/../tools)"
BUILD_FOLDER="$(realpath $(dirname $0)/../build)"



# steps
prepare_builder () {
    echo "[*] Prepare builder"
    echo "******************************"
    echo ""

    PACKAGES_ARQ="${ARCHITECTURE}_24kc"
    DOWNLOAD_BASE_URL="https://github.com/xchwarze/wifi-pineapple-community/raw/main/packages/experimental"

    for TARGET in ${FORCE_PACKAGES[@]}; do
        PACKAGE_IPK="${TARGET}_${PACKAGES_ARQ}.ipk"
        PACKAGE_PATH="$IMAGEBUILDER_FOLDER/packages/$PACKAGE_IPK"
        if [ ! -f "$PACKAGE_PATH" ]; then
            echo "[+] Install: $TARGET"
            wget -q "$DOWNLOAD_BASE_URL/$PACKAGES_ARQ/$PACKAGE_IPK" -O "$PACKAGE_PATH"
        else
            echo "[+] Already exist: $TARGET"
        fi
    done

    echo "[+] Builder setup complete"
    echo ""
}

prepare_build () {
    echo "[*] Prepare build"
    echo "******************************"
    echo ""

    # clean
    rm -rf _basefw.* basefw.bin
    rm -rf "$BUILD_FOLDER"
    mkdir -p "$BUILD_FOLDER/release"

    # get target firmware
    # this work only with lastest binwalk version!
    if [[ "$FLAVOR" == "tetra" || "$FLAVOR" == "universal" ]]; then
        echo "[+] Downloading TETRA firmware..."
        wget -q https://github.com/xchwarze/wifi-pineapple-community/raw/main/firmwares/2.7.0-tetra.bin -O basefw.bin
        
        echo "[+] Unpack firmware for get file system"
        binwalk basefw.bin -e 
        binwalk _basefw.bin.extracted/sysupgrade-pineapple-tetra/root -e --preserve-symlinks
        mv _basefw.bin.extracted/sysupgrade-pineapple-tetra/_root.extracted/squashfs-root/ "$BUILD_FOLDER/rootfs-base"
    else
        echo "[+] Downloading NANO firmware..."
        wget -q https://github.com/xchwarze/wifi-pineapple-community/raw/main/firmwares/2.7.0-nano.bin -O basefw.bin

        echo "[+] Unpack firmware for get file system"
        binwalk basefw.bin -e --preserve-symlinks
        mv _basefw.bin.extracted/squashfs-root/ "$BUILD_FOLDER/rootfs-base"
    fi

    rm -rf _basefw.* basefw.bin
    #sudo chmod +x "$TOOL_FOLDER/*.sh"

    echo "[+] Copying the original files"
    "$TOOL_FOLDER/copier.sh" "$TOOL_FOLDER/../lists/$FLAVOR.filelist" "$BUILD_FOLDER/rootfs-base" "$BUILD_FOLDER/rootfs"
    if [ $? -ne 0 ]; then
        echo "[!] An error occurred while copying the original files. Check the log for errors."
        exit 1
    fi

    echo "[+] Patch file system"
    "$TOOL_FOLDER/fs-patcher.sh" "$ARCHITECTURE" "$FLAVOR" "$BUILD_FOLDER/rootfs"
    if [ $? -ne 0 ]; then
        echo "[!] An error occurred during the execution of the process. Check the log for errors."
        exit 1
    fi

    rm -rf "$BUILD_FOLDER/rootfs-base"
    echo ""
}

build () {
    echo "[*] Build"
    echo "******************************"
    echo ""

    # clean
    echo "[+] Clean last build data"
    #make clean
    rm -rf "$IMAGEBUILDER_FOLDER/tmp/"
    rm -rf "$IMAGEBUILDER_FOLDER/build_dir/target-*/root*"
    rm -rf "$IMAGEBUILDER_FOLDER/build_dir/target-*/json_*"
    rm -rf "$IMAGEBUILDER_FOLDER/bin/targets/*"

    # set selected packages
    echo "[+] Executing make"
    selected_packages="$PACKAGES_UNIVERSAL"
    if [[ "$FLAVOR" == "nano" ]];
    then
        selected_packages="$PACKAGES_NANO"
    elif [[ "$FLAVOR" == "tetra" ]];
    then
        selected_packages="$PACKAGES_TETRA"
    fi

    # build
    cd "$IMAGEBUILDER_FOLDER"
    make image PROFILE="$1" PACKAGES="$selected_packages" FILES="$BUILD_FOLDER/rootfs" BIN_DIR="$BUILD_FOLDER/release" > "$BUILD_FOLDER/release/make.log"
    if [ $? -ne 0 ]; then
        echo ""
        echo "[!] An error occurred in the build process. Check file release/make.log for more information."
        exit 1
    fi

    # add this second check for build process
    checkFwFileExist=$(ls "$BUILD_FOLDER/release"/*-sysupgrade.* 2>/dev/null | wc -l)
    if [ $checkFwFileExist -eq 0 ]; then
        echo ""
        echo "[!] OpenWRT finished the build process but no firmware was found. Check the release/make.log to see if the process was completed correctly."
        #exit 1
    fi
    echo ""
}



# implement this shitty logic
echo "Wifi Pineapple Cloner - builder"
echo "************************************** by DSR!"
echo ""

prepare_builder
prepare_build
build "$PROFILE"

echo "[*] Firmware folder: $BUILD_FOLDER/release"
echo "******************************"
ls -l "$BUILD_FOLDER/release"
echo ""

#!/bin/bash

#####################################################################################
################### Simple WLAN Sniffer Version 0.1 - under GPLv3 ###################
################### by Olivier Sebel                              ###################
###################                                               ###################
################### Thanks to the community for the ideas         ###################
################### integrated into this Script.                  ###################
#####################################################################################

##########################################################
#  INFORMATIONS                                          #
#   Simple script to get Informations about WLAN's in    #
#   your area with airmon and tshark.                    #
##########################################################

#######################
### Preparing tasks ###
#######################

#Check root rights (sudo) before execution.
if [ $(id -u) -ne 0 ]; then
        echo "You need root rights (sudo)."
        exit
fi

#Check if a program is installed.
program=(airmon-ng tshark)
for i in "${program[@]}"; do
       if [ -z $(command -v ${i}) ]; then
               echo "${i} is not installed."
               exit
       fi
done

#Read current date and time in hours and minutes into variable.
time=$(date +%d.%m.%Y-%H:%M)

############################
### Integrated functions ###
############################
#. libraries/


###############################
###    TOOL USAGE TEXT      ###
###############################

usage() {
        echo "Simple WLAN Sniffer Version 0.1 - under GPLv3"
        echo "by Olivier Sebel"
        echo "Use only with legal authorization and at your own risk!"
        echo "ANY LIABILITY WILL BE REJECTED!"
        echo ""
        echo "USAGE:"
        echo "  ./wlan_sniffer.sh -b"
        echo "  ./wlan_sniffer.sh -p"
        echo ""
        echo "OPTIONS:"
        echo "  -h, help - this text"
        echo "  -b - Gets the Informations of the Tshark Output filtered by Beacons"
        echo "  -p - Gets the Informations of the TShark Output filtered by Mobile Device Probes"
}

###############################
### GETOPTS - TOOL OPTIONS  ###
###############################

while getopts "bph" opt; do
        case ${opt} in
                h) usage; exit 1;;
                b) opt_arg1=1;;
                p) opt_arg2=1;;
               \?) echo "**Unknown option**" >&2; echo ""; usage; exit 1;;
                #:) echo "**Missing option argument**" >&2; echo ""; usage; exit 1;;
                *) usage; exit 1;;
        esac
        done
        shift $(( OPTIND - 1 ))

###############################
###        FUNCTIONS        ###
###############################

wlan_adapter_check(){

if  [[ 'ethtool wlan0 | grep -q "No such device" >> /dev/null 2>&1' ]]; then
	echo "No WLAN Adapter is installed. Exit Application."
	echo ""
	echo ""
fi

exit

}

wlan_filter() {
	wlan_adapter_check
        airmon-ng start wlan0 > /dev/null
        airmon-ng check kill > /dev/null

        tshark -i wlan0mon -T fields -e frame.time_relative \
                -e wlan.sa -e wlan.da -e wlan_radio.signal_dbm -e wlan.ssid -Y $1
}

####### MAIN PROGRAM #######

echo ""
echo "###########################################"
echo "####  Simple WLAN Sniffer Version 0.1  ####"
echo "###########################################"
echo ""

if [ "$opt_arg1" == "1" ]; then
        wlan_filter "((wlan.fc.type_subtype==0x08)&&!(wlan.tag.data=="'""'"))"

elif [ "$opt_arg2" == "1" ]; then
        wlan_filter "((wlan.fc.type_subtype==0x04)&&!(wlan.tag.data=="'""'"))"
fi

################### END ###################


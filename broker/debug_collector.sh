#!/bin/bash
# 
# Modified script of iBeacon Scan from Radius Networks referenced in this StackFlow anser:
# https://stackoverflow.com/questions/21733228/can-raspberrypi-with-ble-dongle-detect-ibeacons?lq=1
#
# Usage 
# 1. Set Defines
# 2. Call script:
#		no options: no output
#		-r		  : less information output
#       -v        : show whole data


#
# Defines
#
MQTT_CHANNEL=beacons
#
# End: Defines
#


#
# Requirements: mosquitto sqlite3 mosquitto-clients
#


#
# MAIN
#
if [[ $1 == "parse" ]]; then
  packet=""
  capturing=""
  while read data
  do
    #echo $data    # For Debug
    BROKER_TIME=$(date +"%s")
    NODE=`echo $data | sed 's/^.\{8\}\(.\{18\}\).*$/\1/'`
    SCAN_TIME=`echo $data | sed 's/^.\{26\}\(.\{11\}\).*$/\1/'`
    BEACON=`echo $data | sed 's/^.\{37\}\(.\{17\}\).*$/\1/'`
    RSSI=`echo $data | sed 's/^.\{55\}\(.\{3\}\).*$/\1/'`
    PAYLOAD=${data:58:${#data}}
	if [[ $2 == "-r" ]]; then
      echo "$NODE $SCANTIME $BEACON $RSSI"
    elif [[ $2 == "-v" ]]; then
      echo "$NODE $BEACON $RSSI $PAYLOAD" 
    fi
    sqlite3 beacons.sqlite "INSERT INTO beacons VALUES ('$BEACON', '$NODE', $RSSI, $SCAN_TIME, '$PAYLOAD')"
  done
else
  mosquitto_sub -h localhost -v -t $MQTT_CHANNEL | ./$0 parse $1
fi


#
# End: Main 
#


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
CHANGE_TIME=60			# time in seconds which has to be exeeded before Beacon is moved to another node in database
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
  # Store Data to sqlite
  if [[ $(sqlite3 beacons.sqlite "SELECT mac from beacons where mac='$BEACON'") ]]; then
    # BEACON exists in database
  	if [[ "$NODE" == "$(sqlite3 beacons.sqlite "SELECT node from beacons where mac='$BEACON'")" ]]; then
      # BACON still at same NODE -> update time, RSSI and payload
      #echo "$BEACON: same node -> updating time,rssi and payload"
      sqlite3 beacons.sqlite "UPDATE beacons SET rssi=$RSSI where mac='$BEACON'"
      sqlite3 beacons.sqlite "UPDATE beacons SET time=$SCAN_TIME where mac='$BEACON'"
      sqlite3 beacons.sqlite "UPDATE beacons SET payload='$PAYLOAD' where mac='$BEACON'"
    else
      # BEACON detected at other node -> make sure it is there
      DATA_TIME=$(sqlite3 beacons.sqlite "SELECT time from beacons where mac='$BEACON'")
      DATA_RSSI=$(sqlite3 beacons.sqlite "SELECT rssi from beacons where mac='$BEACON'")
      DELTA_TIME=$((SCAN_TIME - DATA_TIME))
      #echo "$BEACON: in locktime"   #DEBUG
      if [[ $DELTA_TIME -gt $CHANGE_TIME ]]; then
      	# node in database is old update node for beacon entry (time, rssi, node, payload)
      	#echo "$BEACON: old node database entry -> update node, time, RSSI payload" #DEBUG
      	sqlite3 beacons.sqlite "UPDATE beacons SET time=$SCAN_TIME where mac='$BEACON'"
      	sqlite3 beacons.sqlite "UPDATE beacons SET rssi=$RSSI where mac='$BEACON'"
      	sqlite3 beacons.sqlite "UPDATE beacons SET node='$NODE' where mac='$BEACON'"
      	sqlite3 beacons.sqlite "UPDATE beacons SET payload='$PAYLOAD' where mac='$BEACON'"
      elif [[ $RSSI -gt $DATA_RSSI ]]; then
        # node has changed in between CHANGE_TIME locktime because of stronger rssi at new -> update (time, rssi, node)
        #echo "$BEACON: higher rssi at new node -> update node, time, RSSI and payload" #DEBUG
      	sqlite3 beacons.sqlite "UPDATE beacons SET time=$SCAN_TIME where mac='$BEACON'"
      	sqlite3 beacons.sqlite "UPDATE beacons SET rssi=$RSSI where mac='$BEACON'"
      	sqlite3 beacons.sqlite "UPDATE beacons SET node='$NODE' where mac='$BEACON'"
      	sqlite3 beacons.sqlite "UPDATE beacons SET payload='$PAYLOAD' where mac='$BEACON'"      	
      fi
  	fi
  else
    # beacon not in database store
    #echo "$BEACON: new beacon detected -> insert to database (mac, node, rssi, time)" #DEBUG
  	sqlite3 beacons.sqlite "INSERT INTO beacons VALUES ('$BEACON', '$NODE', $RSSI, $SCAN_TIME, '$PAYLOAD')"
  fi
  done
else
  mosquitto_sub -h localhost -v -t $MQTT_CHANNEL | ./$0 parse $1
fi


#
# End: Main 
#


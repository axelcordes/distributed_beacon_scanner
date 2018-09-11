#!/bin/bash
# 
# Modified script of https://gist.github.com/elliotlarson/1e637da6613dbe3e777c
#
# Usage 
# 1. Set Defines
# 2. Call script:
#		no options: full information output
#		-r		  : less information output
#       -m        : send data to MQTT Broker (Node ID, Beacon MAC, RSSI, TIMESTAMP, PALOAD
#       -v        : show whole BT telegram
#       -p        : payload output


#
# Requirements: bc mosquitto-clients bluez-hcidump
#

 

#
# Defines
#
SCAN_DEVICE=hci0                          # define which BT dongle is used
#SCAN_FILTER="04\ 3E\ 2B\ 02\ 01\ 03\ 00"  # EDM Beacons
#SCAN_FILTER="043E2B02010300"  # EDM Beacons
#SCAN_FILTER="04\ 3E\ 2B\ 02\ 01\ 03\ "   # Less filter, receive Beacons
SCAN_FILTER=".{30}FFXXYY"   # set payload specific filter
#SCAN_FILTER=".{20} CB\ 0A\ 0F\ EE\ F3\ 0C" # Onlye specific MAC address: (semi-reverse BT MAC address!)
#SCAN_FILTER=".{20} CB\ 0A\ 0F\ EE\ F3\ 0C" # Onlye specific MAC address: (semi-reverse BT MAC address!)
RSSI_TRESHOLD=-100                         # Consider beacons only if RSSI is greater than treshold
MQTT_BROKER=192.168.169.1
MQTT_CHANNEL=beacons
#
# End: Defines
#


# Get rid of stack size limit
#echo "Stack size before start: `ulimit -s`"
#ulimit -s unlimited
#echo "Stack size run mode: `ulimit -s`"

#
# MAIN
#
# Get MAC of BT Scanner
NODE=`hciconfig $SCAN_DEVICE | grep -o -E '([[:xdigit:]]{1,2}:){5}[[:xdigit:]]{1,2}' `

# Process:
# 1. start hcitool lescan
# 2. begin reading from hcidump
# 3. packets span multiple lines from dump, so assemble packets from multiline stdin
# 4. for each packet, process
# 5. when finished (SIGINT): make sure to close out hcitool

halt_hcitool_lescan() {
  sudo pkill --signal SIGINT hcitool
}


trap halt_hcitool_lescan INT

process_complete_packet() (
  packet=${1//[\ |>]/}
  if [[ $packet =~ ^$SCAN_FILTER ]]; then
    TIMESTAMP=$(date +"%s")	      
    #echo $packet    # For DEBUG 
    RSSI=`echo $packet | sed 's/.*\(..\)/\1/' ` # last byte
    RSSI=`echo "ibase=16; $RSSI" | bc`
    RSSI=$[RSSI - 256]
    if [ "$RSSI" -gt "$RSSI_TRESHOLD" ];then         
      MAC1=`echo $packet | sed 's/^.\{24\}\(.\{2\}\).*$/\1/'`  
      MAC2=`echo $packet | sed 's/^.\{22\}\(.\{2\}\).*$/\1/'`
      MAC3=`echo $packet | sed 's/^.\{20\}\(.\{2\}\).*$/\1/'`
      MAC4=`echo $packet | sed 's/^.\{18\}\(.\{2\}\).*$/\1/'`
      MAC5=`echo $packet | sed 's/^.\{16\}\(.\{2\}\).*$/\1/'`
      MAC6=`echo $packet | sed 's/^.\{14\}\(.\{2\}\).*$/\1/'`
      MAC="$MAC1:$MAC2:$MAC3:$MAC4:$MAC5:$MAC6"
      PAYLOAD=${packet:32:-2}
      if [[ $2 == "-r" ]]; then
        echo "$MAC $RSSI"
      elif [[ $2 == "-v" ]]; then
        echo "$NODE $TIMESTAM $MAC $RSSI $PAYLOAD"  
      elif [[ $2 == "-m" ]]; then
        mosquitto_pub -h $MQTT_BROKER -t $MQTT_CHANNEL -m "$NODE $TIMESTAMP $MAC $RSSI $PAYLOAD"
        echo "$MAC $RSSI"
      elif [[ $2 == "-p" ]]; then
        echo "$MAC $RSSI $PAYLOAD" 
      else
        echo "NODE: $NODE TIME: $TIMESTAMP BEACON: $MAC RSSI: $RSSI "
      fi
    fi
  fi
)

read_blescan_packet_dump() {
  # packets span multiple lines and need to be built up
  packet=""
  while read line; do
    # packets start with ">"
    if [[ $line =~ ^\> ]]; then
      # process the completed packet (unless this is the first time through)
      if [ "$packet" ]; then
        process_complete_packet "$packet" $1 
      fi
      # start the new packet
      packet=$line
    else
      # continue building the packet
      packet="$packet $line"
    fi
  done
}

# begin BLE scanning
sudo hcitool -i $SCAN_DEVICE lescan --duplicates > /dev/null &
sleep 1
# make sure the scan started
if [ "$(pidof hcitool)" ]; then
  # start the scan packet dump and process the stream
  sudo hcidump --raw | read_blescan_packet_dump $1
else
  echo "ERROR: it looks like hcitool lescan isn't starting up correctly" >&2
  exit 1
fi

#
# End: Main 
#

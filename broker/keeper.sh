#!/bin/bash
#


#
# Defines
#
DELETE_TIME=180        # time in seconds before a beacon with old time in database will be deletet from it
CLEANUP_CYCLETIME=60   # time in secons in between databse cleanups
#
# End: Defines
#


#
# MAIN
#
while true; do
  sleep $CLEANUP_CYCLETIME
  TIME=$(date +"%s")
  for entry in $(sqlite3 beacons.sqlite "SELECT mac from beacons where node!='00:00:00:00:00:00'")
    do
      #echo "$entry"
      DATA_TIME=$(sqlite3 beacons.sqlite "SELECT time from beacons where mac='$entry'")
      DELTA_TIME=$((TIME - DATA_TIME))
      if [[ $DELTA_TIME -gt $DELETE_TIME ]]; then
        # cleanup database for old entries
        #echo "$entry: cleanup because database entry is older than $DELETE_TIME seconds"
        sqlite3 beacons.sqlite "UPDATE beacons SET node='00:00:00:00:00:00' where mac='$entry'"
        sqlite3 beacons.sqlite "UPDATE beacons SET rssi=-200 where mac='$entry'"
      fi
    done
  
done


#
# End: Main 
#

#!/bin/bash
#



#
# MAIN
#
if [ -f beacons.sqlite ]; then
for entry in $(sqlite3 beacons.sqlite "SELECT mac from beacons where node='00:00:00:00:00:00'")
do
  sqlite3 beacons.sqlite "DELETE from beacons where mac='$entry'"
done
fi
#
# End: Main 
#

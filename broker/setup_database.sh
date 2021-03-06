#!/bin/bash
#

if [ -f beacons.sqlite ]; then
  rm beacons.sqlite
fi
sqlite3 beacons.sqlite "CREATE TABLE beacons ( mac varchar(17), node varchar(17), rssi int, time int, payload varchar(58) );"

#
# HINTS
#

# look for data of element
#sqlite3 beacons.sqlite "SELECT beacon from beacons where mac='12:34:56:78:90:AA'"

# insert new elemnet
#sqlite3 beacons.sqlite "INSERT INTO beacons VALUES ('12:34:56:78:90:AA', 'B8:27:EB:29:6F:75', -60, '1532887302')"
#

# dump database
#sqlite3 beacons.sqlite  "SELECT * from beacons"

# update element
#sqlite3 beacons.sqlite "UPDATE beacons SET rssi=-50 where mac='12:34:56:78:90:AA'"

#check if exist
#sqlite3 beacons.sqlite "SELECT mac from beacons where mac='12:34:56:78:90:AB'"

# elete entry
#sqlite3 beacons.sqlite "DELETE from beacons where mac='0C:F3:EE:0F:0A:CB'"

#
# End: HINTS
#
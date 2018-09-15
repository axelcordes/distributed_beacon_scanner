# Broker (linux)
The main functionality of the whole system is integrated on the broker since it collects the data from all nodes around and stored the data in a sqliter database.


## Requirements
For Raspberry Pi
<pre><code>sudo apt-get install mosquitto sqlite3 mosquitto-clients</code></pre>

## Setup Database
<pre><code>./setup_database.sh</code></pre>

## Operation
For the broker, two scripts are available:

### Regular Mode
In this mode only one message for each beacon is stored in the database.
If a new message is received which comes from a beacon which is already know (by the same node), only RSSI and BLE payload information will be updated.

Since it could be possible, that two or more nodes receive BLE telegram from one beacon or a beacon moves around and will be recognized by another node, the broker has to options to change the node in that cases. 
If the entry in the database which belongs to the other node is older (grater than the configured "CHANGE_TIME"), the node is change. This prevent the location entry in the database from jumping between two nodes. However, if the RSSI value of the new node ist stronger than the RSSI value of the other node, the location is changed immediately. 

<pre>./collector.sh [Parameter]<code>
</code></pre>
Parameters
<table class="tg">
  <tr>
    <th class="tg-0pky">Parameter</th>
    <th class="tg-0pky">Description</th>
  </tr>
  <tr>
    <td class="tg-0pky">-v</td>
    <td class="tg-0pky">Verbose output</td>
  </tr>
  <tr>
    <td class="tg-0pky">-r</td>
    <td class="tg-0pky">Reduced Debug </td>
  </tr>
</table>
Use now parameter if not output is desired.

### Debug Mode
Here, all via MQTT received telegram were stored in the database message per message. 
<pre>./debug_collector.sh [Parameter]<code>
</code></pre>
Parameters
<table class="tg">
  <tr>
    <th class="tg-0pky">Parameter</th>
    <th class="tg-0pky">Description</th>
  </tr>
  <tr>
    <td class="tg-0pky">-v</td>
    <td class="tg-0pky">Verbose output</td>
  </tr>
  <tr>
    <td class="tg-0pky">-r</td>
    <td class="tg-0pky">Reduced Debug </td>
  </tr>
</table>
Use now parameter if not output is desired.

## Show database 
<pre>show_database.sh<code>
</code></pre>

## Export database to CSV
<pre>csv_database.sh > filename.csv<code>
</code></pre>

## Mark beacons "not seen anymore"
The script:
<pre>keeper.sh<code>
</code></pre>
is used to mark entries as "not seen anymore". The time can be configured in the script. For entries which are older than the configured time, RSSI is set to "-200" and the MAC of the Node is set to "00:00:00:00:00:00".
Since a sqlite database is used, it could be possible, that a running collector script and a keeper script blocks each other from writing to the database. To prevent that, another type of database is required.

## Cleanup databse
This script:
<pre>clean_database.sh<code>
</code></pre>
deletes all entries in the database which are "not seen anymore".
Since a sqlite database is used, it could be possible, that a running collector script and a claenup script blocks each other from writing to the database. To prevent that, another type of database is required.

# Node (linux)
Scanner Script for Linux Nodes (e. g. Raspberry Pi).
I recommend not to use a Pi Zero in BLE crowdy conditions. I had several "segfaults" during operations with a Zero. I think, this is related to the single core processor on the Pi Zero since I have no Problems with Pi  version 3 running this script.

## Requirements
For Raspberry Pi
<pre><code>sudo apt-get install bc mosquitto-clients bluez-hcidump sed</code></pre>
Edit the script and change mqqt broker information according your network setup as well es the beacon filter.

## Operation
<pre>./beacon_scan.sh [Parameter]<code>
</code></pre>
Parameters
<table class="tg">
  <tr>
    <th class="tg-0pky">Parameter</th>
    <th class="tg-0pky">Description</th>
  </tr>
  <tr>
    <td class="tg-0pky">-m</td>
    <td class="tg-0pky">MQTT Forward</td>
  </tr>
  <tr>
    <td class="tg-0pky">-r</td>
    <td class="tg-0pky">Reduced Debug (w/o MQTT)</td>
  </tr>
  <tr>
    <td class="tg-0pky">-v</td>
    <td class="tg-0pky">Verbose Debug (w/o MQTT)</td>
  </tr>
  <tr>
    <td class="tg-0lax">-p</td>
    <td class="tg-0lax">Payload Debug (w/o MQTT)</td>
  </tr>
</table>
For Operation as Node:
<pre>./beacon_scan.sh -m<code>
</code></pre>
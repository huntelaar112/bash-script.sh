#!/bin/bash
# execute at start up as root

## wait until finish config veth
sleep 25s
for veth in $(ip a | grep veth | cut -d' ' -f 2 | rev | cut -c2- | rev | cut -d '@' -f 1 )
do
    sudo ip link set $veth down
done

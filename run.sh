#!/bin/bash

source network-check.sh

trap "cd /tmp; twingate report; cat /var/log/twingated.log; twingate stop" EXIT;

sleep 5
twingate --version
twingate setup --headless /secret/credentials.json
twingate start

while true; do
    sleep 60;
    check_range
    if [ $RESULT == 1 ]
    then
        exit 1
    fi
done

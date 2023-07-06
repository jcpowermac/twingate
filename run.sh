#!/bin/bash

source network-check.sh

trap "cd /tmp; twingate report; cat /var/log/twingated.log; twingate stop" EXIT;


# hostname is too similar, keeping for ref.
#filenumber=$(shuf -n 1 -i 1-4 --random-source <(printf "%s" "$HOSTNAME"))

filenumber=$(shuf -n 1 -i 1-4)

sleep 5
twingate --version
twingate setup --headless "/secret/credentials${filenumber}.json"
twingate config log-level debug
twingate start

while true; do
    sleep 60;
    check_range
    if [ "$RESULT" == 1 ]
    then
        exit 1
    fi
done

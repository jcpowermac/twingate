#!/bin/bash

check_range () {
    RESULT=0
    for (( SEG=$SEG_START; SEG<=$SEG_END; SEG++ )); do
        ping -c 1 192.168.$SEG.1
        if [ $? -eq 0 ]; then
            echo "Segment $SEG responding"
        else
            echo "!!! Segment $SEG not responding"
            RESULT=1
        fi
    done
}

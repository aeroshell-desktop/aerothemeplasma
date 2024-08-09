#!/bin/bash

TIME=8
echo "Running $TIME-second test..."
sudo plymouthd ; sudo plymouth --show-splash ; for ((I=0; I<$TIME; I++)); do sleep 1 ; sudo plymouth --update=test$I ; done ; sudo plymouth --quit

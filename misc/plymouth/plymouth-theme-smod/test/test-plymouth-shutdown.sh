#!/bin/bash

TIME=3

echo "Running $TIME-second test..."

sudo plymouthd
sudo plymouth change-mode --shutdown


sudo plymouth --show-splash

for ((I=0; I<$TIME; I++)); do sleep 1 ; sudo plymouth --update=test$I ; done

sudo plymouth --quit

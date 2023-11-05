#!/bin/bash

mosquitto_sub -N -h $MQTT_HOST -t $MQTT_TOPIC | rtlamr-collect &

while true; do
  pgrep -x mosquitto_sub >/dev/null || killall rtlamr-collect
  pgrep -x rtlamr-collect >/dev/null || exit 1
  sleep 60
done

#!/bin/bash

rtlamr | rtlamr-collect &

while true; do
  pgrep -x rtlamr >/dev/null || killall rtlamr-collect
  pgrep -x rtlamr-collect >/dev/null || exit 1
  sleep 60
done

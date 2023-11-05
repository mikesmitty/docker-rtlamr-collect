#!/bin/bash

rtl_tcp &
rtlamr | rtlamr-collect &

while true; do
  pgrep -x rtlamr >/dev/null || killall rtlamr-collect rtl_tcp
  pgrep -x rtlamr-collect >/dev/null || exit 1
  sleep 60
done

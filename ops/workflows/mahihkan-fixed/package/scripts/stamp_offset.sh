#!/bin/sh
IGNITION="2025-12-04 00:00:00"
now=$(date +%s); start=$(date -d "$IGNITION" +%s); o=$((now-start))
D=$(printf "%03d" $((o/86400)))
H=$(printf "%02d" $(( (o%86400)/3600 )))
M=$(printf "%02d" $(( (o%3600)/60 )))
S=$(printf "%02d" $(( o%60 )))
echo "$D:$H:$M:$S"

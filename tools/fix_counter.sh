#!/bin/bash -e

# if there's a divergence between influxdb->water_counter->sum(values), this
# script can be used to fix the difference
#
# it requires the real reading from the phisical water counter and it will
# add a new raw with the difference to influxdb

counter_current=$1

if [[ -z $counter_current ]]; then
   echo "./fix_counter.sh <current value from counter>"
   exit 1
fi

bmax_sum=$(curl -s bmax:8889/getSum/water_counter 2>&1)
diff=$((counter_current - bmax_sum ))

echo "given actual value is $counter_current"
echo "bmax sum is $bmax_sum"

timestamp=$(date +%s)
curl  --header "device_id: water_counter" bmax:8889/add/$timestamp:$diff

echo "Added new row to water_counter with value $diff"

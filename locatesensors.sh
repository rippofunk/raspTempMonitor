#!/bin/sh
while true 
do

echo "The Current Temp is:";

for dir in /sys/bus/w1/devices/28-*
do
  temp=`cat $dir/w1_slave | grep -o t=.* `;
 echo "$dir \n\r";
  temp2=${temp#t=};
  temp3=`echo "scale=3;$temp2/1000" | bc` ;
#  echo "$temp3 C \n\r";
  nfarenh=`echo "($temp3 * 1.8) + 32" | bc`;
  echo "$nfarenh F ";
done

sleep 5

done


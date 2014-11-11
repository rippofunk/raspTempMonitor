#!/bin/bash

# this script runs on boot
# add this to your cronscript 
# @reboot /home/pi/tempLogger.sh &

#its long winded but easy to understand and floow and modify for your use

#comparison variables, holds current 1/1000c temp for action comparison
basementtemp=0;
desktemp=0;
outsidetemp=0;
whtemp=0;
while true 
do

#using the locatesensors.sh script i was able to determine which sensor was which by running the script and heating up each with my finger tip
#once i saw a spike in one of the sensors, i labled it accordingly

#since i want to log the temps i need to have alook up of which sensor is which
whtempstring=`cat /sys/bus/w1/devices/28-0000053b1fe4/w1_slave`;
btempstring=`cat /sys/bus/w1/devices/28-0000052f59ee/w1_slave`;
dtempstring=`cat /sys/bus/w1/devices/28-0000052f6c24/w1_slave`;
otempstring=`cat /sys/bus/w1/devices/28-000005300ad8/w1_slave`;


function converttof (){

}

#set the counter to determine what string gets printed
fcount=0;
for f in "$btempstring" "$dtempstring" "$otempstring" "$whtempstring"
do
        # there is a YES if there is a valid temp, else its a no
        if [[ $f == *YES* ]]
        then
                # seperate out the temp part
                temppart=`echo $f | grep -o t=.* `;

                # remove the t= from the string leaving the temp in 1/1000c 
                ctemp=${temppart#t=};

                # use bc to do the float number division
                ctempdec=`echo "scale=3;$ctemp/1000" | bc` ;

                # convert C to F
                nfarenh=`echo "($ctempdec * 1.8) + 32" | bc`;

                # check which string (or sensor) we are seeing
                if [ $fcount -eq 0 ] 
                then 
                        #check if there is .250 difference in C (about .4 f change)
                        toprange=`expr $basementtemp + 250`;
                        bottomrange=`expr $basementtemp - 250`;
                        if [ $ctemp -gt $toprange -o $ctemp -lt $bottomrange  ]
                        then
                                logit=`wget -qO- "http://yourwebsite.com/loggingScript.php?seccode=securitycode&temp=$nfarenh&tempID=Basement" &>/dev/null`;
                                basementtemp=$ctemp;
                        fi
                fi
                if [ $fcount -eq 1 ] 
                then 
                        #check if there is .250 difference in C (about .4 f change)
                        toprange=`expr $desktemp + 250`;
                        bottomrange=`expr $desktemp - 250`;
                        if [ $ctemp -gt $toprange -o $ctemp -lt $bottomrange  ]
                        then
                                logit=`wget -qO- "http://yourwebsite.com/loggingScript.php?seccode=securitycode&temp=$nfarenh&tempID=Desk" &>/dev/null`;
                                desktemp=$ctemp;
                        fi
                fi
                if [ $fcount -eq 2 ]
                then
                        #check if there is .250 difference in C (about .4 f change)
                        toprange=`expr $outsidetemp + 250`;
                        bottomrange=`expr $outsidetemp - 250`;
                        if [ $ctemp -gt $toprange -o $ctemp -lt $bottomrange  ]
                        then
                                logit=`wget -qO- "http://yourwebsite.com/loggingScript.php?seccode=securitycode&temp=$nfarenh&tempID=Outside" &>/dev/null`;
                                outsidetemp=$ctemp;
                        fi
                fi
                if [ $fcount -eq 3 ]
                then
                        #check if there is .250 difference in C (about .4 f change)
                        toprange=`expr $whtemp + 250`;
                        bottomrange=`expr $whtemp - 250`;
                        if [ $ctemp -gt $toprange -o $ctemp -lt $bottomrange  ]
                        then
                                logit=`wget -qO- "http://yourwebsite.com/loggingScript.php?seccode=securitycode&temp=$nfarenh&tempID=Water Heater" &>/dev/null`;
                                whtemp=$ctemp;
                        fi
                fi


        fi

# increment the counter
fcount=`expr $fcount + 1`;

done

sleep 60

done 

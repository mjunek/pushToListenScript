#!/bin/bash

SCRIPT_DIR="$(dirname "$(readlink -f "$0")")"
. $SCRIPT_DIR/pushToListenConfig.sh

echo Starting Press-to-Listen CRON script
echo
CURRENT_TIME=$(date +%s)

echo Current time is $CURRENT_TIME
echo Checking status file
if [ -f $STATUS_FILE ]; then
	LAST_PRESSED=$(<$STATUS_FILE)
	echo Last pressed at $LAST_PRESSED
fi

CURRENT_ACTION=IDLE
if [ -f $CURRENT_ACTION_FILE ]; then
	CURRENT_ACTION=$(<$CURRENT_ACTION_FILE)
	echo We are currently in $CURRENT_ACTION action
fi

if [ $LAST_PRESSED -eq 0 ]; then
	echo Button has not been pressed, nothing to do
	exit
fi;

FIRST_REMINDER_TIME=$(expr $LAST_PRESSED + $AMP_ACTIVE_SECS - $FIRST_REMINDER_SECS)
SECOND_REMINDER_TIME=$(expr $LAST_PRESSED + $AMP_ACTIVE_SECS - $SECOND_REMINDER_SECS)
AMP_OFF_TIME=$(expr $LAST_PRESSED + $AMP_ACTIVE_SECS)

echo Checking next action
echo Current Time: $CURRENT_TIME :: Off Time: $AMP_OFF_TIME :: First Reminder: $FIRST_REMINDER_TIME :: Second Reminder: $SECOND_REMINDER_TIME
if [ $CURRENT_TIME -gt $AMP_OFF_TIME ]; then
	echo Time to turn off the amp - maybe
	if  [ "x$CURRENT_ACTION" != "xIDLE" ]; then 
		TOPIC=cbus/write/$CBUS_NETWORK/56/$CBUS_GROUP/switch
		echo Sending MQTT power off command
		echo -- mosquitto_pub -h $MQTT_HOST -m Off -t $TOPIC
		mosquitto_pub -h $MQTT_HOST -m OFF -t $TOPIC
		echo Disable all playing ESEQs
		curl -XGET http://$FPP_HOST/api/command/Effects\%20Stop
		echo
		echo Start playing idle sequence - $IDLE_ESEQ
		curl -XGET http://$FPP_HOST/api/command/Effect\%20Start/$IDLE_ESEQ/$PROP_START_CHANNEL/1
		echo
		echo IDLE > $CURRENT_ACTION_FILE
	else
		echo Already off. Not sending again
	fi
	echo Remove last active time
	echo 0 > $STATUS_FILE

elif  [ $CURRENT_TIME -gt $SECOND_REMINDER_TIME ]; then
	echo Second reminder time exceeded
	if  [ "x$CURRENT_ACTION" != "xSECOND" ]; then
		echo Disable all playing ESEQs
		curl -XGET http://$FPP_HOST/api/command/Effects\%20Stop
		echo
		echo Start playing second reminder sequence - $SECOND_REMINDER_ESEQ
		curl -XGET http://$FPP_HOST/api/command/Effect\%20Start/$SECOND_REMINDER_ESEQ/$PROP_START_CHANNEL/1
		echo
		echo SECOND > $CURRENT_ACTION_FILE
	else
		echo Already in second reminder state.
	fi

elif  [ $CURRENT_TIME -gt $FIRST_REMINDER_TIME ]; then
	echo First Reminder time exceeded
	if  [ "x$CURRENT_ACTION" != "xFIRST" ]; then
		echo Disable all playing ESEQs
		curl -XGET http://$FPP_HOST/api/command/Effects\%20Stop
		echo
		echo Start playing idle sequence - $FIRST_REMINDER_ESEQ
		curl -XGET http://$FPP_HOST/api/command/Effect\%20Start/$FIRST_REMINDER_ESEQ/$PROP_START_CHANNEL/1
		echo
		echo FIRST > $CURRENT_ACTION_FILE
	else
		echo Already in first reminder state.
	fi

else
	echo Have not hit any timers yet. Nothing to do
fi


echo Done, exiting
exit 0

#!/bin/bash

SCRIPT_DIR="$(dirname "$(readlink -f "$0")")"
. $SCRIPT_DIR/pushToListenConfig.sh

echo Starting Press-to-Listen action script
echo
LAST_PRESSED=0
CURRENT_TIME=$(date +%s)

echo Current time is $CURRENT_TIME
echo Checking status file
if [ -f $STATUS_FILE ]; then
	LAST_PRESSED=$(<$STATUS_FILE)
	echo Last pressed at $LAST_PRESSED
fi

if [ $LAST_PRESSED -gt 0 ] && [ $EXTEND_ANYTIME -eq 0 ]; then
	echo Checking to see if we can extend or not
	echo "expr $LAST_PRESSED + $AMP_ACTIVE_SECS - $FIRST_REMINDER_SECS"
	REMINDER_TIME=$(expr $LAST_PRESSED + $AMP_ACTIVE_SECS - $FIRST_REMINDER_SECS)
	echo Cur: $CURRENT_TIME  - Allowed At: $REMINDER_TIME
	if [ $CURRENT_TIME -lt $REMINDER_TIME ]; then
		echo Extension not yet allowed
		exit
	fi
	echo Extension allowed
fi


if [ $LAST_PRESSED -eq 0 ]; then
	echo First press, switching on amp
	TOPIC=cbus/write/$CBUS_NETWORK/56/$CBUS_GROUP/switch
	echo Sending MQTT power on command
	echo -- mosquitto_pub -h $MQTT_HOST -m ON -t $TOPIC
	mosquitto_pub -h $MQTT_HOST -m ON -t $TOPIC
	echo INITIAL > $CURRENT_ACTION_FILE
fi

echo Disable all playing ESEQs
curl -XGET http://$FPP_HOST/api/command/Effects\%20Stop
echo
echo Writing current time to last press time
echo $CURRENT_TIME > $STATUS_FILE

echo Done, exiting
exit 0

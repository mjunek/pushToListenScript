#!/bin/bash


# Timers

# How long we play music for
AMP_ACTIVE_SECS=600

# When do we kick off the first reminder (Seconds remaining)
FIRST_REMINDER_SECS=120

# When do we kick off the second reminder (Seconds remaining)
SECOND_REMINDER_SECS=60

# Status file for storing button push time
STATUS_FILE=/tmp/amp_script_status
CURRENT_ACTION_FILE=/tmp/amp_script_currentaction

# Can we extend anytime (1) or only during reminder periods (0)
EXTEND_ANYTIME=0

# FPP Hostname for ESEQ
FPP_HOST=localhost

# ESeq to play when amp is off (button illuminated)
IDLE_ESEQ=SingleChannel1min-On

# Eseq to play from first reminder time to off/second reminder (slow flash)
FIRST_REMINDER_ESEQ=SingleChannel1min-1Hz

# Eseq to play from second reminder time to off (fast flash)
SECOND_REMINDER_ESEQ=SingleChannel1min-Fast

# Prop start channel to play eseq on
PROP_START_CHANNEL=1

# Cbus network and group for amplifier power outlet
CBUS_NETWORK=253
CBUS_GROUP=12

# MQTT Host for CBUS commands
MQTT_HOST=172.19.85.251

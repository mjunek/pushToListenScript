# pushToListenScript
Push to Listen timer script for FPP.
A simple script which does a few things for Push To Listen.
It expects a button to be connected to a GPIO, and based on the effects, was designed to use a single GPIO as output. That said, there's no restriction on the effect sequence played or which channels it can use.
The amplifier is expected to be controlled by CBUS system, which is accessible via MQTT commands, through Mosquitto, CGateWeb and CGate, and then onto the CBus network with either a PC Interface or CNI.

When button is pusshed, FPP will trigger the ```pushToListenButtonAction.sh``` script
* if the amplifier is off, it will switch it on for a preset amount of time, and switch off the button in the LED (stop all ESEQ on FPP)
* If the amp is already on, it will reset the "on" time if either
   - Extend Anytime is enabled -or-
   - We are in the reminder periods
   
The ```pushToListenCronScript.sh``` file is triggered every two seconds from SystemD (as defined in the unit files).
This checks when the button was pressed and will perform the following actions:
* If the maximum on time has exceeded
   - Switch off the amp
   - Set the running eseq to the idle sequence - usally an "on" effect
* If the second reminder time has exceeded
  - Run the second reminder ESEQ - usually a fast flash
* If the first reminder time has exceeded
  - Run the first reminder ESEQ - usually a slow flash


## Install instructions
* Copy the shell scripts to ```/home/fpp/media/scripts```
* Copy the systemd unit files (.service, .timer) to ```/etc/systemd/system```
* In FPP, set your GPIO for the button to trigger the ```pushToListenButtonAction.sh``` script
* Also define your output GPIO and give it a channel. This should be reflected in the config file below
* Upload the three ESEQ files needed. I have included three basic ones that will blink a single channel.
* Modify the configuration in ```pushToListenConfig.sh```
    - Comments are in the file as to what the configuratrion options do
    - Setting the timers, mqtt details and esequences are important
* Set up your output GPIO with an appropriate FET and external circuitry to drive your status lamp
* Reboot the system (required for the systemd changes)

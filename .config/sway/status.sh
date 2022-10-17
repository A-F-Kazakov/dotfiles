#!/bin/env bash

#                   
# date  
date=$(date "+%a %d/%m")
time=$(date "+%H:%M")
date_time=" $date  $time"

# battery            
battery_capacity=$(cat /sys/class/power_supply/BAT0/capacity)
battery_status=$(cat /sys/class/power_supply/BAT0/status)

if [ "$battery_status" == "Charging" ]; then
	battery_info=" $battery_capacity%"
else
	if [ "$battery_status" == "Full" ]; then
		battery_info=''
	else
		battery_info=" $battery_capacity%"
	fi
fi

# volume     
current_level=$(pactl list sinks | tr ' ' '\n' | grep -m1 '%')
audio_volume=" $current_level"

# brightness 
brightness_level=$(cat /sys/class/backlight/intel_backlight/brightness)
brightness_max_level=$(cat /sys/class/backlight/intel_backlight/max_brightness)
brightness_value=$((brightness_level*100/brightness_max_level))
br_info="  $brightness_value%"

# processor    1ed
cpu_usage=$(grep 'cpu ' /proc/stat | awk '{usage=($2+$4)*100/($2+$4+$5)} END {print substr(usage, 1, 5) "%"}')
cpu_temp=$(cat /sys/class/thermal/thermal_zone0/temp)
cpu_info=" $cpu_usage  $(($cpu_temp/1000))"

# harddrive  
hw_root_usage=$(df /dev/sda2 | tail -n 1 | awk '{print $5}')
hw_home_usage=$(df /dev/sda4 | tail -n 1 | awk '{print $5}')
hw_info="  / $hw_root_usage   home $hw_home_usage"

# network       
wifi_name=$(networkctl status wlp2s0 | sed -n 's/.*WiFi.* \(.*\) (.*)/\1/p')

if [ -z "$wifi_name" ]; then
	wifi_info=''
else
	wifi_info=" $wifi_name"
fi

# language

keyboard='1:1:AT_Translated_Set_2_keyboard'
current_language=$(swaymsg -r -t get_inputs | grep '1:1:AT_Translated_Set_2_keyboard' -A 10 | grep xkb_active_layout_name | awk -F'"' '{print $4}')

# microphone  

# bar
echo  $wifi_info ' | ' $current_language ' | ' $hw_info ' | ' $cpu_info '|' $br_info '|' $audio_volume '|' $battery_info '|' $date_time


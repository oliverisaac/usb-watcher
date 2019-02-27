#!/bin/bash

drive="$1"
{
	date
	ls -altr "$drive"
} | logger -t usb-watcher

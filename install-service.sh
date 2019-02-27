#!/usr/bin/env bash

command=$( echo "${@}" )
mypath="$( dirname "$( readlink -f "$0" )" )"

command="${command:-$mypath/example-callable.sh}"

sudo apt-get install usbmount -y
sudo sed -i"" '/^MountFlags=/s/slave/shared/' /lib/systemd/system/systemd-udevd.service

sudo tee /etc/systemd/system/usb-watch.service <<EOF 
[Unit]
After=network.target

[Service]
ExecStart=${mypath}/usb-watch --watch --call-this="$command"
User=root
ReadWriteDirectories=-/var/tmp

[Install]
WantedBy=default.target
EOF

sudo tee /etc/udev/rules.d/90-usbstick.rules <<EOF
SUBSYSTEMS=="usb",KERNEL=="sd[a-h]1",SYMLINK+="usbkey", RUN+="${mypath}/usb-watch-handler"
SUBSYSTEMS=="usb",KERNEL=="sd[a-h]1",ACTION=="remove", RUN+="${mypath}/usb-watch-handler"
EOF


sudo systemctl enable usb-watch.service
sudo systemctl restart usb-watch.service

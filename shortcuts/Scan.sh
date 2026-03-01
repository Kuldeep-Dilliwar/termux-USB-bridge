#!/data/data/com.termux/files/usr/bin/bash

USB_DEVICE=$(termux-usb -l | grep -o "/dev/bus/usb/[0-9]*/[0-9]*" | head -n 1)

if [ -z "$USB_DEVICE" ]; then
    termux-toast "Error: Scanner not found. Check USB connection."
    exit 1
fi

termux-toast "Starting Universal Scan..."
termux-usb -r -e $PREFIX/bin/run_scanner.sh "$USB_DEVICE"

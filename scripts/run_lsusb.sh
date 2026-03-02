#!/data/data/com.termux/files/usr/bin/bash

FD=$1
USB_PATH=$TARGET_USB_PATH

if [ -z "$FD" ]; then
    echo "Error: No File Descriptor provided."
    exit 1
fi

DEV=$(echo "$USB_PATH" | cut -d'/' -f6 | sed 's/^0*//')
[ -z "$DEV" ] && DEV="2"
DEV_STR=$(echo "$USB_PATH" | cut -d'/' -f6)
[ -z "$DEV_STR" ] && DEV_STR="002"

echo "1. Cloning Native Hardware to Sysfs..."
universal_clone "$FD" "$DEV"

if [ "$BRIDGE_NATIVE" == "1" ]; then
    echo "2. Building Native Universal Bridge..."
    # Point entirely to the PREFIX/tmp directory installed by make
    cp "$PREFIX/share/termux-usb-bridge/usb_bridge_native_template.c" "$PREFIX/tmp/usb_bridge_native.c"
    sed -i "s/__FD__/$FD/g" "$PREFIX/tmp/usb_bridge_native.c"
    sed -i "s/__DEV__/$DEV_STR/g" "$PREFIX/tmp/usb_bridge_native.c"
    
    gcc -shared -fPIC -o "$PREFIX/bin/libusb_bridge_native.so" "$PREFIX/tmp/usb_bridge_native.c" -ldl
    
    echo "3. Running lsusb $BRIDGE_LSUSB_ARGS natively..."

    export TERMUX_USB_FD="$FD"
    export LIBUSB_DEBUG="${BRIDGE_LOG_LEVEL:-0}"
    export LD_PRELOAD="$PREFIX/bin/libusb_bridge_native.so"
    
    lsusb $BRIDGE_LSUSB_ARGS
else
    echo "2. Building Universal Bridge for proot..."
    proot-distro login ubuntu \
        -- env TERMUX_USB_FD="$FD" TERMUX_USB_DEV="$DEV_STR" bash -c "
        # Pull straight from the local /tmp folder
        cp /tmp/usb_bridge_template.c /tmp/usb_bridge.c
        sed -i \"s/__FD__/\$TERMUX_USB_FD/g\" /tmp/usb_bridge.c
        sed -i \"s/__DEV__/\$TERMUX_USB_DEV/g\" /tmp/usb_bridge.c
        gcc -shared -fPIC -o /usr/local/lib/libusb_bridge.so /tmp/usb_bridge.c -ldl
    "

    echo "3. Running lsusb $BRIDGE_LSUSB_ARGS through Custom libusb & C-Bridge (proot)..."
    proot-distro login ubuntu \
        --bind "$HOME/fake_usb/sys/bus/usb:/sys/bus/usb" \
        --bind "$HOME/fake_usb/dev/bus/usb:/dev/bus/usb" \
        -- env LD_LIBRARY_PATH="/usr/local/lib" TERMUX_USB_FD="$FD" LIBUSB_DEBUG="${BRIDGE_LOG_LEVEL:-0}" LD_PRELOAD="/usr/local/lib/libusb_bridge.so" \
        bash -c "lsusb $BRIDGE_LSUSB_ARGS -s 1:$DEV"
fi

# termux-USB-bridge 
*⚠️⚠️⚠️ disclaimer: `run this setup at your own risk` ; if you open any app in doing this or printing or scanning, the opened app might say `the device is rooted`, i found `my official mobile carrier app` showing devices rooted message and `it instantly logged me off my account`, but it was fixed by `clearing the data` of the `infected` app, also `I have no idea why that happend`, ⚠️⚠️⚠️)*
# (HP) Printer And Scanner support for Termux (no-root):
## **1. In Termux.**
```
pkg update -y && pkg install -y make git
git clone https://github.com/Kuldeep-Dilliwar/termux-USB-bridge.git
cd termux-USB-bridge
make install
```

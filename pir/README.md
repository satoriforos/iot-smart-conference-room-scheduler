ESP8266 PIR
###########

Requirements:
=============
NodeMCU Dev Kit 
(or another board that exposes the ADC "TOUT")
http://www.seeedstudio.com/depot/NodeMCU-v2-Lua-based-ESP8266-development-kit-p-2415.html

Leegoal 5x Pyroelectric Infrared PIR Motion Sensor Detector Module
(Or other passive infrared sensor)
http://www.amazon.com/gp/product/B008AESDSY

Installation
============

Mac OS X
---------
On Mac, you'll need the serial driver to talk to the NodeMCU Dev kit:
http://www.wch.cn/download/CH341SER_MAC_ZIP.html

ESPlorer tool to upload files to the NodeMCU and talk to the console
http://esp8266.ru/esplorer/#download

Download or clone the source code to a folder

Plug the output of the PIR into the TOUT of the NodeMCU Dev kit
Power everything
Burn the files from the ESPtool onto the NodeMCU dev kit.

Reboot ESP

log in through serial and type:
dofile("compile.lua")


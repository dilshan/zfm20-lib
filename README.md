# zfm20-lib
### Introduction ###
This is x86 native library to communicate with Zhiantec's ZFM-20 series fingerprint modules over serial interface(s) and obtain captured fingerprint images from the sensor module. This library provides simple API to check availability of sensor, capture and download images from fingerprint reader module.
This fingerprint capture library is implemented using [Lazarus](http://www.lazarus-ide.org/) and it support for *C/C++*, *Lazarus*/*FPC*, *Delphi* and *Microsoft .net* framework based programming languages. Compiled binaries of this project are available for Microsoft Windows operating system. 

### Fingerprint reader module ###
This version of ZFM-20 Fingerprint capture library is [tested](https://drive.google.com/file/d/0B84TrX2d3zu8ZjJjZzEtSEtpTTQ/view) with ZFM-20 series serial fingerprint module with *[CH340G](http://jayakody2000lk.blogspot.com/2015/07/usb-to-33v-5v-serial-ttl-adapter.html)* USB to serial converter. Generally this library is design to work with any USB to serial converter which including *FT232*, *CP2101*, etc. 

### License ###
- ZFM-20 Fingerprint capture library is released under the terms of [MIT License](https://opensource.org/licenses/MIT). 
- Sample applications of this project use an icon file which is designed by [IconsMind](http://www.iconsmind.com). 
- This project use [Ararat Synapse](http://synapse.ararat.cz/doku.php) for serial communication.
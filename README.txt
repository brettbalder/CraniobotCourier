The Craniobot Courier is a bare-bones GUI for interfacing with a CNC machine
running g2core. It borrows many aspects from other Gcode senders, such as:

       * Automatic Flow Control (using linemode protocol)
       * Position Monitoring
       * Machine Status and Error Reporting
       * A Serial Command Terminal
       * Shortcuts for Common Commands

The purpose of building a custom GUI in lieu of Chillipeppr or UGS is to
create a single, integrated environment for controlling the Craniobot. In
addition to the standard features, this software package allows the user to
probe complex topographies and generate tool paths tailored to each surface.
It will also simplify future development through the use of MATLAB's extensive
libraries and documentation.   
NOTES: There seem to be backwards compatibility issues with Matlab. This was
written using version 2017b on a Mac.



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
General Info
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%	

G2core can be tricky to start using, it took me many hours of reading and googling before I got any where. I cannot stress enough how important it is that you understand every listed on this Github Wiki:

	https://github.com/synthetos/g2/wiki

And I mean everything. You will want to know all of this if you every plan on altering either the Craniobot Courier GUI or the current version of g2core that is on the Craniobot. Everything I learned about building this machine came from this wiki, so be persistent if you run into problems.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
Compiling and Building G2core
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

Since I did all of my development on a Mac, windows users will have to look for other ways of compiling and building the binary files needed to upload to the Arduino if you need to change some of the Craniobot's settings (speed limits, additional axes, GPIO configuration, etc.). 

Procedure for Mac.

1) If you don't have Xcode on your machine, get it.

2) In the G2 folder we (ME Senior Design Group Spring 2018) provided, find the file "g2core.xcodeproj". It should be located at: /g2/g2core

3) The only file you should ever have to alter is "settings_default.h". This file contains all configurable parameters that are needed for CNC machines. Look through this and make any changes that need to be made.

4) In the top menu bar, go to Product > Scheme and select "G2 gShield"

5) Now click on Product > Build. If all goes well, you should see a "Build succeeded" popup. You should now have a binary file (.bin) called "g2core.bin" located at:

	/g2/g2core/bin/gShield/g2core.bin

	This is the file you will flash to the Arduino.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
Flashing G2core to the Due
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

Figuring out how to get g2core uploaded to the Arduino was a pain in the ass. You can't use the Arduino IDE like most programs. Again, I did all of my work on a Mac, so Windows users will have to find out another way, but googling should yield results if you are persistent. Start with this link: https://github.com/synthetos/g2/wiki/Flashing-g2core-with-Windows

Here is the process for MacOS

1) You will need to download something called "bossac" found at:

		https://github.com/arduino/arduino-flash-tools

	It is a tool for uploading binary files to Atmel SAM ARM CPUs, such as the one found on the Arduino Due

2) Find the location on your computer where this file is stored and write it down. On my computer it was:

	/Documents/Github/arduino-flash-tools/tools_darwin/bossac/bin

3) Next, find the location of your built g2core binary file that you wish to upload to the Arduino. For me it was:

	/Documents/Github/g2/g2core/bin/gShield/g2core.bin

4) Connect the Due to your computer with a USB cable. The Due has two USB ports; if you look on the bottom of the Due, one says "Programming" (it is located closer to the barrel jack). Use this port for programming the Arduino. The other is used for interacting sending and receiving Gcode.

5) Open up terminal

6) Move to the directory you found in step 2 like so:

	cd Documents/Github/arduino-flash-tools/tools_darwin/bossac/bin

7) Use the bossac application to flash g2core to the Arduino like so:

	./bossac -e -w -v -b ~/Documents/Github/g2/g2core/bin/gShield/g2core.bin

NOTE: The Arduino has to be erased before you flash it. To do so, power up the Arduino and then press and hold the "erase" button (tiny button near the middle of the board) for a second or two. If the LED stops blinking, it has been erased. If you don't do this, the bossac application will throw an error.

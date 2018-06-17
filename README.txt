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

3) In the top menu bar, go to Product > Scheme and select "G2 Craniobot"

4) Now click on Product > Build. If all goes well, you should see a "Build succeeded" popup. You should now have a binary file (.bin) called "g2core.bin" located at:

	/g2/g2core/bin/Craniobot-CranioShield/g2core.bin

	This is the file you will flash to the Arduino.

EXTRAS)
	The only file you should ever have to alter is "settings_Craniobot.h". This file contains all configurable parameters. Look through this and make any changes that need to be made.

Should you want to change the pinout of the Arduino Due, open the CranioShield-pinout.h file. There is a series of lines that look like:
	pin_number kInput1_PinNumber = 14;

The number at the end is the pin on the Due that you would plug a wire into. It follows the numbering scheme printed on the Due with the exception that the Analog pins are tacked on to the end (so A0 is pin 54, A1 is pin 55, all the way to 69). See the Craniobot pinout image included in this package.

Several things must be done to change the number of input/output pins on the system.
1) In gpio.h, change lines 36-40 to suit the pins you need/want
2) In gpio.cpp, add any and all pin declarations and initializations necessary. Ex, for adding inputs I added ioDigitalInputExt<kInput16_PinNumber , 16> _din16; at line 220 as well as _din16.reset(); at line 400.
3) Add the input/output pin declarations and number assignments in CranioShield-pinout.h. Ex. pin_number kInput16_PinNumber = 66 at line 216
4) In config_app.cpp, update the table with any and all relevant changes that you have made. 
	Ex (line 425):
	#if (D_IN_CHANNELS >= 16)
   	 { "di16","di16mo",_fip, 0, io_print_mo, get_int8,io_set_mo, &d_in[15].mode,     DI16_MODE },
   	 { "di16","di16ac",_fip, 0, io_print_ac, get_ui8, io_set_ac, &d_in[15].action,   DI16_ACTION },
   	 { "di16","di16fn",_fip, 0, io_print_fn, get_ui8, io_set_fn, &d_in[15].function, DI16_FUNCTION },
	#endif

	Ex (line 1144):
	#if (D_IN_CHANNELS > 15)
   	 { "","di16", _f0, 0, tx_print_nul, get_grp, set_grp,&cs.null,0 },
	#endif


DEVELOPER NOTES)

In order to make this custom Xcode "Scheme" for the Craniobot, I had to alter a few files. First, I went to boards.mk and added:

ifeq ("$(CONFIG)","Craniobot")
    ifeq ("$(BOARD)","NONE")
        BOARD=CranioShield
    endif
    SETTINGS_FILE="settings_Craniobot.h"
endif

Second, i went to the ArduinoDue.mk filed and added:

ifeq ("$(BOARD)","CranioShield")
    # This is a due with a custom shield (gShield with added features, currently). We'll use the Due platform, but set defines
    # for the code to get the pinout right.

    BASE_BOARD = g2core-due
    DEVICE_DEFINES += MOTATE_BOARD="CranioShield"
    DEVICE_DEFINES += SETTINGS_FILE=${SETTINGS_FILE}
endif

Then, in the G2 Craniobot Target Scheme, the arguments are:

$(ACTION) VERBOSE=1 COLOR=0 OPTIMIZATION=s CONFIG=Craniobot BOARD=CranioShield

If the version of g2core is ever updated (current version is Firmware Build 100.xx from January of 2018), then the files Config_app.cpp, gpio.h, gpio.cpp, boards.mk, and ArduinoDue.mk will need to be replaced with those from this repository. settings_Craniobot.h and CranioShield-pinout.h will need to be added. Lastly, the Xcode "Craniobot" Scheme will need to be made again so that everything compiles as intended.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
Flashing G2core to the Due
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

Figuring out how to get g2core uploaded to the Arduino was a pain in the ass. You can't use the Arduino IDE like most programs. Again, I did all of my work on a Mac, so Windows users will have to find out another way, but googling should yield results if you are persistent. Start with this link: https://github.com/synthetos/g2/wiki/Flashing-g2core-with-Windows

Here is the process for MacOS

1) You will need to download something called "bossac" found at:

		https://github.com/arduino/arduino-flash-tools

	It is a tool for uploading binary files to Atmel SAM ARM CPUs, such as the one found on the Arduino Due

2) Find the location on your computer where this file is stored and write it down. On my computer it was:

	/Users/brettbalder/GitHub/arduino-flash-tools/tools_darwin/bossac/bin

3) Next, find the location of your built g2core binary file that you wish to upload to the Arduino. For me it was:

	/Users/brettbalder/GitHub/g2/g2core/bin/Craniobot-CranioShield/g2core.bin

4) Connect the Due to your computer with a USB cable. The Due has two USB ports; if you look on the bottom of the Due, one says "Programming" (it is located closer to the barrel jack). Use this port for programming the Arduino. The other is used for sending and receiving Gcode to the machine.

5) The Arduino has to be erased before you flash it. To do so, power up the Arduino and then press and hold the "erase" button (tiny button near the middle of the board) for a few seconds. If the LED stops blinking, it has been erased. If you don't do this, the bossac application will throw an error about not finding the right port.

6) Open up terminal

7) Move to the directory you found in step 2 like so:

	cd /Users/brettbalder/GitHub/arduino-flash-tools/tools_darwin/bossac/bin

7) Use the bossac application to flash g2core to the Arduino like so:

	./bossac -e -w -v -b /Users/brettbalder/GitHub/g2/g2core/bin/Craniobot-CranioShield/g2core.bin

If all goes well you should see something like:

<<<<<<< HEAD
Device found on cu.usbmodem1411
Erase flash
Write 166320 bytes to flash
[==============================] 100% (650/650 pages)
Verify 166320 bytes of flash
[==============================] 100% (650/650 pages)
Verify successful
Set boot flash true
=======
NOTE: The Arduino has to be erased before you flash it. To do so, power up the Arduino and then press and hold the "erase" button (tiny button near the middle of the board) for a second or two. If the LED stops blinking, it has been erased. If you don't do this, the bossac application will throw an error.
>>>>>>> origin/master

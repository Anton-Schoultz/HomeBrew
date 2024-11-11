# GAL Programmer
The GAL programmer is bassed on this project
https://github.com/ole00/afterburner/tree/version_4_legacy

<image src="afterburner_circuit.png"/>

The PC code is <a href="afterburner_w64_040.exe">afterburner w64</a>
and the code for th Arduino UNO is <a href="afterburner042/afterburner042.ino">afterburner042.ino</a>

Links:
<br>https://www.youtube.com/watch?v=fCsP7ujMJV8

I used a circuit based on the one in the video (at 8:15)
to switch the 12v supply to the edit pinnstead of the switchable module.

I thew it all together on a proto-typing 'hat' which then plugs onto the Arduino UNO R3.

<image src="GAL_Programmer_Hat.jpg"/>


# WinCUPL
This is used to program the GAL20v8 chips.

Here is the install file <a href="wincupl.exe">wincupl.exe</a>

I have included some refernce documents<ul>
<li><a href="CUPL_Reference.pdf">CUPL_Reference</a>
<li><a href="WinCUPL_Manual.pdf">WinCUPL_Manual</a>
</ul>
It took me a while to figure out to use the simulator..
When it first pops up, File->New, click [Design File]
select the PLD file and OK.
<p>
Then go add the signals that you want. You need to add vectors 
for the input conditions, you can click with the mouse to set them high/low
(It helps to make the columns widder and taller while doing this)
Save the .SI file for next time.
</p>
This video helped, https://www.youtube.com/watch?v=qxJI961dyNE around 21:40


# Logic Analyser
Here I made use of the excellent PulseView Program,
using a Raspberry Pi Pico as the data capture device.

*Raspberry Pi Install*

Hold down the button, plug it in, release the button.
It will appear as a USB drive, drag and drop this file
<code>pico_sdk_sigrok.uf2</code> into the folder to install the software
onto the Raspberry Pi.

As the Pi is 3v3 and I'm working with 5v circuits, I built a little adaptor board
with voltage dividers for the input pins.
I used 3k3 resistor in line, with a 4k7 to ground.

<image src="Pi-Pico-adapter-board.jpg"/>

I used the nightly builds as they include the Raspberry Pi capture device.
(The release version does not show it in the device dropdown)<ul>
<li><a href="pulseview-NIGHTLY-x86_64-release-installer.exe">Pulse View</a>
<li><a href="sigrok-cli-NIGHTLY-x86_64-release-installer.exe">Sigrok</a>
</ul>

Links: 
<br>https://www.youtube.com/watch?app=desktop&v=waBu6ijT3wo
<br>https://github.com/pysigrok/hardware-raspberrypi-pico


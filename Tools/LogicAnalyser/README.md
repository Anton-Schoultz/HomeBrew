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


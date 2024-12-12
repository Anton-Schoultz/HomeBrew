# Retro Computer
When I started on this journey to build my own retro computer I first looked to see what others had done.
I found Ben Eater's videos extremely useful.
I like his aproach to building his 6502 machine, and will most likely proceed in a similar fasion.


## Clock Circuit
After seeing the usefulness of Ben's clock circuit https://eater.net/8bit/clock, I opted to make my own.

I opted for a somewhat different (cruder) circuit, and added a reset circuit.

<image src="ClockCircuit.jpg"/>

Please excuse the hand-drawn diagram, but I figure even a badly hand-drawn diagram is better than no diagram at all ;-)

The negative going reset pulse is generated at power-up, but can also be triggered by the push button.
<br>The positive going clock pulses can be manually generated, or auto-generated via a variable speed oscillator.



<image src="CircuitDiagram.png"/>

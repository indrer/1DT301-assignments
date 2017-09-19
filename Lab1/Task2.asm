;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
;   1DT301, Computer Technology I
;   Date: 2017-09-07
;   Authors:
;                       Indre 
;                       Georgiana 
;
;   Lab number:         1
;   Title:              LEDs lighting up when corresponding switch is pressed
;
;   Hardware:           STK600, CPU ATmega2560
;
;   Function:           Reads switch press and lights up corresponding LED.
;
;   Input ports:        On board switches connected to PORTA
;
;   Output ports:       On board LEDs connected to PORTB
;
;   Subroutines:        None
;   Included files:     m2560def.inc
;
;   Other information:  None
;   Changes in program: 
;                       2017 - 09 - 07:
;                           File created, task 1 is completed.
;
;                       2017 - 09 - 08:
;                           Header comment added.
;<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<

.include "m2560def.inc"

ldi r16, 0xFF
out DDRB, r16 ;port B as output

ldi r16, 0x00
out DDRA, r16; port A as input

loop:
in r16, PINA ;read value of switches
out PORTB, r16 ;write same value to LEDs to light them up
rjmp loop

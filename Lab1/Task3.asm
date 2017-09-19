;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
;   1DT301, Computer Technology I
;   Date: 2017-09-07
;   Authors:
;                       Indre 
;                       Georgiana
;
;   Lab number:         1
;   Title:              Light up LED0 when switch 5 is pressed
;
;   Hardware:           STK600, CPU ATmega2560
;
;   Function:           Lights LED0 when switch 5 is presseded, otherwise does nothing
;
;   Input ports:        On board switches connected to PORTA
;
;   Output ports:       On board LEDs connected to PORTB
;
;   Subroutines:        equal, not_equal
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
out DDRB, r16 ; set port B to output

ldi r16, 0x00
out DDRA, r16 ; set port A to input

ldi r16, 0xDF ; set value for 5th switch
ldi r17, 0xFE ; set value for 0th LED
ldi r18, 0xFF ; set value for all LEDs off

loop:
in r19, PINA ; read port A
cp r19, r16 ; compare port A input and value for 5th switch
breq equal ; if equal go to equal 
brne not_equal ; if any other switch is pressed, go to not_equal

rjmp loop ;infinite loop

equal: ; light up 0th LED
	out PORTB, r17
	rjmp loop
not_equal: ; all LEDs are off
	out PORTB, r18
	rjmp loop;





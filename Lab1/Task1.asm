;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
;   1DT301, Computer Technology I
;   Date: 2017-09-07
;   Authors:
;                       Indre 
;                       Georgiana 
;
;   Lab number:         1
;   Title:              Lighting up LED2
;
;   Hardware:           STK600, CPU ATmega2560
;
;   Function:           Lights LED2 on PORTB
;
;   Input ports:        None
;
;   Output ports:       On board LED2 connected to PORTB
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
out DDRB, r16 ;set port B as output

ldi r16, 0xFB
out portB, r16 ;light up LED2

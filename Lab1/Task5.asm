;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
;   1DT301, Computer Technology I
;   Date: 2017-09-07
;   Authors:
;                       Indre
;                       Georgiana
;
;   Lab number:         1
;   Title:              Ring Counter with 0.5 second delay
;
;   Hardware:           STK600, CPU ATmega2560
;
;   Function:           LEDs light up in Ring Counter order, with 0.5 second delay
;
;   Input ports:        None
;
;   Output ports:       On board LEDs connected to PORTB
;
;   Subroutines:        delay, delay_1, switch_back
;   Included files:     m2560def.inc
;
;   Other information:  None
;   Changes in program: 
;                       2017 - 09 - 07:
;                           File created, task 1 is completed.
;
;                       2017 - 09 - 08:
;                           Header comment added.
;
;			2017 - 09 - 10:
;                           Updated delay loop.
;<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<

.include "m2560def.inc"

; Initializing stack pointer
ldi r16, HIGH(RAMEND)
out SPH, r16
ldi r16, low(RAMEND)
out SPL, r16

ldi r16, 0xFF
out DDRB, r16 ; set PORTB to output

ldi r16, 0b1111_1110 ; first LED value to light up
ldi r17, 0b1111_1111 ; all LEDs are off

loop:
rcall delay ; call 0.5 sec delay loop
out PORTB, r16 ; light up current LED
lsl r16 ; shift bits to left
inc r16 ; to avoid more than one LEDs on, increase r16 value
cp r16, r17 ; compare all LEDs off value with current value
breq switch_back ; if all LEDs are off, go to switch_back subroutine
rjmp loop

; Clock's frequency is 1.000 MGhz
; Code generated using http://bretmulvey.com/avrdelay.html
delay: 
    push r16
    push r17
    ldi  r16, 3
    ldi  r17, 138
    ldi  r18, 83
delay_1: dec  r18
    brne delay_1
    dec  r17
    brne delay_1
    dec  r16
    brne delay_1
    pop r17
    pop r16
    rjmp PC+1
ret

switch_back: ; to avoid all LEDs out, switches back to 0th LED on value
	ldi r16, 0b1111_1110 ; it's okay to overwrite the value here
	rjmp loop


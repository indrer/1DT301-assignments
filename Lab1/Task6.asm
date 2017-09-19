;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
;   1DT301, Computer Technology I
;   Date: 2017-09-07
;   Authors:
;                       Indre
;                       Georgiana
;
;   Lab number:         1
;   Title:              Johnson Counter 
;
;   Hardware:           STK600, CPU ATmega2560
;
;   Function:           Johnson Counter is created using LEDs
;
;   Input ports:        None
;
;   Output ports:       On board LEDs connected to PORTB
;
;   Subroutines:        delay, delay_1, go_right, equals
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

; Initializing stack pointer
ldi r16, HIGH(RAMEND)
out SPH, r16
ldi r16, low(RAMEND)
out SPL, r16

ldi r16, 0xFF
out DDRB, r16

ldi r16, 0b1111_1110 ; first LED value to light up
ldi r17, 0b1111_1111 ; all LEDs are off
ldi r21, 0b0000_0000 ; all LEDs are on

loop:
rcall delay ; call 0.5 sec delay loop
out PORTB, r16 ; light up current LED
cp r16, r21 ; compare all LEDs off value with current value
breq go_right ; if all LEDs are on, start going left to right (go_right subroutine)
lsl r16 ; shifts all bits to the left
rjmp loop ; infinite loop

delay: ; code generated using http://bretmulvey.com/avrdelay.html
    push r16
    push r17
    push r21
    ldi  r16, 3
    ldi  r17, 138
    ldi  r21, 83
delay_1: dec  r21
    brne delay_1
    dec  r17
    brne delay_1
    dec  r16
    brne delay_1
    pop r21
    pop r17
    pop r16
    nop
ret

go_right:
	ldi r16, 0b1000_0000 ; first LED off from left side
	another_loop: ; loop for lights to start going off
	rcall delay ; delay subroutine
	out PORTB, r16 ; shows lights that are still on
	cp r16, r17 ; compares current register (r16) with register that stores LEDs off value
	breq equals ; if all LEDs are off, closes loop
	asr r16 ; shifts all bits one place to the right, and keeps 7th bit, which is needed
	rjmp another_loop
	rjmp loop ; goes back to infinite loop

equals: 
	ldi r16, 0b1111_1110
	rjmp loop; loop closing

;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
;   1DT301, Computer Technology I
;   Date: 2017-09-07
;   Authors:
;                       Indre
;                       Georgiana
;
;   Lab number:         3
;   Title:              Turning LED on and off using interrupts
;
;   Hardware:           STK600, CPU ATmega2560
;
;   Function:           Turning LED on and off by SW0 press, uses interrupts.
;
;   Input ports:        On board switches connected to PORTD
;
;   Output ports:       On board LEDs connected to PORTB
;
;   Subroutines:        main_program,
;			interrupt_0,
;			avoid_bouncing
;   Included files:     m2560def.inc
;
;   Other information:  None
;   Changes in program: 
;                       2017 - 09 - 21:
;                           File created, task finished
;
;                       2017 - 09 - 27:
;                           Comments added, header added.
;<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
.include "m2560def.inc"

.org 0x00
rjmp start

.org INT0addr
rjmp interrupt_0

.org 0x72
start:
;Initialize Stack Pointer
ldi r16, HIGH(RAMEND)
out SPH, r16
ldi r16, low(RAMEND)
out SPL, r16

;>>>>>>>>>>>>>>>>>>>>Set data direction registers>>>>
ldi r16,0x00; Setup PORTD as input
out DDRD, r16

ldi r16, 0xFF; Setup PORTB as output
out DDRB, r16

ldi r16, 0b0000_0001
out EIMSK, r16

ldi r16, 0b0000_1000
sts EICRA, r16

sei ; Enable global interrupts

;>>>>>>>>>>>>>>>>>>>>Main loop>>>>>>>>>>>>>>>>>>>>>>>
ldi r16, 0xFF
out PORTB, r16
main_program:
nop
rjmp main_program

;>>>>>>>>>>>>>>>>>>>>Interrupt subroutine>>>>>>>>>>>>
interrupt_0:
rcall avoid_bouncing
out PORTB, r16
cpi r16, 0b1111_1110 ; Check if LED is on
breq switch_off

cpi r16, 0b1111_1111 ; Check if LED is off
breq switch_on
reti

switch_off:
ldi r16, 0b1111_1111 ;LED was on, so switch it off and exit interrupt
reti

switch_on:
ldi r16, 0b1111_1110 ;LED was off, so switch it on and exit interrupt
reti

;>>>>>>>>>>>>>>>>>>>>Delays>>>>>>>>>>>>>>>>>>>>>>>>>>
avoid_bouncing:
	push r18
	push r19
	push r20
    ldi  r18, 2
    ldi  r19, 134
    ldi  r20, 154
L1: dec  r20
    brne L1
    dec  r19
    brne L1
    dec  r18
    brne L1
	pop r19
	pop r18
	pop r20
    ret

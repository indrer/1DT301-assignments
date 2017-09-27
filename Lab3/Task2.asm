;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
;   1DT301, Computer Technology I
;   Date: 2017-09-07
;   Authors:
;                       Indre
;                       Georgiana
;
;   Lab number:         3
;   Title:              Switch between two counters
;
;   Hardware:           STK600, CPU ATmega2560
;
;   Function:           Switches between two counters after a button press; uses interrupts
;
;   Input ports:        On board switches connected to PORTD
;
;   Output ports:       On board LEDs connected to PORTB
;
;   Subroutines:        main_program,
;			main_loop,
;			ring_counter,
;			ring_reset,
;			johnson_counter,
;			go_left,
;			go_right,
;			switch_to_left,
;			switch_to_right,
;			delay,
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
rjmp main_loop

.org 0x72
start:
;>>>>>>>>>>>>>>>>>>>>Set variables>>>>>>>>>>>>>>>>>>>
.def output_leds = r16
.def current_counter = r17 ; 0 - Ring Counter, 1 - Johnson Counter
.def johnson_state = r18 ; 0 - go left, 1 - go right
.def counter_start = r20 ; value at which counters start
.def switch_reader = r21 ; stores value of a switch

;>>>>>>>>>>>>>>>>>>>>Initializing stack pointer>>>>>>
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

sei ;enable global iterrupts

;>>>>>>>>>>>>>>>>>>>>Set values>>>>>>>>>>>>>>>>>>>>>>
ldi output_leds, 0b1111_1111
ldi current_counter, 0x00
ldi johnson_state, 0
ldi counter_start, 0b1111_1110

;>>>>>>>>>>>>>>>>>>>>Main loop>>>>>>>>>>>>>>>>>>>>>>>
main_program:
	cpi current_counter, 0xFF
	breq johnson_counter

	rcall ring_counter

	output:
		out PORTB, output_leds
	
	; Delay needs to be at the very end of main loop, since
	; we are checking for button clicks in the delay loop. So if
	; delay loop is stopped, program starts over in main_loop.
	rcall delay 
rjmp main_program

main_loop:
	rcall avoid_bouncing
	com current_counter ; invert current counter value
	ldi output_leds, 0xFF ; reset output_leds value
reti
;>>>>>>>>>>>>>>>>>>>>Ring counter>>>>>>>>>>>>>>>>>>>>
ring_counter:
cpi output_leds, 0xFF
breq ring_reset

lsl output_leds
inc output_leds

cpi output_leds, 0xFF
breq ring_reset
ret 

ring_reset:
lsl output_leds
rjmp output


;>>>>>>>>>>>>>>>>>>>>Johnson counter>>>>>>>>>>>>>>>>>>
johnson_counter:
	cpi johnson_state, 0
	brne go_right

	cpi johnson_state, 0
	breq go_left

go_left:
	cpi output_leds, 0x00
	breq switch_to_right
	lsl output_leds
	rjmp output

switch_to_right:
	ldi johnson_state, 1
	rjmp go_right

switch_to_left:
	ldi johnson_state, 0
	rjmp go_left

go_right:
	cpi output_leds, 0xFF
	breq switch_to_left
	com output_leds
	lsr output_leds
	com output_leds
	rjmp output


;>>>>>>>>>>>>>>>>>>>>Delays>>>>>>>>>>>>>>>>>>>>>>>>>>>
; code generated using http://bretmulvey.com/avrdelay.html
delay:
	push r18
	push r19
	push r20
    ldi  r18, 3
    ldi  r19, 138
    ldi  r20, 86
delay_1: 
	dec  r20
    brne delay_1
    dec  r19
    brne delay_1
    dec  r18
    brne delay_1
	pop r20
	pop r19
	pop r18
ret

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
	pop r20
	pop r19
	pop r18
    ret



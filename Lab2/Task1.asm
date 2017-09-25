;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
;   1DT301, Computer Technology I
;   Date: 2017-09-07
;   Authors:
;                       Indre
;                       Georgiana
;
;   Lab number:         2
;   Title:              Switching between two counters with a button press
;
;   Hardware:           STK600, CPU ATmega2560
;
;   Function:           Switches between Ring Counter and Johnson counter when SW0 is pressed.
;
;   Input ports:        On board switches connected to PORTA
;
;   Output ports:       On board LED2 connected to PORTB
;
;   Subroutines:        main_loop,
;			ring_counter,
;			ring_reset,
;			johnson_counter,
;			go_left,
;			go_right,
;			switch_to_left,
;			switch_to_right,
;			switch,
;			avoid_bouncing,
;			delay
;   Included files:     m2560def.inc
;
;   Other information:  None
;   Changes in program: 
;                       2017 - 09 - 14:
;                           File created
;
;                       2017 - 09 - 17:
;                           Task finished, header added.
;<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
.include "m2560def.inc"

;>>>>>>>>>>>>>>>>>>>>Set variables>>>>>>>>>>>>>>>>>>>
.def output_leds = r16
.def current_counter = r17 ; 0 - Ring Counter, 1 - Johnson Counter
.def johnson_state = r18 ; 0 - go left, 1 - go right
.def zero_switch = r19 ; value of SW0
.def counter_start = r20 ; value at which counters start
.def switch_reader = r21 ; stores value of a switch

;>>>>>>>>>>>>>>>>>>>>Initializing stack pointer>>>>>>
ldi r16, HIGH(RAMEND)
out SPH, r16
ldi r16, low(RAMEND)
out SPL, r16

;>>>>>>>>>>>>>>>>>>>>Set data direction registers>>>>
ldi r16,0x00; Setup PORTA as input
out DDRA, r16

ldi r16, 0xFF; Setup PORTB as output
out DDRB, r16

;>>>>>>>>>>>>>>>>>>>>Set values>>>>>>>>>>>>>>>>>>>>>>
ldi output_leds, 0b1111_1111
ldi current_counter, 0x00
ldi johnson_state, 0
ldi zero_switch, 0b1111_1110
mov counter_start, zero_switch

;>>>>>>>>>>>>>>>>>>>>Main loop>>>>>>>>>>>>>>>>>>>>>>>
main_loop:

	cpi current_counter, 0xFF
	breq johnson_counter

	rcall ring_counter

	output:
		out PORTB, output_leds
	
	; Delay needs to be at the very end of main loop, since
	; we are checking for button clicks in the delay loop. So if
	; delay loop is stopped, program starts over in main_loop.
	rcall delay 

	rjmp main_loop
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



;>>>>>>>>>>>>>>>>>>>>Counter switch>>>>>>>>>>>>>>>>>>>
switch:
rcall avoid_bouncing
com current_counter ; invert current counter value
ldi output_leds, 0xFF ; reset output_leds value
pop r20
pop r19
pop r18
rjmp main_loop ; jump back to main loop

;Method to help avoid button bouncing (waits 300 ms)
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


;>>>>>>>>>>>>>>>>>>>>Delay>>>>>>>>>>>>>>>>>>>>>>>>>>>>
; code generated using http://bretmulvey.com/avrdelay.html
delay:
	push r18
	push r19
	push r20
    ldi  r18, 2
    ldi  r19, 4
    ldi  r20, 187
delay_1: 
	in switch_reader, PINA ;checks input
	cpi switch_reader, 0b1111_1110
	breq switch
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



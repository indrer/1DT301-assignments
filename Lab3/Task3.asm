;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
;   1DT301, Computer Technology I
;   Date: 2017-09-07
;   Authors:
;                       Indre
;                       Georgiana
;
;   Lab number:         3
;   Title:              Car light simulator
;
;   Hardware:           STK600, CPU ATmega2560
;
;   Function:           When SW0 is pressed, ring counter of first 4 LEDs is displayed.
;			When SW1 is pressed, ring counter of last 4 LEDs is displayed.
;
;   Input ports:        On board switches connected to PORTD
;
;   Output ports:       On board LEDs connected to PORTB
;
;   Subroutines:        main_program,
;			left_turn,
;			continue_left,
;			right_turn,
;			continue_right,
;			interrupt_right,
;			interrupt_left,
;			delay,
;			avoid_bouncing
;   Included files:     m2560def.inc
;
;   Other information:  None
;   Changes in program: 
;                       2017 - 09 - 21:
;                           File created.
;			2017 - 09 - 25
;			    Task finished.
;                       2017 - 09 - 27:
;                           Comments added, header added.
;<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<

.include "m2560def.inc"

.org 0x00
rjmp start

.org INT0addr
rjmp interrupt_right

.org INT1addr
rjmp interrupt_left

.org 0x72
start:
;>>>>>>>>>>>>>>>>>>>>Set variables>>>>>>>>>>>>>>>>>>>
.def output_leds = r19
.def right_turn_flag = r17
.def left_turn_flag = r18
.def ring = r16
.equ normal_state = 0b0011_1100

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

ldi r16, 0b0000_0101
sts EICRA, r16

ldi r16, 0b0000_0011
out EIMSK, r16

sei ;Enable global interrupts


;>>>>>>>>>>>>>>>>>>>>Set values>>>>>>>>>>>>>>>>>>>>>>
ldi output_leds, normal_state
;>>>>>>>>>>>>>>>>>>>>Main loop>>>>>>>>>>>>>>>>>>>>>>>
main_program:
out portB, output_leds
check_right:
cpi right_turn_flag, 0xFF ; checks if it should show right turn
brne check_left
rcall right_turn

check_left:
cpi left_turn_flag, 0xFF ;checks if it should show left turn
brne check_none
rcall left_turn

check_none:
ldi output_leds, normal_state ; if no turns are enabled, four LEDs are on

end:
rcall delay
rjmp main_program


;>>>>>>>>>>>>>>>>>>>>Left turn>>>>>>>>>>>>>>>>>>>>>>>
left_turn:
cpi ring, 0b0111_1111 ; if it reached end of the ring counter, reset it
brne continue_left
ldi ring, 0b1111_0111

continue_left:
; invert bits, shift them to the left, invert them back
com ring
lsl ring
com ring
mov output_leds, ring ; copy currently on ring counter LED to output_leds
cbr output_leds, 0b0000_0011 ; make sure that right side LEDs are on
rjmp end

;>>>>>>>>>>>>>>>>>>>>Right turn>>>>>>>>>>>>>>>>>>>>>>
right_turn:
cpi ring, 0b1111_1110 ; if it reached an end of the ring counter, reset it
brne continue_right
ldi ring, 0b1110_1111

continue_right:
; invert bits, shift them to the right, invert them back
com ring
lsr ring
com ring
mov output_leds, ring ; copy currently on ring counter LED to output_leds
cbr output_leds, 0b1100_0000 ; make sure that left side LEDs are on
rjmp end


;>>>>>>>>>>>>>>>>>>>>1st interrupt (right)>>>>>>>>>>>
interrupt_right:
rcall avoid_bouncing
com right_turn_flag ; change the value of right turn flag
ldi left_turn_flag, 0x00 ; make sure left turn is not activated at the same time
ldi ring, 0b1110_1111

reti
;>>>>>>>>>>>>>>>>>>>>2nd interrupt(left)>>>>>>>>>>>>>
interrupt_left:
rcall avoid_bouncing
com left_turn_flag ;change the value of left turn flag
ldi right_turn_flag, 0x00 ; make sure right turn is not activated at the same time
ldi ring, 0b1111_0111

reti

;>>>>>>>>>>>>>>>>>>>>Delays>>>>>>>>>>>>>>>>>>>>>>>>>>
delay:
    ldi  r25, 2
    ldi  r26, 134
    ldi  r27, 154
delay_1: 
	dec  r27
    brne delay_1
    dec  r26
    brne delay_1
    dec  r25
    brne delay_1

ret


avoid_bouncing:
    ldi  r24, 13
    ldi  r22, 252
L1: dec  r22
    brne L1
    dec  r24
    brne L1
    rjmp PC+1
	ret

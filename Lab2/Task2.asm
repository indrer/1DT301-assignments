;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
;   1DT301, Computer Technology I
;   Date: 2017-09-07
;   Authors:
;                       Indre
;                       Georgiana
;
;   Lab number:         2
;   Title:              Random dice value
;
;   Hardware:           STK600, CPU ATmega2560
;
;   Function:           Outputs random dice value (1-6) when SW0 is pressed.
;
;   Input ports:        On board switches connected to PORTA
;
;   Output ports:       On board LED2 connected to PORTB
;
;   Subroutines:        main,
;			button_pressed,
;			reset_counter,
;			create_output,
;			start,
;			face_one,
;			face_two,
;			face_three,
;			face_four,
;			face_five,
;			face_six,
;			avoid_bouncing
;
;   Included files:     m2560def.inc
;
;   Other information:  None
;   Changes in program: 
;                       2017 - 09 - 17:
;                           File created, task completed
;<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
.include "m2560def.inc"

;>>>>>>>>>>>>>>>>>>>>Set variables>>>>>>>>>>>>>>>>>>>
.def output = r16
.def zero_switch = r17
.def randomizer = r18
.def input = r19

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

ldi zero_switch, 0b1111_1110
ldi randomizer, 0

;>>>>>>>>>>>>>>>>>>>>Main subroutine>>>>>>>>>>>>>>>>>
main:
rcall avoid_bouncing
in input, PINA
cp input, zero_switch
brne create_output

rcall button_pressed

rjmp main

;>>>>>>>>>>>>>>>>>>>>Button press handling>>>>>>>>>>>
button_pressed:
inc randomizer
cpi randomizer, 7
breq reset_counter
rjmp main

reset_counter:
ldi randomizer, 1
ret


create_output:
cpi input, 0x00
breq start

cpi randomizer, 1
breq face_one

cpi randomizer, 2
breq face_two

cpi randomizer, 3
breq face_three

cpi randomizer, 4
breq face_four

cpi randomizer, 5
breq face_five

cpi randomizer, 6
breq face_six

ret


;Method to help avoid button bouncing (waits 50 ms)
avoid_bouncing:
	push r18
	push r19
    ldi  r18, 65
    ldi  r19, 239
L1: dec  r19
    brne L1
    dec  r18
    brne L1
	pop r19
	pop r18
    ret

;>>>>>>>>>>>>>>>>>>>>Die faces>>>>>>>>>>>>>>>>>>>>>>>
start:
ldi output, 0xFF
out PORTB, output
rjmp main

face_one:
ldi output, 0b1110_1111
out PORTB, output
rjmp main

face_two:
ldi output, 0b1011_1011
out PORTB, output
rjmp main

face_three:
ldi output, 0b1010_1011
out PORTB, output
rjmp main

face_four:
ldi output, 0b0011_1001
out PORTB, output
rjmp main

face_five:
ldi output, 0b0010_1001
out PORTB, output
rjmp main

face_six:
ldi output, 0b0001_0001
out PORTB, output
rjmp main

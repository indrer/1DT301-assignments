;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
;   1DT301, Computer Technology I
;   Date: 2017-09-07
;   Authors:
;                       Indre
;                       Georgiana
;
;   Lab number:         2
;   Title:              Delay subroutine with variable delay time
;
;   Hardware:           STK600, CPU ATmega2560
;
;   Function:           A subroutine that takes the number of milliseconds as a parameter
;			and creates a delay as long as parameter value. The program also 
;			displays Ring Counter.
;
;   Input ports:        None
;
;   Output ports:       On board LED2 connected to PORTB
;
;   Subroutines:        main,
;			wait_milliseconds,
;			delay,
;			ring_counter,
;			ring_reset
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
.def output_leds = r16
.equ delay_ms = 500 ;by changing its value, time between each ring counter is changed. for future reference: try 20 ms ;)

;>>>>>>>>>>>>>>>>>>>>Initializing stack pointer>>>>>>
ldi r16, HIGH(RAMEND)
out SPH, r16
ldi r16, low(RAMEND)
out SPL, r16

;>>>>>>>>>>>>>>>>>>>>Set data direction registers>>>>
ldi r16, 0xFF; Setup PORTB as output
out DDRB, r16

;>>>>>>>>>>>>>>>>>>>>Set values>>>>>>>>>>>>>>>>>>>>>>
ldi output_leds, 0xFF

;>>>>>>>>>>>>>>>>>>>>Main program>>>>>>>>>>>>>>>>>>>>
main:
out PORTB, output_leds
rcall ring_counter
ldi r25, high(delay_ms)
ldi r24, low(delay_ms)
rcall wait_milliseconds
rjmp main


;>>>>>>>>>>>>>>>>>>>>Delay subroutine>>>>>>>>>>>>>>>>
wait_milliseconds:

	sbiw r25:r24, 1
	brne delay ;1ms long delay is ran as many ms as requested in parameters

ret

;This delay subroutine is 1ms long
delay:
	push r18
	push r19
    ldi  r18, 2
    ldi  r19, 75
L1: dec  r19
    brne L1
    dec  r18
    brne L1
	pop r19
	pop r18
    rjmp wait_milliseconds

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
ret

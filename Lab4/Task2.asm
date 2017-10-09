;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
;   1DT301, Computer Technology I
;   Date: 2017-10-09
;   Authors:
;                       Indre
;                       Georgiana
;
;   Lab number:         4
;   Title:              Pulse Width Modulation
;
;   Hardware:           STK600, CPU ATmega2560
;
;   Function:           Create square wave. Increase/ decrease duty cycle 
;			in steps of 5% using SW0 and SW1. Uses interrupt.
;
;   Input ports:        On board switches connected to PORTD
;
;   Output ports:       On board LEDs connected to PORTB
;         	
;   Subroutines: 	start,
;			interrupt_decrease, 
;			end_decrease,
;			interrupt_increase, 
;			end_increase,
;			timer0, 
;			leds_off,
;			leds_on, 
;			reset_counter, 
;			cont
;
;   Included files:     m2560def.inc
;
;   Other information:  Connected device to oscilloscope to visualize 
;			the change in duty cycle.
;   Changes in program: 
;                       2017-10-09
;                           File created.
;			2017-10-09
;			    Task finished.
;                       2017 - 10 - 11:
;                           Comments added, header added.
;<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
.include "m2560def.inc"
.def temp = r16
.def output = r17
.def counter = r18
.def duty_counter = r19

.equ duty_step = 5
.equ duty_max = 100
.equ duty_min = 0

.org 0x00
	jmp restart

.org OVF0addr
	jmp timer0
; not using INT0 as it seems to be broken, can register up to 3 clicks
.org INT2addr
	jmp interrupt_increase

.org INT1addr
	jmp interrupt_decrease

.org 0x72

restart:
ldi temp, LOW(RAMEND)
out SPL, temp
ldi temp, HIGH(RAMEND)
out SPH, temp

ldi temp, 0x01
out DDRB, temp
ldi temp, 0x00
out DDRD, temp

ldi temp, 0b0000_0101 ; This was in table 42, doc2466
out TCCR0B, temp
ldi temp, (1<<TOIE0)
sts TIMSK0, temp
ldi temp, 245
out TCNT0, temp

; Change back to INT0, 
ldi r16, 0b0010_1000
sts EICRA, r16
ldi r16, 0b0000_0110
out EIMSK, r16

sei


ldi duty_counter, 50
;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
start:
	rjmp start 

;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>> int0
interrupt_increase:
	; check if duty_counter has reached 100
	cpi duty_counter, duty_max
	breq end_increase

	push temp
	ldi temp, duty_step
	add duty_counter, temp
	pop temp

end_increase:
	reti

;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>> int 1
interrupt_decrease:
	; check if duty_counter has reached 0
	cpi duty_counter, duty_min
	breq end_decrease

	push temp
	ldi temp, duty_step
	sub duty_counter, temp
	pop temp

end_decrease:
	reti

;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>

timer0:
	push temp
	in temp, SREG
	push temp

	inc counter
	; counter <= duty_counter, BRLT possibly?
	cp counter, duty_counter
	brlo leds_on
	breq leds_on

leds_off:
	ldi output, 0xFF
	rjmp counter_reset

leds_on:
	ldi output, 0x00
	rjmp counter_reset

counter_reset:
	out PORTB, output
	cpi counter, duty_max
	brlo cont
	clr counter

cont:
	ldi temp, 245
	out TCNT0, temp
	pop temp
	out SREG, temp
	pop temp
	reti

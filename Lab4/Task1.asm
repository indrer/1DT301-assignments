;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
;   1DT301, Computer Technology I
;   Date: 2017-09-07
;   Authors:
;                       Indre
;                       Georgiana
;
;   Lab number:         4
;   Title:              Square wave generator
;
;   Hardware:           STK600, CPU ATmega2560
;
;   Function:           LED0 lights up for 5 seconds, then turns off for five seconds
;			to create a square wave. Keeps on going.
;
;   Input ports:        None
;
;   Output ports:    	 LED0 connected to PORTB
;
;   Subroutines:	timer0,
;			start
;			cont
;
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
.def temp = r16
.def output = r17
.def counter = r18

.org 0x00
	jmp restart

.org OVF0addr
	jmp timer0

.org 0x72

restart:
	; Initialize stack pointer
	ldi temp, LOW(RAMEND)
	out SPL, temp
	ldi temp, HIGH(RAMEND)
	out SPH, temp
	; First LED as output
	ldi temp, 0x01
	out DDRB, temp

	ldi temp, 0b0000_0101 ; This was in table 42, doc2466
	out TCCR0B, temp
	ldi temp, (1<<TOIE0)
	sts TIMSK0, temp
	ldi temp, 205
	out TCNT0, temp

	sei

	ldi output, 0x00
	ldi counter, 0
start:
	out PORTB, output
	rjmp start 

timer0:
	push temp
	in temp, SREG
	push temp
	; 10*50=500ms
	inc counter
	cpi counter, 10
	brne cont
	; If it reached 500ms, invert output
	com output
	ldi counter, 0

	cont:
	ldi temp, 205
	out TCNT0, temp
	pop temp
	out SREG, temp
	pop temp
	reti

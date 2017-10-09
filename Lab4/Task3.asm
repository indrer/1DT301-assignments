;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
;   1DT301, Computer Technology I
;   Date: 2017-10-09
;   Authors:
;                       Indre
;                       Georgiana
;
;   Lab number:         4
;   Title:              Serial communication 
;
;   Hardware:           STK600, CPU ATmega2560
;
;   Function:           Use polled UART to input and receive characters from the computer
;			and display their ASCII code in binary equivalent on the LEDs.
;			
;
;   Input ports:        RS232
;
;   Output ports:       On board LEDs connected to PORTB
;
;   Subroutines:       	restart,
;			get_data,
;			output
;
;   Included files:     m2560def.inc
;
;   Other information:  Used the PuTTy application to input characters and
;			connected receiver and trasnmitter wires 
;			(RXD and TXD, transmitter, to PD2 and PD3), and also
;			connected the RS232 cable between the board and the computer.
;			
;			
;   Changes in program: 
;                       2017 - 10 - 09
;                           File created, task finished.
;
;                       2017 - 10 - 18:
;                           Comments added, header added.
;<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
.include "m2560def.inc"

.equ UBRR_val = 12

.def temp = r16
.def char = r17

.cseg
.org 0x00
	jmp restart

restart:

	ldi temp, LOW(RAMEND)
	out SPL, temp
	ldi temp, HIGH(RAMEND)
	out SPH, temp

	ldi temp, 0xFF
	out DDRB, temp
	out PORTB, temp

	ldi temp, UBRR_val
	sts UBRR0L, temp ;store prescaler value in UBBRRL
	ldi temp, (1<<RXEN0) ; only receiver is needed for this task
	sts UCSR0B, temp ;set TX and RX enable flags

	sei

get_data: ;gets data - code from doc2549, page 215
	lds temp, UCSR0A
	;Make sure it is not receiving any more input
	sbrs temp, RXC0
	rjmp get_data
	;Load char variable with whatever was received
	lds char, UDR0

	output:
	com char
	out PORTB, char
	com char

	rjmp get_data

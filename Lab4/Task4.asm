;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
;   1DT301, Computer Technology I
;   Date: 2017-10-09
;   Authors:
;                       Indre
;                       Georgiana
;
;   Lab number:         4
;   Title:              Serial communication with echo
;
;   Hardware:           STK600, CPU ATmega2560
;
;   Function:           Use polled UART to input and receive characters from the computer
;			                  and display their ASCII code in binary equivalent on the LEDs,
;			                  and also echo back to the terminal the character(s) sent.			
;
;   Input ports:        RS232
;
;   Output ports:       On board LEDs connected to PORTB
;
;   Subroutines:       	get_data,
;			                  output,
;			                  send_data
;
;   Included files:     m2560def.inc
;
;   Other information:  Used the PuTTy application to input characters and
;			                  connected receiver and trasnmitter wires 
;			                  (RXD and TXD, transmitter, to PD2 and PD3), and also
;		                  	connected the RS232 cable between the board and the computer.			
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

.org 0x00
rjmp restart

.org 0x72
restart:

ldi temp, LOW(RAMEND)
out SPL, temp
ldi temp, HIGH(RAMEND)
out SPH, temp

ldi temp, 0xFF
out DDRB, temp
out PORTB, temp

ldi temp, UBRR_val
sts UBRR0L, temp ;store prescaler value in UBRRL
ldi temp, (1<<RXEN0) | (1<<TXEN0)
sts UCSR0B, temp ;set TX and RX enable flags

get_data: ;gets data - code from doc2549, page 215
lds temp, UCSR0A
sbrs temp, RXC0
rjmp get_data
lds char, UDR0

output:
com char
out PORTB, char
com char

send_data: ; lecture 7, slide 60
lds temp, UCSR0A
sts UDR0, char
rjmp get_data

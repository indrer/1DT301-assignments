;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
;   1DT301, Computer Technology I
;   Date: 2017-10-09
;   Authors:
;                       Indre
;                       Georgiana
;
;   Lab number:         4
;   Title:              Serial communication using Interrupt
;
;   Hardware:           STK600, CPU ATmega2560
;
;   Function:           Use interrupt based polled UART to input and receive characters 
;			from the computer and display their ASCII code in binary equivalent 
;			on the LEDs, and also echo back to the terminal the character(s) sent.			
;			
;   Input ports:        RS232
;
;   Output ports:       On board LEDs connected to PORTB
;
;   Subroutines:        main,
;			rx_complete
;
;   Included files:     m2560def.inc
;
;   Other information:  Used the PuTTy application to input characters and
;			connected receiver and trasnmitter wires 
;			(RXD and TXD, transmitter, to PD2 and PD3), and also
;			connected the RS232 cable between the board and the computer.
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
rjmp restart

;page 105, doc 2549
.org URXC0addr ;USART0 RX, 0x32
rjmp rx_complete


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
ldi temp, (1<<RXEN0) | (1<<TXEN0) | (1<<RXCIE0)
sts UCSR0B, temp ;set TX and RX enable flags

sei

main:
rjmp main

rx_complete: ;slide 72, lecture 7
lds temp, UCSR0B
lds char, UDR0

;echo back to terminal
lds temp, UCSR0B
sts UDR0, char

;output to LEDs
com char
out PORTB, char
com char
reti

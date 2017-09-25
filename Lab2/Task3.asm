;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
;   1DT301, Computer Technology I
;   Date: 2017-09-07
;   Authors:
;                       Indre
;                       Georgiana
;
;   Lab number:         2
;   Title:              Change counter
;
;   Hardware:           STK600, CPU ATmega2560
;
;   Function:           Increases a byte value stored in a register after SW0 is pressed and after it's released.
;			Changed value is displayed on PORTB.
;
;   Input ports:        On board switches connected to PORTA
;
;   Output ports:       On board LED2 connected to PORTB
;
;   Subroutines:        main,
;			check_press,
;			handle_press,
;			end_handle,
;			handle_release
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
.def output = r17 ; printed out led value
.def button_pressed = r18 ; 0 - not pressed, 1 - pressed
.def zero_switch = r19
.def input = r20

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

;>>>>>>>>>>>>>>>>>>>>Set register value>>>>>>>>>>>>>>
ldi output, 0x00
ldi zero_switch, 0b1111_1110


;>>>>>>>>>>>>>>>>>>>>Main program loop>>>>>>>>>>>>>>>
main:

rcall check_press
com output
out PORTB, output
com output

rjmp main 

;>>>>>>>>>>>>>>>>>>>>Checks if button is pressed>>>>>
check_press:

in input, PINA
cp input, zero_switch
breq handle_press

cpi button_pressed, 0xFF ;button is not pressed, but flag still marks it as pressed
breq handle_release

ret

;>>>>>>>>>>>>>>>>>>>>Handles button operations>>>>>>>

handle_press:
cpi button_pressed, 0xFF ; handles if button is kept pressed
breq end_handle

com button_pressed ; button was not pressed, so we invert button press flag to let program know that button is now pressed
inc output
ret

end_handle:
rjmp check_press

handle_release:
com button_pressed ;set flag to button not pressed
inc output
ret

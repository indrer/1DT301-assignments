;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
;   1DT301, Computer Technology I
;   Date: 2017-10-10
;   Authors:
;                       Indre
;                       Georgiana
;
;   Lab number:         5
;   Title:              Take input as 4 lines, display them 5 seconds each two, then scroll.
;
;   Hardware:           STK600, CPU ATmega2560
;
;   Function:           Displays text received on a serial port, two lines are visible for 5 seconds, then text scrolls down
;                       and another pair of lines is displayed.
;
;   Input ports:        RX and TX on PINE0 and PINE1
;
;   Output ports:       LCD on PORTB
;
;   Subroutines:        display_first,
;                       display_second,
;                       display_third,
;                       display_fourth,
;                       input_handler,
;                       print_line,
;                       five_sec_delay,
;                       loop,
;                       subourtines from Lab 5_init_HT_2016.asm
;   Included files:       m2560def.inc
;
;   Other information:  None
;   Changes in program: 
;                       2017 - 10 - 10:
;                           File created, task finished
;
;                       2017 - 10 - 18:
;                           Comments added, header added.
;<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
.include "m2560def.inc"

.def temp = r16
.def output = r17
.def rs = r18
.def start_high = r19
.def start_low = r20
.def display_counter = r21
.def counter = r23
.def line_counter = r24
.def char_counter = r25
.def input_finished_flag =r26

.equ UBRR_val = 12
.equ bitmode4 = 0b0000_0010
.equ clear = 0b0000_0001
.equ display_control = 0b0000_1111
.equ newline = 0b1010_1000
.equ sequence_addr = 0x200 	;Where SRAM begins, according to lectures. Hopefully good start for a sequence
.equ counter_max = 21			;For timer count. 250x20 = 5000ms=5s
.equ counter_min  = 0
.equ enter_input = 0x0d 		; Carriage return (CR)
.equ space = 0b0010_0000

.cseg
.org 0x00
	jmp reset

.org URXC0addr
	jmp input_handler

.org 0x72
reset:
;>>>>>>>>>>>>>>>>>>>>Initialize stack pointer>>>>>>>>
	ldi temp, HIGH(RAMEND)
	out SPH, temp
	ldi temp, LOW(RAMEND)
	out SPL, temp
;>>>>>>>>>>>>>>>>>>>>Set data direction register>>>>>
	ser temp						; sets temp to 0xFF
	out DDRB, temp			 ; PORTB as output
;>>>>>>>>>>>>>>>>>>>>Initialize display>>>>>>>>>>>>>
	rcall init_disp			; Initializing display using Lab_5_init_HT_2016.asm file
	
;>>Ser prescaller value, enable receiver and tramsmitter>
	ldi temp, UBRR_val
	sts UBRR0L, temp 			; store prescaler value in UBRRL
	ldi temp, (1<<RXEN0) | (1<<RXCIE0) | (1<<TXEN0)
	sts UCSR0B, temp 			; set TX and RX enable flags

	sei
;>>>>>>>>>>>>>>>Store location of start of a sequence>>
;X is used to go through sequence, Y is used to write to memory
	ldi XH, HIGH(sequence_addr)
	ldi XL, LOW(sequence_addr)
	ldi YH, HIGH(sequence_addr) 
	ldi YL, LOW(sequence_addr)

;>>>>>>>>>>>>>>>A forever alone loop:(>>>>>>>>>>>>>>
main:
	cpi display_counter, 0
	breq display_first
	cpi display_counter, 1
	breq display_second
	cpi display_counter, 2
	breq display_third
	cpi display_counter, 3
	breq display_fourth
    rjmp main

;>>>>>>>>>>>>>>>Message display subroutines>>>>>>>>
; Four next subroutines follow same pattern. Display is cleared
; then top line is printed. It is moved to new line and a bottom
; line is printed (it is 20 characters further in the address than
; the previous line, unless it's 4th and 1st lines displayed).
; Then five second delay is called.
display_first:
	rcall clr_disp
	; Print line 1
	ldi start_high, HIGH(sequence_addr)
	ldi start_low, LOW(sequence_addr)
	rcall print_line
	; Jump to new line
	ldi output, newline
	rcall write_cmd
	rcall long_wait
	; Print line 2
	ldi start_high, HIGH(sequence_addr+20)
	ldi start_low, LOW(sequence_addr+20)
	rcall print_line
	inc display_counter
	rcall five_sec_delay
	rjmp main

display_second:
	rcall clr_disp
	; Print line 2
	ldi start_high, HIGH(sequence_addr+20)
	ldi start_low, LOW(sequence_addr+20)
	rcall print_line
	; Jump to new line
	ldi output, newline
	rcall write_cmd
	rcall long_wait
	; Print line 3
	ldi start_high, HIGH(sequence_addr+40)
	ldi start_low, LOW(sequence_addr+40)
	rcall print_line
	inc display_counter
	rcall five_sec_delay
	rjmp main

display_third:
	rcall clr_disp
	; Print line 3
	ldi start_high, HIGH(sequence_addr+40)
	ldi start_low, LOW(sequence_addr+40)
	rcall print_line
	; Jump to new line
	ldi output, newline
	rcall write_cmd
	rcall long_wait
	; Print line 4
	ldi start_high, HIGH(sequence_addr+60)
	ldi start_low, LOW(sequence_addr+60)
	rcall print_line
	inc display_counter
	rcall five_sec_delay
	rjmp main

display_fourth:
	rcall clr_disp
	; Print line 4
	ldi start_high, HIGH(sequence_addr+60)
	ldi start_low, LOW(sequence_addr+60)
	rcall print_line
	; Jump to new line
	ldi output, newline
	rcall write_cmd
	rcall long_wait
	; Print line 3
	ldi start_high, HIGH(sequence_addr)
	ldi start_low, LOW(sequence_addr)
	rcall print_line
	ldi display_counter, 0
	rcall five_sec_delay
	rjmp main

;>>>>>>>>>>>>>>>Data received interrupt>>>>>>>>>>>>>
; One line can store 20 characters . Line ends either when 20 character is reached or when 
; enter is pressed.
input_handler:
	;Are we accepting any more input?
	cpi input_finished_flag, 0xFF
	breq end_input
	
	;receive input
	lds output, UDR0
	;echo back to terminal  ---- for testing purposes
	sts UDR0, output
	
	;Was just recently received character a new line(enter)?
	cpi output, enter_input
	breq enter_pressed
	
	;It's not enter, has there been 21 character input already (end of line on LCD)?
	cpi char_counter, 20
	brge input_new_line
	rjmp continue_input
	
	enter_pressed:
	; Fill up the memory with empty spaces to reach LCD's line length
	push temp
	ldi temp, space
	fill_line:
	st Y+, temp
	inc char_counter
	cpi char_counter, 20
	brlo fill_line
	pop temp

	input_new_line:
	; Has there been 4 lines in total? If so, end input_handler, accept no more input
	cpi line_counter, 3
	breq input_finished
	; Increase line counter
	inc line_counter
	; Restart number of character in one line counter 
	ldi char_counter, 0
	rjmp end_input

	continue_input:
	;Store it in memory, got to one higher memory place
	st Y+, output
	inc char_counter
	rjmp end_input

	input_finished:
	; set input_finished_flag to 0xFF, so input is finished, taking no more input
	com input_finished_flag 
	end_input:
	reti

;>>>>>>>>>>>>>>>Printing current line>>>>>>>>>>>>>>>
print_line:
	mov XH, start_high
	mov XL, start_low
	ldi char_counter, 0

	cont_printing:
	cpi char_counter, 20
	breq end_printing
	inc char_counter
	ld output, X+
	push temp
	rcall write_char
	pop temp
	rjmp cont_printing

	end_printing:
	ldi char_counter, 0
	ret
;>>>>>>>>>>>>>>>Five second delay>>>>>>>>>>>>>>>>>
five_sec_delay:
	push r18
	push r19
	push r20
    ldi  r18, 26
    ldi  r19, 94
    ldi  r20, 111
L1: dec  r20
    brne L1
    dec  r19
    brne L1
    dec  r18
    brne L1
    nop
	pop r20
	pop r19
	pop r18
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
    rjmp delay_counter

;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
;>>>>>>>>>>>>>>>>>>>>Lab 5_init_HT_2016.asm>>>>>>
;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
init_disp:	
	rcall power_up_wait			
	ldi output, bitmode4	   	 
	rcall write_nibble				
	rcall short_wait				  
	ldi output, display_control	
	rcall write_cmd					
	rcall short_wait				 
	ret

clr_disp:	
	ldi output, clear			
	rcall write_cmd			  
	rcall long_wait			    
	ret

write_char:		
	ldi RS, 0b00100000		
	rjmp write
write_cmd: 	
	clr RS								
write:	
	mov temp, output					 
	andi output, 0b11110000			
	swap output								   
	or output, rs								 
	rcall write_nibble						  
	mov output, temp					  
	andi output, 0b00001111			
	or output, rs								

write_nibble:
	rcall switch_output						
	nop												  
	sbi PORTB, 5								
	nop
	nop												  
	cbi PORTB, 5								
	nop
	nop												 
	ret

short_wait:	
	clr zh					; approx 50 us
	ldi zl, 30
	rjmp wait_loop
long_wait:	
	ldi zh, HIGH(1000)		; approx 2 ms
	ldi zl, LOW(1000)
	rjmp wait_loop
dbnc_wait:	
	ldi zh, HIGH(4600)		; approx 10 ms
	ldi zl, LOW(4600)
	rjmp wait_loop
power_up_wait:
	ldi zh, HIGH(9000)		; approx 20 ms
	ldi zl, LOW(9000)

wait_loop:	
	sbiw z, 1				; 2 cycles
	brne wait_loop			; 2 cycles
	ret

switch_output:
	push temp
	clr temp
	sbrc output, 0				; D4 = 1?
	ori temp, 0b00000100		; Set pin 2 
	sbrc output, 1				; D5 = 1?
	ori temp, 0b00001000		; Set pin 3 
	sbrc output, 2				; D6 = 1?
	ori temp, 0b00000001		; Set pin 0 
	sbrc output, 3				; D7 = 1?
	ori temp, 0b00000010		; Set pin 1 
	sbrc output, 4				; E = 1?
	ori temp, 0b00100000		; Set pin 5 
	sbrc output, 5				; RS = 1?
	ori temp, 0b10000000		; Set pin 7 (wrong in previous version)
	out PORTB, temp
	pop temp
	ret

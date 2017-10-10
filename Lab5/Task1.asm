;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
;   1DT301, Computer Technology I
;   Date: 2017-10-10
;   Authors:
;                       Indre
;                       Georgiana
;
;   Lab number:         5
;   Title:              Display % on LCD.
;
;   Hardware:           STK600, CPU ATmega2560
;
;   Function:           Displays % character on LCD.
;
;   Input ports:        None.
;
;   Output ports:       LCD on PORTE
;
;   Subroutines:        loop,
;                       subourtines from Lab 5_init_HT_2016.asm
;   Included files:     m2560def.inc
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

.equ percent = 0b0010_0101
.equ bitmode4 = 0b0000_0010
.equ clear = 0b0000_0001
.equ display_control = 0b0000_1111


.cseg
.org 0x00
	rjmp reset

.org 0x72

reset:
;>>>>>>>>>>>>>>>>>>>>Initialize stack pointer>>>>>>>>
	ldi temp, HIGH(RAMEND)
	out SPH, temp
	ldi temp, LOW(RAMEND)
	out SPL, temp
;>>>>>>>>>>>>>>>>>>>>Set data direction registers>>>>	
	ser temp						; sets temp to 0xFF
	out DDRE, temp			 ; PORTE as output
	clr temp						 ; temp to 0x00
	out PORTE, temp
;>>>>>>>>>>>>>>>>>>>>Initialize display>>>>>>>>>>>>>
	rcall init_disp					; Initializing display using Lab_5_init_HT_2016.asm file

;>>>>>>>>>>>>>>>>>>>>Write '%' to LCD>>>>>>>>>>>>>
	ldi output, percent
	rcall write_char

;>>>>>>>>>>>>>>>>>>>>Loop forever>>>>>>>>>>>>>>>
loop:
	rjmp loop			; loop forever

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
	sbi PORTE, 5								
	nop
	nop												  
	cbi PORTE, 5								
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
	out PORTE, temp
	pop temp
	ret







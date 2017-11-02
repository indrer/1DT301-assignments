/*>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
*   1DT301, Computer Technology I
*   Date: 2017-11-02
*   Authors:
*                       Indre
*                       Georgiana
*
*   Lab number:         6
*   Title:              Task 3. Write a program that changes text strings on the display.
*
*   Hardware:           STK600, CPU ATmega2560, CyberDisplay
*
*   Function:           Displays 4 lines of text on the display that are scrolled each 5 seconds (3 lines at once). 
*
*   Input ports:        None.
*
*   Output ports:       RX and TX on PINE0 and PINE1
*
*   Subroutines:        main,
*                       final_msg(),
*                       send_message(char data),
*                       void print_bottom (char* message),
*                       void print_top (char* first_string, char* last_string)
*
*   Other information:  None
*   Changes in program: 
*                       2017 - 11 - 02:
*                           File created, task finished
*
*                       2017 - 11 - 03:
*                           Comments added, header added.
*<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<*/
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <avr/io.h>
// Communication speed is 2400 bps, at 1MHz
#define UBRR_VAL 24
#define F_CPU 1843200UL
#include <util/delay.h>

void print_top (char* first_string, char* last_string);
void print_bottom (char* message);
void send_message (char data);
void final_msg ();
int main(void) {
	// Set UBRR value, enable transmitting
	// We only need to print out a character, therefore we don't need to receive anything
	char* words[4] = {"Computer Science, 2o17", "Computer Technology", "Assignment #6", "Change after 5 sec."};
	UBRR1L = UBRR_VAL;
	UCSR1B = (1 << TXEN1);
	int i = 0;
	while(1) {
		print_top(words[i], words[(i+1)%4]);
		print_bottom(words[(i+2)%4]);
		final_msg();
		_delay_ms(5000);
		i++;
		if (i==4) {
			i = 0;
		}
	}
	return 0;
}

void final_msg () {
	char final_message[13] = {0};
	sprintf(final_message, "\rZD0013C\n");
	for (int i = 0; i< 11; i++) {
		send_message(final_message[i]);
	}
}

void send_message (char data) {
	// Wait while data register is empty
	while ( !(UCSR1A & (1<<UDRE1)) ) ;
	//Send data
	UDR1 = data;
}

void print_top (char* first_string, char* last_string) {
	//Calculating lengths of strings
	char printout[150] = "\rAO0001";
	strcat(printout, first_string);
	char for_spaces[150];
	strcpy(for_spaces, first_string);
	int len = strlen(for_spaces);
	for (int i = len; i < 24; i++) {
		strcat(printout, " ");
	}
	strcat(printout, last_string);
	len = strlen(printout);
	
	int i;
	int checksum = 0;
	for (i = 0; i < len; i++) {
		checksum = checksum + printout[i];
	}
	checksum = checksum % 256;
	
	char final_print[150];
	sprintf(final_print, "%s%02X\n", printout, checksum);
	len = strlen(final_print);
	for (int i = 0; i< len; i++) {
		send_message(final_print[i]);
	}
	
}

void print_bottom (char* message) {
	char printout[150] = "\rBO0001";
	strcat(printout, message);
	
	int len = strlen(printout);
	
	int i;
	int checksum = 0;
	for (i = 0; i < len; i++) {
		checksum = checksum + printout[i];
	}
	checksum = checksum % 256;
	
	char final_print[150];
	sprintf(final_print, "%s%02X\n", printout, checksum);
	len = strlen(final_print);
	for (int i = 0; i< len; i++) {
		send_message(final_print[i]);
	}
	
}

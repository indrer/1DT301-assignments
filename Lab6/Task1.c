/*>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
*   1DT301, Computer Technology I
*   Date: 2017-11-02
*   Authors:
*                       Indre
*                       Georgiana
*
*   Lab number:         6
*   Title:              Task 1, Display "0" on CyberDisplay.
*
*   Hardware:           STK600, CPU ATmega2560, CyberDisplay
*
*   Function:           Displays 0 character on CyberDisplay.
*
*   Input ports:        None.
*
*   Output ports:       RX and TX on PINE0 and PINE1
*
*   Subroutines:        main(),
*                       final_msg(),
*                       send_message(char data),
*                       construct_message(char* character)
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
#include <avr/io.h>
// Communication speed is 2400 bps, at 1MHz
#define UBRR_VAL 24

void construct_message(char* character);
void send_message (char data);
void final_msg ();
int main(void) {
	// Set UBRR value, enable transmitting
	// We only need to print out a character, therefore we don't need to receive anything
	UBRR1L = UBRR_VAL;
	UCSR1B = (1 << TXEN1);
	char* displayed_character = "O";
	construct_message(displayed_character);
	final_msg();

	
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

void construct_message(char* character) {
	char beginning[9] = {0};
	sprintf(beginning, "\rAO0001%s", character);
	// Message starts with 0x0D-Carriage Return(in ascii)-\r
	// A is used from the C lecture 3, slide 37
	// Information message command is O0001
	int i;
	int checksum = 0;
	for (i = 0; i < 9; i++) {
		checksum = checksum + beginning[i];
	}
	checksum = checksum % 256;
	// 0x0a -New Line-\n
	char msg[13] = {0};
	sprintf(msg, "%s%02X\n", beginning, checksum);

	for (int i = 0; i< 13; i++) {
		send_message(msg[i]);
	}
}

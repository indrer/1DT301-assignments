/*>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
*   1DT301, Computer Technology I
*   Date: 2017-11-02
*   Authors:
*                       Indre
*                       Georgiana
*
*   Lab number:         6
*   Title:              Task 4, Display text on CyberDisplay.
*
*   Hardware:           STK600, CPU ATmega2560, CyberDisplay
*
*   Function:           Displays text typed to console via serial communication on CyberDisplay,
*                       text can be displayed on several lines.
*
*   Input ports:        None.
*
*   Output ports:       RX and TX on PINE0 and PINE1
*
*   Subroutines:        main(),
*                       final_msg(),
*                       send_message(char data),
*                       receive_input(),
*                       print_all (char* first, char* second, char* third),
*                       print_message (char cmd, char* msg, char* msg_2)
*                     
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

void print_message (char cmd, char* msg, char* msg_2);
char receive_input();
void send_message (char data);
void final_msg ();
void print_all ();


int main(void) {
	// line counter
	int line = 0;
	// character storage
	char printout[3][150] = {{0}, {0}, {0}};
	// number of characters per line (on single display only 3 lines fit, so more is not needed)
	int line_pos[3] = {0, 0, 0};
	// Set UBRR value, enable transmitting
	// We only need to print out a character, therefore we don't need to receive anything
	UBRR1L = UBRR_VAL;
	UCSR1B = (1 << TXEN1) | (1 << RXEN1);
	while(1) {
		// receive input
		char data = receive_input();
		// check if input is newline character (in our case + is for new line)
		if (data=='+') {
			line = (line + 1)%3;
		}
		// check if any numbers are input, if so, change line. numbers are not displayed
		else if (data=='1' || data == '2' || data == '3') {
			if (data == '1') {
				line = 0;
			}
			else if (data == '2') {
				line = 1;
			}
			else {
				line = 2;
			}
		}
		// store text in whichever line is selected
		else {
			if(line == 0 || line == 1) {
				printout[line][line_pos[line]] = data;
				line_pos[line]++;
				// if text has reached end of one line, start from the beginning of the same line again
				if (line_pos[line] >= 24) {
					line_pos[line] = 0;
				}
			}
			else if (line == 2) {
				printout[line][line_pos[line]] = data;
				line_pos[line]++;
				if (line_pos[line] >= 24) {
					line_pos[line] = 0;
				}
			}
		}
		// print all messages
		print_all(printout[0], printout[1], printout[2]);
		//final commend to display printout
		final_msg();
			
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

char receive_input() {
	while (!(UCSR1A & (1<<RXC1)));
	return UDR1;
}

void send_message (char data) {
	// Wait while data register is empty
	while ( !(UCSR1A & (1<<UDRE1)) ) ;
	//Send data
	UDR1 = data;
}
// prints 3 messages on the display, in 3 different lines
void print_all (char* first, char* second, char* third) {
	print_message('A', first, second);
	print_message('B', third, NULL);
}

void print_message (char cmd, char* msg, char* msg_2) {
	int len = 0;
	char printout[150] = "\rAO0001";
	printout[1] = cmd;
	// If it and A command, second line can also be filled, therefore
	// we need to see if first line needs to be filled with spaces to make sure that 
	// text gets displayed properly on the second line, from its beginning
	if (cmd == 'A') {
		strcat(printout, msg);
		char for_spaces[150];
		strcpy(for_spaces, msg);
		len = strlen(for_spaces);
		for (int i = len; i < 24; i++) {
			strcat(printout, " ");
		}
		strcat(printout, msg_2);
	}
	else {
		strcat(printout, msg);
	}
	
	len = strlen(printout);
	//calculating checksum
	int i;
	int checksum = 0;
	for (i = 0; i < len; i++) {
		checksum = checksum + printout[i];
	}
	checksum = checksum % 256;
	
	char final_print[150];
	//adding everything to the final string
	sprintf(final_print, "%s%02X\n", printout, checksum);
	len = strlen(final_print);
	//sending the message 
	for (int i = 0; i< len; i++) {
		send_message(final_print[i]);
	}
	
}

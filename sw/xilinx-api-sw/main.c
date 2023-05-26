/******************************************************************************
*
* Copyright (C) 2009 - 2014 Xilinx, Inc.  All rights reserved.
*
* Permission is hereby granted, free of charge, to any person obtaining a copy
* of this software and associated documentation files (the "Software"), to deal
* in the Software without restriction, including without limitation the rights
* to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
* copies of the Software, and to permit persons to whom the Software is
* furnished to do so, subject to the following conditions:
*
* The above copyright notice and this permission notice shall be included in
* all copies or substantial portions of the Software.
*
* Use of the Software is limited solely to applications:
* (a) running on a Xilinx device, or
* (b) that interact with a Xilinx device through a bus or interconnect.
*
* THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
* IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
* FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL
* XILINX  BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
* WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF
* OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
* SOFTWARE.
*
* Except as contained in this notice, the name of the Xilinx shall not be used
* in advertising or otherwise to promote the sale, use or other dealings in
* this Software without prior written authorization from Xilinx.
*
******************************************************************************/

/*
 * main.c: simple test application
 *
 * This application configures UART 16550 to baud rate 9600.
 * PS7 UART (Zynq) is not initialized by this application, since
 * bootrom/bsp configures it to baud rate 115200
 *
 * ------------------------------------------------
 * | UART TYPE   BAUD RATE                        |
 * ------------------------------------------------
 *   uartns550   9600
 *   uartlite    Configurable only in HW design
 *   ps7_uart    115200 (configured by bootrom/bsp)
 */

// Includes
#include <stdio.h>
#include <stdbool.h>
#include "platform.h"
#include "xbasic_types.h"
#include "xil_printf.h"		// API UART
#include "xgpio.h"			// API GPIO
#include "pem_aes.h"		// API AES

// Defines
#define LED_4BITS_CH	1
#define PUSH_BUTTONS_CH 2
#define RGB_CH	 		1
#define DIP_SWITCHES_CH 2

#define DEBUG

// Prototipos
void delay100ms_custom(void);
void delay50ms_custom(void);

#ifdef DEBUG
	Xuint32 read_result1[4], read_result2[4];
	void print_result(void);
	void run_test(Xuint32);
#endif

int main()
{
    init_platform();

    // Init GPIOs
    // GPIO0: led_4bits and push_buttons
    // GPIO1: rgb_leds and di_switches
    XGpio gpio0, gpio1;
    int status0, status1;
    
    // Inicializa periferico colocando informações na struct
    status0 = XGpio_Initialize(&gpio0,XPAR_AXI_GPIO_0_DEVICE_ID);
    status1 = XGpio_Initialize(&gpio1,XPAR_AXI_GPIO_1_DEVICE_ID);

    /*

    if(status0 == XST_SUCCESS)
    	print("GPIO 0 - Enable!\n\r");
    else
    	print("GPIO 0 - Not work\n\r");

    if(status1 == XST_SUCCESS)
       	print("GPIO 1 - Enable!\n\r");
    else
       	print("GPIO 1 - Not work\n\r");
	*/

    // Set direction
    // 0: Output
    // 1: Input
    XGpio_SetDataDirection(&gpio0,LED_4BITS_CH,0b0000);
    XGpio_SetDataDirection(&gpio0,PUSH_BUTTONS_CH,0b1111);
    XGpio_SetDataDirection(&gpio1,RGB_CH,0x000);
    XGpio_SetDataDirection(&gpio1,DIP_SWITCHES_CH,0b1111);

    #ifdef DEBUG
    
    //data1 : 00112233445566778899AABBCCDDEEFF
    //data2 : FFEEDDCCBBAA99887766554433221100
    //  key : 000102030405060708090A0B0C0D0E0F
    //   IV : CCCCCCCCAAAAAAAAFFFFFFFFEEEEEEEE

	#define KEY0 	0x03020100
    #define KEY1 	0x07060504
    #define KEY2 	0x0B0A0908
    #define KEY3 	0x0F0E0D0C

    #define DATA1_0	0x33221100
    #define DATA1_1	0x77665544
    #define DATA1_2	0xBBAA9988
    #define DATA1_3	0xFFEEDDCC

    #define DATA2_0	0xCCDDEEFF
    #define DATA2_1	0x8899AABB
    #define DATA2_2	0x44556677
    #define DATA2_3	0x00112233

    #define IV0		0xCCCCCCCC
    #define IV1		0xAAAAAAAA
    #define IV2		0xFFFFFFFF
    #define IV3		0xEEEEEEEE

    // Entradas do teste
    xil_printf("\n\n\r****************************************************\n\r");
    xil_printf("AES IP - Embedded Test");
    xil_printf("\n\r****************************************************\n\n\r");
    xil_printf("Inputs:\n\r");
    xil_printf("Data1:\t 0x00112233445566778899AABBCCDDEEFF\n\r");
    xil_printf("Data2:\t 0xFFEEDDCCBBAA99887766554433221100\n\r");
    xil_printf("Key:\t 0x000102030405060708090A0B0C0D0E0F\n\r");
    xil_printf("IV:\t 0xCCCCCCCCAAAAAAAAFFFFFFFFEEEEEEEE\n\n\r");

    // Escreve Key e IV (constantes)
    AES_writeKey(KEY0,KEY1,KEY2,KEY3);
    AES_writeIV(IV0,IV1,IV2,IV3);

    // Verifica se Key e IV foram escritos corretamente
    if(AES_getRegister(0) != KEY0 || AES_getRegister(8) != IV0) xil_printf("\n\rERROR!");
    if(AES_getRegister(1) != KEY1 || AES_getRegister(9) != IV1) xil_printf("\n\rERROR!");
    if(AES_getRegister(2) != KEY2 || AES_getRegister(10)!= IV2) xil_printf("\n\rERROR!");
    if(AES_getRegister(3) != KEY3 || AES_getRegister(11)!= IV3) xil_printf("\n\rERROR!");

    //run_test(ECB); // OK!
    //run_test(CBC); // OK!
    //run_test(PCBC);// OK!
    //run_test(CFB); // OK!
    //run_test(OFB); // OK!
    //run_test(CTR); // OK!

    xil_printf("\n\n\r****************************************************\n\r");
    xil_printf("END TEST");
    xil_printf("\n\r****************************************************\n\r");
    #endif

    // Rotina de pisca LED
    while(1)
    {
    	XGpio_DiscreteWrite(&gpio0,LED_4BITS_CH,0b1010);
    	delay50ms_custom();
    	XGpio_DiscreteWrite(&gpio1,RGB_CH,0b111100010001);
    	delay100ms_custom();
    	XGpio_DiscreteWrite(&gpio0,LED_4BITS_CH,0b0101);
    	delay50ms_custom();
    	XGpio_DiscreteWrite(&gpio1,RGB_CH,0b001010001111);
    	delay50ms_custom();
    }
    cleanup_platform();
    return 0;
}

void delay100ms_custom()
{
	for(int i=0; i<1000000; i++);
}

void delay50ms_custom()
{
	for(int i=0; i<500000; i++);
}

void print_result(void)
{
    xil_printf("\n\r0x%08x",AES_getRegister(12));
    xil_printf("\n\r0x%08x",AES_getRegister(13));
    xil_printf("\n\r0x%08x",AES_getRegister(14));
    xil_printf("\n\r0x%08x",AES_getRegister(15));
}

void run_test(Xuint32 MODE)
{
	if(MODE == CTR) AES_writeCounter(0,0);

    // Encrypt
	switch(MODE)
	{
	case ECB:
		xil_printf("\n\n\rECB MODE\n\r");
		break;
	case CBC:
		xil_printf("\n\n\rCBC MODE\n\r");
		break;
	case PCBC:
		xil_printf("\n\n\rPCBC MODE\n\r");
		break;
	case CFB:
		xil_printf("\n\n\rCFB MODE\n\r");
		break;
	case OFB:
		xil_printf("\n\n\rOFB MODE\n\r");
		break;
	case CTR:
		xil_printf("\n\n\rCTR MODE\n\r");
		break;
	}

    AES_writeData(DATA1_0,DATA1_1,DATA1_2,DATA1_3);
    AES_writeConfig(START,KEEP_COUNTER,ENCRYPT,MODE);
    xil_printf("first cipher block:");
    print_result();
    read_result1[0] = AES_getRegister(12);
    read_result1[1] = AES_getRegister(13);
    read_result1[2] = AES_getRegister(14);
    read_result1[3] = AES_getRegister(15);
    AES_writeData(DATA2_0,DATA2_1,DATA2_2,DATA2_3);
    AES_writeConfig(START,KEEP_COUNTER,ENCRYPT,MODE);
    xil_printf("\n\n\rsecond cipher block:\t");
    print_result();
    read_result2[0] = AES_getRegister(12);
    read_result2[1] = AES_getRegister(13);
    read_result2[2] = AES_getRegister(14);
    read_result2[3] = AES_getRegister(15);

    if(MODE == CTR) AES_writeCounter(0,0);
    if(MODE != ECB)
    {
    	AES_writeIV(IV0,IV1,IV2,IV3);
    }
    // Decrypt
    AES_writeData(read_result1[0],read_result1[1],read_result1[2],read_result1[3]);
    AES_writeConfig(START,KEEP_COUNTER,DECRYPT,MODE);
    xil_printf("\n\n\rfirst decrypted block:\t");
    print_result();
    AES_writeData(read_result2[0],read_result2[1],read_result2[2],read_result2[3]);
    AES_writeConfig(START,KEEP_COUNTER,DECRYPT,MODE);
    xil_printf("\n\n\rsecond decrypted block:\t");
    print_result();
}


/*        
data1 : 00112233445566778899AABBCCDDEEFF
data2 : FFEEDDCCBBAA99887766554433221100
key : 000102030405060708090A0B0C0D0E0F
IV : CCCCCCCCAAAAAAAAFFFFFFFFEEEEEEEE

ECB MODE
first cipher block     : 69C4E0D86A7B0430D8CDB78070B4C55A
second cipher block    : 1B872378795F4FFD772855FC87CA964D
first decrypted block  : 00112233445566778899AABBCCDDEEFF
second decrypted block : FFEEDDCCBBAA99887766554433221100

CBC MODE
first cipher block     : F6217F61B2D50A6AE6791F8C384B1E07
second cipher block    : 00E6F7C3F089B33AF8D701BEB170AF82
first decrypted block  : 00112233445566778899AABBCCDDEEFF
second decrypted block : FFEEDDCCBBAA99887766554433221100

PCBC MODE
first cipher block     : F6217F61B2D50A6AE6791F8C384B1E07
second cipher block    : 1766EA65883AE0BE5DE323B1431CBD54
first decrypted block  : 00112233445566778899AABBCCDDEEFF
second decrypted block : FFEEDDCCBBAA99887766554433221100

CFB MODE
first cipher block     : 79C571F93E6E91590576009881A3AB8E
second cipher block    : 3F778AF1BA19E580C751137195BCFF23
first decrypted block  : 00112233445566778899AABBCCDDEEFF
second decrypted block : FFEEDDCCBBAA99887766554433221100

OFB MODE
first cipher block     : 79C571F93E6E91590576009881A3AB8E
second cipher block    : 03219503DD5973187FADC74474E3F047
first decrypted block  : 00112233445566778899AABBCCDDEEFF
second decrypted block : FFEEDDCCBBAA99887766554433221100

CTR MODE
first cipher block     : 79C571F93E6E91590576009881A3AB8E
second cipher block    : 833441D22AD2BAAEEFAB5EA586AC0DF2
third cipher block     : E23BF25A445A52FAB2F0B29707572743
first decrypted block  : 00112233445566778899AABBCCDDEEFF
second decrypted block : FFEEDDCCBBAA99887766554433221100
third decrypted block  : FF23AC4500FFAABC8899AEEBCEDFFFEE
*/

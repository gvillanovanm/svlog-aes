/*
 * pem_aes.c
 *
 *  Created on: Apr 12, 2017
 *      Author: gvillanova
 */
#include "pem_aes.h"
#include "xbasic_types.h"

#define ENCRYPT_MASK  	0x00000001
#define DECRYPT_MASK  	0x00000002
#define KEYEXPAN_MASK 	0x00000004
#define MODE_MASK		0x00000038
#define SETMODE_MASK    0xFFFFFFF8

#define XPAR_AES_IP_AXI_BASEADDR 0x44A00000
Xuint32 *baseaddr_p = (Xuint32 *)XPAR_AES_IP_AXI_BASEADDR;

void AES_init(Xuint32 start)
{
	baseaddr_p[18] = baseaddr_p[18] | (start << 31);
}
void AES_writeKey(Xuint32 k0, Xuint32 k1, Xuint32 k2, Xuint32 k3)
{
    baseaddr_p[0] = k0;
    baseaddr_p[1] = k1;
    baseaddr_p[2] = k2;
    baseaddr_p[3] = k3;
}

void AES_writeData(Xuint32 d0, Xuint32 d1, Xuint32 d2, Xuint32 d3)
{
	baseaddr_p[4] = d0;
	baseaddr_p[5] = d1;
	baseaddr_p[6] = d2;
	baseaddr_p[7] = d3;
}

void AES_writeIV(Xuint32 IV0, Xuint32 IV1, Xuint32 IV2, Xuint32 IV3)
{
	baseaddr_p[8]  = IV0;
	baseaddr_p[9]  = IV1;
	baseaddr_p[10] = IV2;
	baseaddr_p[11] = IV3;
}

void AES_writeCounter(Xuint32 c0, Xuint32 c1)
{
	baseaddr_p[16] = c0;
	baseaddr_p[17] = c1;
}

void AES_writeResult(Xuint32 r0, Xuint32 r1, Xuint32 r2, Xuint32 r3)
{
	baseaddr_p[12] = r0;
	baseaddr_p[13] = r1;
	baseaddr_p[14] = r2;
	baseaddr_p[15] = r3;
}

void AES_setMode(Xuint32 mode)
{
	baseaddr_p[18] = (baseaddr_p[18] & SETMODE_MASK) | mode;
}

void AES_setCounterZero(Xuint32 counter)
{
	baseaddr_p[18] = baseaddr_p[18] | (counter << 4);
}

void AES_setEncrypt(Xuint32 encrypt)
{
	baseaddr_p[18] = baseaddr_p[18] | (encrypt << 3);
}

void AES_writeConfig(Xuint32 start, Xuint32 counter_zero, Xuint32 decrypt, Xuint32 mode)
{
	baseaddr_p[18] = start << 31 | counter_zero << 4 | decrypt << 3 | mode;
}

bool AES_getEncryption(void)
{
	if(((Xuint32)ENCRYPT_MASK & baseaddr_p[18]))
		return TRUE;
	else
		return FALSE;
}

bool AES_getDecryption(void)
{
	if(((Xuint32)DECRYPT_MASK & baseaddr_p[18]))
		return TRUE;
	else
		return FALSE;
}

Xuint32 AES_getRegister(Xuint32 i)
{
	return baseaddr_p[i];
}

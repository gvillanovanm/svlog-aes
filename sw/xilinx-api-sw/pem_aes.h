/*
 * pem_aes.h
 *
 *  Created on: Apr 12, 2017
 *      Author: gvillanova
 */

#ifndef SRC_PEM_AES_H_
#define SRC_PEM_AES_H_
#include <stdbool.h>
#include "xbasic_types.h"

// Defines para configuração do AES IP
#define ECB 	0b000
#define CBC		0b001
#define PCBC 	0b010
#define CFB		0b011
#define OFB 	0b100
#define CTR 	0b101

#define ENCRYPT 0
#define DECRYPT 1

#define KEEP_COUNTER 0
#define ZERO_COUNTER 1

#define NOSTART 0
#define START 	1

/* API AES-IP */
void AES_init(Xuint32);
void AES_writeKey(Xuint32,Xuint32,Xuint32,Xuint32);
void AES_writeData(Xuint32,Xuint32,Xuint32,Xuint32);
void AES_writeIV(Xuint32,Xuint32,Xuint32,Xuint32);
void AES_writeCounter(Xuint32,Xuint32);
void AES_writeResult(Xuint32,Xuint32,Xuint32,Xuint32);
void AES_setMode(Xuint32);
void AES_setCounterZero(Xuint32);
void AES_setEncrypt(Xuint32);
void AES_writeConfig(Xuint32,Xuint32,Xuint32,Xuint32);
bool AES_getEncryption(void); 
bool AES_getDecryption(void); 
Xuint32 AES_getRegister(Xuint32); 

#endif /* SRC_PEM_AES_H_ */

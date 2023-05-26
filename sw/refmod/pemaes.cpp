#include <iomanip>
#include <iostream>
#include <string.h>
#include <type_traits>

#include "cryptopp/modes.h"
#include "cryptopp/aes.h"
#include "cryptopp/filters.h"
#include "cryptopp/hex.h"
#include "pemaes.h"


pemaes::pemaes(){
	cipher = new byte[CryptoPP::AES::BLOCKSIZE];
	key = new byte[CryptoPP::AES::BLOCKSIZE];
	data = new byte[CryptoPP::AES::BLOCKSIZE];
 	decrypted = new byte[CryptoPP::AES::BLOCKSIZE];
}
pemaes::~pemaes(){

}

byte* pemaes::getKey(){
	return key;
}
byte* pemaes::getPlainText(){
	return data;
}
byte* pemaes::getCipher(){
	return cipher;
}
byte* pemaes::getDecrypted(){
	return decrypted;
}

void pemaes::setKey(byte* K){
	key = K;

}

void pemaes::setPlainText(byte *PT){
	data = PT;
}
void pemaes::setCipher(byte *C){
	cipher = C;
}
void pemaes::encrypt(){
	
	CryptoPP::AES::Encryption aesEncryption(key, CryptoPP::AES::DEFAULT_KEYLENGTH);
	CryptoPP::ECB_Mode_ExternalCipher::Encryption ecbEncryption(aesEncryption);
	CryptoPP::StreamTransformationFilter stfEncryptor(ecbEncryption, new CryptoPP::ArraySink (cipher,CryptoPP::AES::BLOCKSIZE) , CryptoPP::StreamTransformationFilter::NO_PADDING);
	stfEncryptor.Put((byte*)data, CryptoPP::AES::BLOCKSIZE);
	stfEncryptor.MessageEnd();
	
 	/*CryptoPP::HexEncoder hex;
	std::string r1;
	hex.Attach(new CryptoPP::StringSink(r1));
	hex.Put(cipher, CryptoPP::AES::BLOCKSIZE);
	hex.MessageEnd();      
	std::cout << "cipher encrypted";
	std::cout <<" : ";
	std::cout << r1 << std::endl;*/
}



void pemaes::decrypt(){	
		
/* 	CryptoPP::HexEncoder hex;
	std::string r1;
	hex.Attach(new CryptoPP::StringSink(r1));
	hex.Put(cipher, CryptoPP::AES::BLOCKSIZE);
	hex.MessageEnd();      
	std::cout << "cipher to be decripted";
	std::cout <<" : ";
	std::cout << r1 << std::endl;*/

	CryptoPP::AES::Decryption aesDecryption(key, CryptoPP::AES::DEFAULT_KEYLENGTH);
	CryptoPP::ECB_Mode_ExternalCipher::Decryption ecbDecryption( aesDecryption);
	CryptoPP::StreamTransformationFilter stfDecryptor(ecbDecryption, new CryptoPP::ArraySink(decrypted, CryptoPP::AES::BLOCKSIZE), CryptoPP::StreamTransformationFilter::NO_PADDING );
	stfDecryptor.Put((byte*)cipher, CryptoPP::AES::BLOCKSIZE);
	stfDecryptor.MessageEnd();


		
 /*	CryptoPP::HexEncoder hex2;
	std::string r2;
	hex2.Attach(new CryptoPP::StringSink(r2));
	hex2.Put(decrypted, CryptoPP::AES::BLOCKSIZE);
	hex2.MessageEnd();      
	std::cout << "text decrypted";
	std::cout <<" : ";
	std::cout << r2 << std::endl;*/


}


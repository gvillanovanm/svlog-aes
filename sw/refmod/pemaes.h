#ifndef PEMAES_H
#define PEMAES_H

class pemaes {
private:
	byte* data;
	byte* key;
	byte* cipher;
	byte* decrypted;

public:
	pemaes();
	~pemaes();
	void setKey(byte *);
	void setPlainText(byte *);
	void setCipher(byte *);
	void encrypt();
	void decrypt();
	byte* getKey();
	byte* getPlainText();
	byte* getCipher();
	byte* getDecrypted();
};
#endif

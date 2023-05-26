= Testbench Procedural IP-AES

== Códigos
	* tb_aes_noamba.sv: 
		- Testa o IP com todos os módulos, exceto a interface AMBA AXI4-Lite;
		- Para rodar esse teste deve-se passar o modo de criptação, e.g.: $ make MODE=CBC
		- Os modos são:
		(Encriptar) | (Decriptar)
			ECB |   IECB
			CBC |   ICBC
		       PCBC |   IPCBC
			CFB |   ICFB
			OFB |   IOFB
			CTR |   ICTR


== Códigos
	* tb_ip_aes.sv: 
		- Testa o IP com todos os módulos;
		- Para rodar esse teste deve-se passar o modo de criptação, e.g.: $ make MODE=CBC
		- Os modos são:
		(Encriptar) | (Decriptar)
			ECB |   IECB
			CBC |   ICBC
		       PCBC |   IPCBC
			CFB |   ICFB
			OFB |   IOFB
			CTR |   ICTR

== Tempo de processamento em cada modo
		MODE	| COM EXPANSÃO DE CHAVE | SEM EXPANSÃO DE CHAVE
	  	    ECB |	   58		|	16
		   IECB |	   58		|	16
		    CBC |	   62		|	20
		   ICBC |	   62		|	20
		   PCBC |	   62		|	20
		  IPCBC |	   62		|	20
		    CFB |	   62		|	20
		   ICFB |	   62		|	20
		    OFB |  	   60		|	18
		   IOFB |  	   62		|	20
		    CTR |  	   64		|	22
		   ICTR |  	   64		|	22

== Timing para expansão de chave
		 MODE	| PRE-EXPANSÃO DE CHAVE |  EXPANSÃO DE CHAVE |   POS-EXPANSAO
	  	    ECB |	   02		|	 42          |       14
		   IECB |	   02		|	 42          |       14
		    CBC |	   04		|	 42          |       16
		   ICBC |	   04		|	 42          |       16
		   PCBC |	   04		|	 42          |       16
		  IPCBC |	   04		|	 42          |       16
		    CFB |	   04		|	 42          |       16
		   ICFB |	   04		|	 42          |       16
		    OFB |  	   03		|	 42          |       15
		   IOFB |  	   04		|	 42          |       16
		    CTR |  	   05		|	 42          |       17
		   ICTR |  	   05		|	 42          |       17

== Equipe 
	* Gabriel Villanova
	* Rubens Roux
	* Samuel Mendes

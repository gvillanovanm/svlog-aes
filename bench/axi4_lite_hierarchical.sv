interface aw #(
  int unsigned SIZE_ADDR = 32
);
        import axi4_types::*;
	logic VALID;
	logic READY;
	logic [SIZE_ADDR-1:0]ADDR;
	logic [2:0]PROT;
endinterface

interface w #(
  int unsigned SIZE_WORD = 32,
  int unsigned SIZE_STRB = SIZE_WORD/8
);
        import axi4_types::*;
	logic VALID;
	logic READY;
	logic [SIZE_WORD-1:0]DATA;
	logic [SIZE_STRB-1:0]STRB;
endinterface

interface b();
        import axi4_types::*;
	logic VALID;
	logic READY;
	axi4_resp_el RESP;
endinterface

interface ar #(
  int unsigned SIZE_ADDR = 32
);
        import axi4_types::*;
	logic VALID;
	logic READY;
	logic [SIZE_ADDR-1:0]ADDR;
	logic [2:0]PROT;
endinterface

interface r #(
  int unsigned SIZE_WORD = 32
);
        import axi4_types::*;
	logic VALID;
	logic READY;
	logic [SIZE_WORD-1:0]DATA;
	axi4_resp_el RESP;
endinterface

interface axi4_lite_hierarchical# (
	// Constantes default: 
	// 		Palavras de 32 bits
	// 		4 bytes
	int unsigned SIZE_WORD=32,
	int unsigned SIZE_STRB=SIZE_WORD/8,
	int unsigned SIZE_ADDR=SIZE_WORD
	) (
	input logic ACLK,
	input logic ARSTn);

        import axi4_types::*;
	// WRITE CHANNEL
	aw #(SIZE_ADDR)            AW();
	w  #(SIZE_WORD, SIZE_STRB)  W();
	b                           B();
	// END

	// READ CHANNEL
	ar #(SIZE_ADDR)            AR();
	r  #(SIZE_WORD)             R();
	// END
endinterface

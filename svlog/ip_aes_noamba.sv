/**

  ******************************************************************************
  *
  * @university	UFCG (Universidade Federal de Campina Grande)
  * @lab 	 	embedded
  * @project 	RISC-V.br
  * @ip      	AES (Advanced Encryption Standard)
  *
  * @file    	ip_aes_noamba.sv
  * @authors 	Gabriel Villanova	
  * @version 	V1.0
  * @date    	01 february 2017
  * @brief   
  *		The module control define the control words for the datapath depending 
  *		on the operating mode. It manages the use of registers by controlling 
  *  	the enable_amba signal.
  *
  ****************************************************************************** 

**/

module ip_aes_noamba (
	input logic ACLK,
	input logic ARSTn,

	output logic enable_amba,

	/* AMBA */
 	input  logic wr_amba,
 	input  logic [3:0]  strb,
 	input  logic [31:0] data_in,
 	input  logic [31:0] addr_rc,
 	input  logic [31:0] addr_wc,
 	output logic [31:0] data_out
);

// wires MUXs A, B
logic [127:0] r0;
logic [127:0] r1;
logic [127:0] r2;
logic [63:0]  r3; 
logic [31:0]  reg_command;
logic [10:0]  control_word;
logic [127:0] busA;
logic [127:0] busB;
logic [127:0] key;

// wires CONTROL and Reg. File
logic [127:0] busR;
logic [127:0] busULA;
logic [127:0] busAES;
logic wr_control;

// wire AES and Reg. File
logic expanding;

mux_busA mux_A (
	.r0(r0),
	.r1(r1),
	.r2(r2),
	.r3(r3),
	.SEL_busA(control_word[10:9]),
	.busA(busA)
);

mux_busB mux_B (
	.r0(r0),
	.r1(r1),
	.r2(r2),
	.r3(r3),
	.SEL_busB(control_word[8:7]),
	.busB(busB)
);

mux_busR mux_R (
	.busULA(busULA),
	.busAES(busAES),
	.SEL_busR(control_word[6]),
	.busR(busR)
);

ula ula (
	.busA(busA),
	.busB(busB),
	.FS(control_word[1:0]),
	.busULA(busULA)
);

register_file reg_file (
	.ACLK(ACLK), 
	.ARSTn(ARSTn),

	// AES
	.expanding(expanding),

	// AMBA
	.wr_amba(wr_amba), 
	.wr_control(wr_control), 
	.enable_amba(enable_amba),
	.data_in(data_in),
	.addr_rc(addr_rc),
	.addr_wc(addr_wc),
	.strb(strb),
	.data_out(data_out),

	// CONTROL
	.reg_dest(control_word[5:4]),
	.busR(busR),
	.r0(r0), 
	.r1(r1), 
	.r2(r2), 
	.r3(r3), 
	.key(key), 
	.reg_command(reg_command)
);

aes aes(
	.ACLK(ACLK), 
	.ARSTn(ARSTn),
	.start_AES(control_word[3]), 
	.decrypt(control_word[2]), 
	.key(key), 
	.busB(busB),
	.valid_AES(valid_AES),
	.expanding(expanding),
	.busAES(busAES)
);

control control (
 	.ACLK(ACLK),
	.ARSTn(ARSTn),
	.enable_amba(enable_amba),
	.wr_control(wr_control),
	.valid_AES(valid_AES),
	.reg_command(reg_command),
	.control_word(control_word)
);

/* control_word: | SEL_busA[1:0] | SEL_busB[1:0] | SEL_busR | reg_DEST[1:0] | start_AES | decrypt | FS[1:0] (11bits) */
/*               |     XX        |      XX       |    X     |      XX       |     X     |    X	  |   XX    (11bits) */

endmodule

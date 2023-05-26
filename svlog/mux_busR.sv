/**

  ******************************************************************************
  *
  * @university	UFCG (Universidade Federal de Campina Grande)
  * @lab 	 	embedded
  * @project 	RISC-V.br
  * @ip      	AES (Advanced Encryption Standard)
  *
  * @file    	mux_busR.sv
  * @authors  	Gabriel Villanova	
  * @version 	V1.0
  * @date    	01 february 2017
  * @brief   
  *		MUX to selection the result of ULA or AES in bus R.
  *
  ****************************************************************************** 

**/

module mux_busR (
	input  logic [127:0] busULA,
	input  logic [127:0] busAES,

	input logic SEL_busR,

	output logic [127:0] busR
);

always_comb
	busR = (SEL_busR) ? busAES : busULA;
endmodule
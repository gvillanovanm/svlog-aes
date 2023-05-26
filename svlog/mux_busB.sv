/**

  ******************************************************************************
  *
  * @university	UFCG (Universidade Federal de Campina Grande)
  * @lab 	 	embedded
  * @project 	RISC-V.br
  * @ip      	AES (Advanced Encryption Standard)
  *
  * @file    	mux_busB.sv
  * @authors  	Gabriel Villanova	
  * @version 	V1.0
  * @date    	01 february 2017
  * @brief   
  *		MUX to selection the register r0, r1, r2 or r3 in bus B.
  *
  ****************************************************************************** 

**/

module mux_busB (
	input  logic [127:0] r0,
	input  logic [127:0] r1,
	input  logic [127:0] r2,
	input  logic [63:0] r3,

	input logic [1:0] SEL_busB,

	output logic [127:0] busB
);

always_comb
begin
	case(SEL_busB)
		2'b00:
			busB = r0;
		2'b01:
			busB = r1;
		2'b10:
			busB = r2;
		2'b11:
			busB = {64'b0,r3};
	endcase // SEL_busB
end
endmodule

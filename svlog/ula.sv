/**

  ******************************************************************************
  *
  * @university	UFCG (Universidade Federal de Campina Grande)
  * @lab 	 	embedded
  * @project 	RISC-V.br
  * @ip      	AES (Advanced Encryption Standard)
  *
  * @file    	ula.sv
  * @authors  	Gabriel Villanova	
  * @version 	V1.0
  * @date    	01 february 2017
  * @brief   
  *		The module calculates the operations of xor, increment and move.
  *
  ****************************************************************************** 

**/

module ula (
	input logic [127:0] busA,
	input logic [127:0] busB,

	input logic  [1:0] FS,

	output logic [127:0] busULA
);

always_comb
begin
	case(FS)
		2'b00:   busULA = busA ^ busB;
		2'b01:
    begin
      busULA = 0;
      {busULA[7:0],busULA[15:8],busULA[23:16],busULA[31:24],busULA[39:32],busULA[47:40],busULA[55:48],busULA[63:56]} = {busA[7:0],busA[15:8],busA[23:16],busA[31:24],busA[39:32],busA[47:40],busA[55:48],busA[63:56]} + 1;
    end
		default: busULA = busA;
	endcase
end
endmodule
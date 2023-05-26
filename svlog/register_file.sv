/**

  ******************************************************************************
  *
  * @university	UFCG (Universidade Federal de Campina Grande)
  * @lab 	 	embedded
  * @project 	RISC-V.br
  * @ip      	AES (Advanced Encryption Standard)
  *
  * @file    	register_file.sv
  * @authors  	Rubens Roux
  *				Gabriel Villanova	
  * @version 	V1.0
  * @date    	01 february 2017
  * @brief   
  *		Register file
  *
  ****************************************************************************** 

**/

module register_file (
	input  logic ACLK,  
	input  logic ARSTn,
	input  logic expanding,
	input  logic wr_amba,
	input  logic wr_control,
	input  logic enable_amba,
	input  logic [31:0]  data_in, 
	input  logic [31:0]  addr_rc, 
	input  logic [31:0]  addr_wc, 
	input  logic [3:0]   strb,
	output logic [31:0]  data_out,
	input  logic [1:0]   reg_dest, 
	input  logic [127:0] busR,
	output logic [127:0] r0, 
	output logic [127:0] r1, 
	output logic [127:0] r2, 
	output logic [127:0] key, 
	output logic [63:0]  r3, 
	output logic [31:0] reg_command
);

logic [2:0] mode;

logic[31:0] register[19];
logic[31:0] status;

always_comb
begin
	mode = register[18][2:0];

	if(addr_rc[7:0] < 8'h4C)
		data_out = register[addr_rc[7:2]];
	else
		data_out = status;

	//key = {register[3],register[2],register[1],register[0]};
	//r0 = {register[7],register[6],register[5],register[4]};
	//r1 = {register[11],register[10],register[9],register[8]};
	//r2 = {register[15],register[14],register[13],register[12]};
	//r3 = {register[17],register[16]};
	key = {register[0][7:0],register[0][15:8],register[0][23:16],register[0][31:24],
		   register[1][7:0],register[1][15:8],register[1][23:16],register[1][31:24],
		   register[2][7:0],register[2][15:8],register[2][23:16],register[2][31:24],
		   register[3][7:0],register[3][15:8],register[3][23:16],register[3][31:24]};
	r0  = {register[4][7:0],register[4][15:8],register[4][23:16],register[4][31:24],
		   register[5][7:0],register[5][15:8],register[5][23:16],register[5][31:24],
		   register[6][7:0],register[6][15:8],register[6][23:16],register[6][31:24],
		   register[7][7:0],register[7][15:8],register[7][23:16],register[7][31:24]};
	r1  = {register[8][7:0],register[8][15:8],register[8][23:16],register[8][31:24],
		   register[9][7:0],register[9][15:8],register[9][23:16],register[9][31:24],
		   register[10][7:0],register[10][15:8],register[10][23:16],register[10][31:24],
		   register[11][7:0],register[11][15:8],register[11][23:16],register[11][31:24]};
	r2  = {register[12][7:0],register[12][15:8],register[12][23:16],register[12][31:24],
		   register[13][7:0],register[13][15:8],register[13][23:16],register[13][31:24],
		   register[14][7:0],register[14][15:8],register[14][23:16],register[14][31:24],
		   register[15][7:0],register[15][15:8],register[15][23:16],register[15][31:24]};
	r3  = {register[16][7:0],register[16][15:8],register[16][23:16],register[16][31:24],
		   register[17][7:0],register[17][15:8],register[17][23:16],register[17][31:24]};
	reg_command = {register[18]};
end

always_ff @(posedge ACLK) begin
	if(!ARSTn)
	begin
		foreach(register[i])
			register[i] <= 0;
		status <= 0;
	end
	else
	begin
		status = (!enable_amba || register[18][31]) ?  {26'b0,
														(mode < 3'b110) ? mode : {1'b0, mode[1:0]},
														expanding,
														(expanding == 0) ? register[18][3] : 1'b0,
														(expanding == 0) ? ~register[18][3] : 1'b0} : {1'b1, 31'b0};

		if(enable_amba)
		begin
			if(wr_amba)
			begin
				register[addr_wc[7:2]] <= (strb == 0) ? data_in : {(strb[3]) ? data_in[31:24] : register[addr_wc[7:2]][31:24],
																   (strb[2]) ? data_in[23:16] : register[addr_wc[7:2]][23:16],
																   (strb[1]) ? data_in[15: 8] : register[addr_wc[7:2]][15: 8],
																   (strb[0]) ? data_in[ 7: 0] : register[addr_wc[7:2]][ 7: 0]};
			end
		end
		else
		begin
			register[18][31] <= 0;

			if(mode == 3'b101 /* CTR */ && register[18][4]) //Counter Zero = 1 e modo = CTR, zera o contador
			begin
				register[16] <= 0;
				register[17] <= 0;
				register[18][4] <= 0;
			end

			if(wr_control)
			begin
				case(reg_dest)
					2'b00: {register[7],register[6],register[5],register[4]} <= {busR[7:0],busR[15:8],busR[23:16],busR[31:24],
																				 busR[39:32],busR[47:40],busR[55:48],busR[63:56],
																				 busR[71:64],busR[79:72],busR[87:80],busR[95:88],
																				 busR[103:96],busR[111:104],busR[119:112],busR[127:120]};
					2'b01: {register[11],register[10],register[9],register[8]} <= {busR[7:0],busR[15:8],busR[23:16],busR[31:24],
																				   busR[39:32],busR[47:40],busR[55:48],busR[63:56],
 																				   busR[71:64],busR[79:72],busR[87:80],busR[95:88],
																				   busR[103:96],busR[111:104],busR[119:112],busR[127:120]};
					2'b10: {register[15],register[14],register[13],register[12]} <= {busR[7:0],busR[15:8],busR[23:16],busR[31:24],
																				     busR[39:32],busR[47:40],busR[55:48],busR[63:56],
																				     busR[71:64],busR[79:72],busR[87:80],busR[95:88],
																				     busR[103:96],busR[111:104],busR[119:112],busR[127:120]};
					2'b11: {register[17], register[16]} <= {busR[7:0],busR[15:8],busR[23:16],busR[31:24],
															busR[39:32],busR[47:40],busR[55:48],busR[63:56]};
					/*2'b11: {register[17], register[16]} <= busR[63:0];*/
				endcase
			end
		end
	end
end

endmodule
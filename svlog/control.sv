/**

  ******************************************************************************
  *
  * @university	UFCG (Universidade Federal de Campina Grande)
  * @lab 	 	embedded
  * @project 	RISC-V.br
  * @ip      	AES (Advanced Encryption Standard)
  *
  * @file    	aes.sv
  * @authors 	Gabriel Villanova	
  *				Rubens Roux
  * @version 	V1.0
  * @date    	01 february 2017
  * @brief   
  *		The module control define the control words for the datapath depending 
  *		on the operating mode. It manages the use of registers by controlling 
  *  	the enable_amba signal.
  *
  ****************************************************************************** 

**/

module control (
	input logic ACLK,
	input logic ARSTn,
	
	/* conf AMBA */
	output logic enable_amba,

	/* write reg */
	output logic wr_control,

	/* AES */
	input logic valid_AES,

	/* reg command  */
	input  logic [31:0] reg_command,
	output logic [10:0] control_word

	/* control_word: | SEL_busA[1:0] | SEL_busB[1:0] | SEL_busR | reg_DEST[1:0] | start_AES | decrypt | FS[1:0] (11bits) */
	/*               |     XX        |      XX       |    X     |      XX       |     X     |    X	  |   XX    (11bits) */
);

typedef enum logic [2:0]
{
	idle,
	wait_start_bit,
	decode_instruction,
	execute,
	wr_register
} STATE_E;

STATE_E STATE;

// OPERATION MODES
localparam logic [2:0] ecb =3'b000;
localparam logic [2:0] cbc =3'b001;
localparam logic [2:0] pcbc=3'b010;
localparam logic [2:0] cfb =3'b011;
localparam logic [2:0] ofb =3'b100;
localparam logic [2:0] ctr =3'b101;

// REGISTERS
localparam logic [1:0] r0=2'b00;
localparam logic [1:0] r1=2'b01;
localparam logic [1:0] r2=2'b10;
localparam logic [1:0] r3=2'b11;

// FS ULA
localparam logic [1:0] XOR_busAbusB  =2'b00;
localparam logic [1:0] INC_busA      =2'b01;
localparam logic [1:0] MOV_busA_busR =2'b10;

// bus Result
localparam logic bus_ULA=0;
localparam logic bus_AES=1;

logic [10:0] instruction[4];
logic [1:0]  num_instruction;
logic [1:0]  count_instruction;

always_ff @(posedge ACLK) begin
	if(!ARSTn) begin
		control_word 	  <= 0;
		wr_control		  <= 0;
		enable_amba  	  <= 0; 
		num_instruction   <= 0;
		count_instruction <= 0;

		instruction[0] 	  <= 11'b0;
		instruction[1] 	  <= 11'b0;
		instruction[2] 	  <= 11'b0;
		instruction[3] 	  <= 11'b0;
		STATE <= idle;
	end 
	else begin
		unique case(STATE)
			idle: begin
				STATE 		<= wait_start_bit;
				enable_amba <= 1; 		// AMBA em uso
			end
 			wait_start_bit: begin
 				count_instruction <= 0;
 				wr_control  	  <= 0;
 				enable_amba 	  <= 1; // AMBA em uso

 				if(reg_command[31]) begin
 					enable_amba <= 0; 	// AMBA em estado de espera
 					STATE 		<= decode_instruction;
 				end
 			end
 			decode_instruction: begin
 				// ENCRYPT
 				if(!reg_command[3]) begin
 					/* control_word: | SEL_busA[1:0] | SEL_busB[1:0] | SEL_busR | reg_DEST[1:0] | start_AES | decrypt | FS[1:0] (11bits) */
 					case(reg_command[2:0])
 						default : begin
 							if(reg_command[0]) // reg_command[2:0] = 111, ignorando o mais significativo: 011 = cfb
 							begin
 								// def instrucao   
		 						instruction[0]  <= {2'b00,   r1,bus_AES,r1,1'b1,1'b0,2'b00};  	 	 // r1 <- E(r1);
		 						instruction[1]  <= {   r0,   r1,bus_ULA,r2,1'b0,1'b0,XOR_busAbusB};  // r2 <- r0 xor r1;
		 						instruction[2]  <= {   r2,2'b00,bus_ULA,r1,1'b0,1'b0,MOV_busA_busR}; // r1 <- r2;
		 						num_instruction	<= 2;

		 						// new state
		 						STATE <= execute;
 							end
 							else // reg_command[2:0] = 110, ignorando o mais significativo: 010 = pcbc
 							begin
 								// def instrucao
		 						instruction[0]  <= {   r1,r0,bus_ULA,r2,1'b0,1'b0,XOR_busAbusB};  // r2 <- r1 xor r0;
		 						instruction[1]  <= {2'b00,r2,bus_AES,r2,1'b1,1'b0,2'b00};  		  // r2 <- E(r2);
		 						instruction[2]  <= {   r2,r0,bus_ULA,r1,1'b0,1'b0,XOR_busAbusB};  // r1 <- r2 xor r0;
		 						num_instruction	<= 2;

		 						// new state
		 						STATE <= execute;
 							end
 						end
	 					// ECB
	 					ecb : begin
	 						// def instrucao 
	 						instruction[0]  <= {2'b00,  r0,bus_AES,r2,1'b1,1'b0,2'b00};  	 // r2 <- E(r0);
	 						num_instruction <= 0;

	 						// new state
	 						STATE <= execute;
	 					end
	 					cbc : begin
	 						// def instrucao
	 						instruction[0]  <= {   r1,   r0,bus_ULA,r2,1'b0,1'b0,XOR_busAbusB};  // r2 <- r1 xor r0;
	 						instruction[1]  <= {2'b00,   r2,bus_AES,r2,1'b1,1'b0,2'b00};  	 	 // r2 <- E(r2);
	 						instruction[2]  <= {   r2,2'b00,bus_ULA,r1,1'b0,1'b0,MOV_busA_busR}; // r1 <- r2;
	 						num_instruction	<= 2;

	 						// new state
	 						STATE <= execute;
	 					end
	 					pcbc : begin
	 						// def instrucao
	 						instruction[0]  <= {   r1,r0,bus_ULA,r2,1'b0,1'b0,XOR_busAbusB};  // r2 <- r1 xor r0;
	 						instruction[1]  <= {2'b00,r2,bus_AES,r2,1'b1,1'b0,2'b00};  		  // r2 <- E(r2);
	 						instruction[2]  <= {   r2,r0,bus_ULA,r1,1'b0,1'b0,XOR_busAbusB};  // r1 <- r2 xor r0;
	 						num_instruction	<= 2;

	 						// new state
	 						STATE <= execute;
	 					end
	 					cfb : begin
	 						// def instrucao   
	 						instruction[0]  <= {2'b00,   r1,bus_AES,r1,1'b1,1'b0,2'b00};  	 	 // r1 <- E(r1);
	 						instruction[1]  <= {   r0,   r1,bus_ULA,r2,1'b0,1'b0,XOR_busAbusB};  // r2 <- r0 xor r1;
	 						instruction[2]  <= {   r2,2'b00,bus_ULA,r1,1'b0,1'b0,MOV_busA_busR}; // r1 <- r2;
	 						num_instruction	<= 2;

	 						// new state
	 						STATE <= execute;
	 					end
	 					ofb : begin
	 						// def instrucao   
	 						instruction[0]  <= {2'b00,r1,bus_AES,r1,1'b1,1'b0,2'b00};  	 	 // r1 <- E(r1);
	 						instruction[1]  <= {   r0,r1,bus_ULA,r2,1'b0,1'b0,XOR_busAbusB}; // r2 <- r0 xor r1;
							num_instruction	<= 1;

	 						// new state
	 						STATE <= execute;
	 					end
	 					ctr : begin
	 						// def instrucao
	 						instruction[0]  <= {   r1,   r3,bus_ULA,r2,1'b0,1'b0,XOR_busAbusB}; // r2 <- r1 xor r3;
	 						instruction[1]  <= {2'b00,   r2,bus_AES,r2,1'b1,1'b0,2'b00};    	// r2 <- E(r2);
	 						instruction[2]  <= {   r0,   r2,bus_ULA,r2,1'b0,1'b0,XOR_busAbusB}; // r2 <- r0 xor r2;
	 						instruction[3]  <= {   r3,2'b00,bus_ULA,r3,1'b0,1'b0,INC_busA}; 	// r3 <- r3 + 1;
	 						num_instruction	<= 3;

	 						// new state
	 						STATE <= execute;
	 					end
	 				endcase
 				end
 				// DECRYPT
 				else begin
 					/* control_word: | SEL_busA[1:0] | SEL_busB[1:0] | SEL_busR | reg_DEST[1:0] | start_AES | decrypt | FS[1:0] (11bits) */
 					case(reg_command[2:0])
	 					default : begin
	 						if(reg_command[0]) // reg_command[2:0] = 111, ignorando o mais significativo: 011 = cfb
	 						begin
	 							// def instrucao   
		 						instruction[0]  <= {2'b00,   r1,bus_AES,r2,1'b1,1'b0,2'b00};  	 	 // r2 <- E(r1);
		 						instruction[1]  <= {   r2,   r0,bus_ULA,r2,1'b0,1'b0,XOR_busAbusB};  // r2 <- r2 xor r0;
		 						instruction[2]  <= {   r0,2'b00,bus_ULA,r1,1'b0,1'b0,MOV_busA_busR}; // r1 <- r0;
		 						num_instruction	<= 2;

		 						// new state
		 						STATE <= execute;
	 						end
	 						else // reg_command[2:0] = 110, ignorando o mais significativo: 010 = pcbc
	 						begin
	 							// def instrucao
		 						instruction[0]  <= {2'b00,r0,bus_AES,r2,1'b1,1'b1,2'b00};  	 	 // r2 <- D(r0);
		 						instruction[1]  <= {   r2,r1,bus_ULA,r2,1'b0,1'b0,XOR_busAbusB}; // r2 <- r2 xor r1;
		 						instruction[2]  <= {   r0,r2,bus_ULA,r1,1'b0,1'b0,XOR_busAbusB}; // r1 <- r0 xor r2;
		 						num_instruction	<= 2;

		 						// new state
		 						STATE <= execute;
	 						end
	 					end
	 					// ECB
	 					ecb : begin
	 						// def instrucao 
	 						instruction[0]  <= {2'b00,r0,bus_AES,r2,1'b1,1'b1,2'b00};  	 // r2 <- D(r0);
	 						num_instruction <= 0;

	 						// new state
	 						STATE <= execute;
	 					end
	 					cbc : begin
	 						// def instrucao
	 						instruction[0]  <= {2'b00,   r0,bus_AES,r2,1'b1,1'b1,2'b00};  	     // r2 <- D(r0);
	 						instruction[1]  <= {   r1,   r2,bus_ULA,r2,1'b0,1'b0,XOR_busAbusB};  // r2 <- r1 xor r0;
	 						instruction[2]  <= {   r0,2'b00,bus_ULA,r1,1'b0,1'b0,MOV_busA_busR}; // r1 <- r0;
	 						num_instruction	<= 2;

	 						// new state
	 						STATE <= execute;
	 					end
	 					pcbc : begin
	 						// def instrucao
	 						instruction[0]  <= {2'b00,r0,bus_AES,r2,1'b1,1'b1,2'b00};  	 	 // r2 <- D(r0);
	 						instruction[1]  <= {   r2,r1,bus_ULA,r2,1'b0,1'b0,XOR_busAbusB}; // r2 <- r2 xor r1;
	 						instruction[2]  <= {   r0,r2,bus_ULA,r1,1'b0,1'b0,XOR_busAbusB}; // r1 <- r0 xor r2;
	 						num_instruction	<= 2;

	 						// new state
	 						STATE <= execute;
	 					end
	 					cfb : begin
	 						// def instrucao   
	 						instruction[0]  <= {2'b00,   r1,bus_AES,r2,1'b1,1'b0,2'b00};  	 	 // r2 <- E(r1);
	 						instruction[1]  <= {   r2,   r0,bus_ULA,r2,1'b0,1'b0,XOR_busAbusB};  // r2 <- r2 xor r0;
	 						instruction[2]  <= {   r0,2'b0,bus_ULA,r1,1'b0,1'b0,MOV_busA_busR}; // r1 <- r0;
	 						num_instruction	<= 2;

	 						// new state
	 						STATE <= execute;
	 					end
	 					ofb : begin
	 						// def instrucao   
	 						instruction[0]  <= {2'b00,r1,bus_AES,r2,1'b1,1'b0,2'b00};  	 		 // r2 <- E(r1);
	 						instruction[1]  <= {   r2,2'b00,bus_ULA,r1,1'b0,1'b0,MOV_busA_busR}; // r1 <- r2;
	 						instruction[2]  <= {   r2,   r0,bus_ULA,r2,1'b0,1'b0,XOR_busAbusB};  // r2 <- r2 xor r0;
							num_instruction	<= 2;

	 						// new state
	 						STATE <= execute;
	 					end
	 					ctr : begin
	 						// def instrucao
	 						instruction[0]  <= {   r1,   r3,bus_ULA,r2,1'b0,1'b0,XOR_busAbusB}; // r2 <- r1 xor r3;
	 						instruction[1]  <= {2'b00,   r2,bus_AES,r2,1'b1,1'b0,2'b00};    	// r2 <- E(r2);
	 						instruction[2]  <= {   r0,   r2,bus_ULA,r2,1'b0,1'b0,XOR_busAbusB}; // r2 <- r0 xor r2;
	 						instruction[3]  <= {   r3,2'b00,bus_ULA,r3,1'b0,1'b0,INC_busA}; 	// r3 <- r3 + 1;
	 						num_instruction	<= 3;

	 						// new state
	 						STATE <= execute;
	 					end
	 				endcase
 				end
 			end
 			execute: begin
 				// Define palavra de controle e desabilita escrita em registrador
 				control_word <= instruction[count_instruction];
 				wr_control   <= 0;

 				STATE <= wr_register;
 			end
 			wr_register: begin
 				// AES
 				if(control_word[3]) begin
 					if(valid_AES) begin
 						// Atualiza contador de instrucao e habilita escrita em registrador
 						control_word[3] 	<= 1'b0; // Desce o start AES
 						count_instruction 	<= count_instruction + 1;
 						wr_control 			<= 1;

 						STATE				<= (count_instruction == num_instruction) ? wait_start_bit : execute;
 					end
 				end
 				// ULA
 				else begin
 					// Atualiza contador de instrucao e habilita escrita em registrador
 					count_instruction <= count_instruction + 1;
 					wr_control 		  <= 1;

 					STATE			  <= (count_instruction == num_instruction) ? wait_start_bit : execute;
 				end
 			end
 		endcase 
 	end
 end // always_ff
endmodule
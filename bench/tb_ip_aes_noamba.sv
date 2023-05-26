`include "tb_config.svh"
`include "../svlog/ip_aes_noamba.sv"
`include "../svlog/ula.sv"
`include "../svlog/mux_busR.sv"
`include "../svlog/mux_busA.sv"
`include "../svlog/mux_busB.sv"
`include "../svlog/control.sv"
`include "../svlog/register_file.sv"
`include "../svlog/key_expansion.sv"
`include "../svlog/aes.sv"

module tb_ip_aes_noamba ();

typedef enum logic [2:0] {ECB, CBC, PCBC, CFB, OFB, CTR} MODE;

MODE mode;

logic ACLK;
logic ARSTn;

logic [4:0] cont;
logic [1:0] N_BLOCKS_CONT;
logic rst_count;
logic [127:0] Blocks[NUM_OF_BLOCKS];
logic[31:0] counter;

/* AMBA */
logic wr_amba;   // input
logic [3:0]  strb;		// input
logic [31:0] data_in;	// input
logic [31:0] addr_rc;		// input
logic [31:0] addr_wc;		// input
logic [31:0] data_out;	// output
logic enable_amba;		// output

// Instancia
ip_aes_noamba aes (
	.ACLK(ACLK),
	.ARSTn(ARSTn),
	.enable_amba(enable_amba),

	/* AMBA */
 	.wr_amba(wr_amba),
 	.strb(strb),
 	.data_in(data_in),
 	.addr_rc(addr_rc),
 	.addr_wc(addr_wc),
	.data_out(data_out)
);

always_ff @(posedge ACLK)
begin
	if(~ARSTn)
	begin
		reset();
	end
	else
	begin
		if(enable_amba)
		begin
			if(cont < 5)
			begin
				wr_amba <= 0;
				get_result(cont);
			end
			else
				wr_amba <= 1;

			case(mode)
				ECB:
				begin
					write_key(KEY, cont);
			 		write_block(Blocks[N_BLOCKS_CONT], cont);
			 		write_reg_conf({1'b1, 26'b0, 1'b0, INVCIPHER, mode}, cont);
			 	end
			 	CBC:
			 	begin
			 		write_key(KEY, cont);
			 		write_block(Blocks[N_BLOCKS_CONT], cont);
			 		if(N_BLOCKS_CONT == 0)
			 			write_iv(IV, cont);
			 		write_reg_conf({1'b1, 26'b0, 1'b0, INVCIPHER, mode}, cont);
			 	end
			 	PCBC:
			 	begin
			 		write_key(KEY, cont);
			 		write_block(Blocks[N_BLOCKS_CONT], cont);
			 		if(N_BLOCKS_CONT == 0)
			 			write_iv(IV, cont);
			 		write_reg_conf({1'b1, 26'b0, 1'b0, INVCIPHER, mode}, cont);
			 	end
			 	CFB:
			 	begin
			 		write_key(KEY, cont);
			 		write_block(Blocks[N_BLOCKS_CONT], cont);
			 		if(N_BLOCKS_CONT == 0)
			 			write_iv(IV, cont);
			 		write_reg_conf({1'b1, 26'b0, 1'b0, INVCIPHER, mode}, cont);
			 	end
			 	OFB:
			 	begin
			 		write_key(KEY, cont);
			 		write_block(Blocks[N_BLOCKS_CONT], cont);
			 		if(N_BLOCKS_CONT == 0)
			 			write_iv(IV, cont);
			 		write_reg_conf({1'b1, 26'b0, 1'b0, INVCIPHER, mode}, cont);
			 	end
			 	CTR:
			 	begin
			 		write_key(KEY, cont);
			 		write_block(Blocks[N_BLOCKS_CONT], cont);
			 		if(N_BLOCKS_CONT == 0)
			 			write_iv(IV, cont);
			 		write_reg_conf({1'b1, 26'b0, rst_count, INVCIPHER, mode}, cont);
			 	end
	 		endcase

	 		cont <= cont + 1;
		end
		else
		begin
			cont 	<= 0;
			wr_amba <= 0;
			if(cont == 5'h14)
				if(N_BLOCKS_CONT == NUM_OF_BLOCKS - 1)
				begin
					N_BLOCKS_CONT <= 0;
					rst_count <= 1;
				end
				else
				begin
					N_BLOCKS_CONT <= N_BLOCKS_CONT + 1;
			 		rst_count <= 0;
				end
		end
	end
end

 // CLK 5ns
always #5 ACLK = ~ACLK;

initial
begin
	$vcdpluson;
	$vcdplusmemon;
	
	Blocks[0] = BLOCK1;

	if(NUM_OF_BLOCKS > 1)
		Blocks[1] = BLOCK2;

	if(NUM_OF_BLOCKS > 2)
		Blocks[2] = BLOCK3;

	mode = OP_MODE;
	ACLK = 0;
	ARSTn = 0;
	#6;
	ARSTn = 1;

	#4994;
	$finish;
end	

logic [127:0]block_aux, result_aux;

// ** task ** //
task write_key(input logic[127:0] key, input logic[4:0] cont);
	case(cont)
		5'h5: config_write_reg(key[31:0]  ,32'h00000000); // key[0]
		5'h6: config_write_reg(key[63:32] ,32'h00000004); // key[1]
		5'h7: config_write_reg(key[95:64] ,32'h00000008); // key[2]
		5'h8: config_write_reg(key[127:96],32'h0000000C); // key[3]
	endcase
endtask

task write_block(input logic[127:0] block, input logic[4:0] cont);
	case(cont)
		5'h9: config_write_reg(block[31:0]  ,32'h00000010); // block[0]
		5'ha: config_write_reg(block[63:32] ,32'h00000014); // block[1]
		5'hb: config_write_reg(block[95:64] ,32'h00000018); // block[2]
		5'hc: config_write_reg(block[127:96],32'h0000001C); // block[3]
	endcase
endtask

task write_iv(input logic [127:0] iv, input logic[4:0] cont);
	case(cont)
		5'hd: config_write_reg(iv[31:0]  ,32'h00000020); // iv[0]
		5'he: config_write_reg(iv[63:32] ,32'h00000024); // iv[1]
		5'hf: config_write_reg(iv[95:64] ,32'h00000028); // iv[2]
		5'h10: config_write_reg(iv[127:96],32'h0000002C);// iv[3]
	endcase
endtask

task write_reg_conf(input logic[31:0] reg_conf, input logic[4:0] cont);
	case(cont)
		5'h11: config_write_reg(reg_conf,32'h00000048); // reg_conf
	endcase
endtask

task config_write_reg (input logic[31:0] data, address);
	data_in   <= data;
	addr_wc	  <= address;
	strb 	  <= 4'b1111;

	block_aux <= {data,block_aux[127:32]};

	if(cont == 5)
	begin
		if(rst_count)
			counter <= 0;
		else
			counter <= data_out;
		$display("result   = 0x%h", result_aux);
		$display("");
		$display("Dados de entrada:");
	end

	if(address == 32'h00000010)
		$display("key      = 0x%h",block_aux);
	if(address == 32'h00000020)
		$display("block    = 0x%h",block_aux);
	if(address == 32'h00000044)
	begin
		if(N_BLOCKS_CONT == 0)
			$display("iv       = 0x%h",block_aux);
		else
			$display("block    = 0x%h",block_aux);
		$display("reg_conf = 0x%h",data);
		$display("");
		if(mode == CTR)
			$display("counter  = 0x%h", counter);
	end
endtask

task get_result(input logic[4:0] cont);

	case(cont)
		5'h0: result(32'h00000030);
		5'h1: result(32'h00000034);
		5'h2: result(32'h00000038);
		5'h3: result(32'h0000003C);
		5'h4: result(32'h00000040);
	endcase

endtask

task result (input logic[31:0] address);
	addr_rc	   <= address;
	result_aux <= {data_out,result_aux[127:32]};
endtask

task reset;
	rst_count <= 0;
	cont 	  <= 0;
	wr_amba   <= 1'b0;
	strb 	  <= 4'b0000;
	data_in   <= 32'b0;
	addr_wc	  <= 32'b0;
	addr_rc	  <= 32'b0;
	counter   <= 0;
	N_BLOCKS_CONT <= 0;

	$display("\n\n");
	case(mode)
		ECB:  $display("MODE ECB\n");
		CBC:  $display("MODE CBC\n");
		PCBC: $display("MODE PCBC\n");
		CFB:  $display("MODE CFB\n");
		OFB:  $display("MODE OFB\n");
		CTR:  $display("MODE CTR\n");
	endcase
endtask
// ** End tasks ** //
 endmodule

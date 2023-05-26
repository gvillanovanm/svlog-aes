`include "./aes_types.svh"
//`include "../uvm/pedro/integra-adder-refmod/aes_config.svh"


module tb_ip_aes;

logic ACLK;
logic ARSTn;
axi4_lite_hierarchical amba(.ACLK(ACLK),.ARSTn(ARSTn));

ip_aes aes(.amba_if(amba));

typedef enum logic [1:0]{
	wc_idle,
	wc_write,
	wc_wait_resp
} WC_STATE;

typedef enum logic [1:0]{
	rc_idle,
	rc_read,
	rc_wait_resp
} RC_STATE;

WC_STATE write_state;
RC_STATE read_state;

logic [127:0] result;

logic [7:0] cont;

always_comb
begin
	case (write_state)
		wc_idle:
		begin
			amba.AW.VALID = 0;
			amba.W.VALID  = 0;
			amba.B.READY  = 0;
			amba.AW.ADDR  = 32'hFFFFFFFF;
			amba.W.DATA   = 0;
			amba.W.STRB   = 0;
		end
		wc_write:
		begin
			amba.AW.VALID = 1;
			amba.W.VALID  = 1;
			amba.B.READY  = 0;
			amba.W.STRB   = 4'b1111;

			case(cont)
				8'h0: //Escrever [31:0] KEY ---------- Counter
				begin
					//amba.AW.ADDR = 32'h00000000;
					//amba.W.DATA  = KEY[31:0];

					amba.AW.ADDR = 32'h00000040;
					amba.W.DATA  = 32'h000000ff;
				end
				8'h1: //Escrever [63:32] KEY --------- Counter
				begin
					//amba.AW.ADDR = 32'h00000004;
					//amba.W.DATA  = KEY[63:32];

					amba.AW.ADDR = 32'h00000044;
					amba.W.DATA  = 32'h00000000;
				end
				8'h2: //Escrever [95:64] KEY
				begin
					amba.AW.ADDR = 32'h00000008;
					amba.W.DATA  = KEY[95:64];
				end
				8'h3: //Escrever [127:96] KEY
				begin
					amba.AW.ADDR = 32'h0000000C;
					amba.W.DATA  = KEY[127:96];
				end
				8'h4: //Escrever [31:0] BLOCK
				begin
					amba.AW.ADDR = 32'h00000010;
					amba.W.DATA  = BLOCK1[31:0];
				end
				8'h5: //Escrever [63:32] BLOCK
				begin
					amba.AW.ADDR = 32'h00000014;
					amba.W.DATA  = BLOCK1[63:32];
				end
				8'h6: //Escrever [95:64] BLOCK
				begin
					amba.AW.ADDR = 32'h00000018;
					amba.W.DATA  = BLOCK1[95:64];
				end
				8'h7: //Escrever [127:96] BLOCK
				begin
					amba.AW.ADDR = 32'h0000001C;
					amba.W.DATA  = BLOCK1[127:96];
				end
				8'h8: //Escrever [31:0] IV
				begin
					amba.AW.ADDR = 32'h00000020;
					amba.W.DATA  = IV[31:0];
				end
				8'h9: //Escrever [63:32] IV
				begin
					amba.AW.ADDR = 32'h00000024;
					amba.W.DATA  = IV[63:32];
				end
				8'ha: //Escrever [95:64] IV
				begin
					amba.AW.ADDR = 32'h00000028;
					amba.W.DATA  = IV[95:64];
				end
				8'hb: //Escrever [127:96] IV
				begin
					amba.AW.ADDR = 32'h0000002C;
					amba.W.DATA  = IV[127:96];
				end
				8'hc: //Escrever Reg Command
				begin
					amba.AW.ADDR = 32'h00000048;
					amba.W.DATA  = {1'b1, 26'b0, 1'b0, 1'b1, 3'b101};
				end
				8'h11: //Escrever [31:0] BLOCK
				begin
					amba.AW.ADDR = 32'h00000010;
					amba.W.DATA  = BLOCK2[31:0];
					$display("\nRESULTADOS: \n");
					$display("first cipher block  : 0x%h", result);
				end
				8'h12: //Escrever [63:32] BLOCK
				begin
					amba.AW.ADDR = 32'h00000014;
					amba.W.DATA  = BLOCK2[63:32];
				end
				8'h13: //Escrever [95:64] BLOCK
				begin
					amba.AW.ADDR = 32'h00000018;
					amba.W.DATA  = BLOCK2[95:64];
				end
				8'h14: //Escrever [127:96] BLOCK
				begin
					amba.AW.ADDR = 32'h0000001C;
					amba.W.DATA  = BLOCK2[127:96];
				end
				8'h15: //Escrever Reg Command
				begin
					amba.AW.ADDR = 32'h00000048;
					amba.W.DATA  = {1'b1, 26'b0, 1'b0, 1'b1, 3'b101};
				end
				default:
					amba.AW.ADDR = 32'hFFFFFFFF;
			endcase
		end
		wc_wait_resp:
		begin
			amba.AW.VALID = 0;
			amba.W.VALID  = 0;
			amba.B.READY  = 1;
			amba.AW.ADDR  = 32'hFFFFFFFF;
			amba.W.DATA   = 0;
			amba.W.STRB   = 0;
		end
	endcase

	case (read_state)
		rc_idle:
		begin
			amba.AR.VALID = 0;
			amba.R.READY  = 0;
			amba.AR.ADDR  = 32'hFFFFFFFF;
		end
		rc_read:
		begin
			case(cont)
				8'hd: //Ler [31:0] Result
					amba.AR.ADDR = 32'h00000030;
				8'he: //Ler [63:32] Result
					amba.AR.ADDR = 32'h00000034;
				8'hf: //Ler [95:64] Result
					amba.AR.ADDR = 32'h00000038;
				8'h10: //Ler [127:96] Result
					amba.AR.ADDR = 32'h0000003C;
				8'h16: //Ler [31:0] Result
					amba.AR.ADDR = 32'h00000030;
				8'h17: //Ler [63:32] Result
					amba.AR.ADDR = 32'h00000034;
				8'h18: //Ler [95:64] Result
					amba.AR.ADDR = 32'h00000038;
				8'h19: //Ler [127:96] Result
					amba.AR.ADDR = 32'h0000003C;
				8'h1a:
					$display("second cipher block : 0x%h\n", result);
				default:
					amba.AR.ADDR = 32'hFFFFFFFF;
			endcase
			amba.AR.VALID = 1;
			amba.R.READY = 0;
		end
		rc_wait_resp:
		begin
			amba.AR.ADDR  = 0;
			amba.AR.VALID = 0;
			amba.R.READY = 1;
		end
	endcase
end

always_ff @(posedge ACLK)
begin
	if(!ARSTn)
	begin
		amba.AW.PROT <= 3'h0;

		amba.AR.PROT <= 0;

		write_state <= wc_idle;

		read_state <= rc_idle;

		cont <= 0;
	end
	else
	begin
		case(write_state)
			wc_idle:
				if(cont == 8'h00 || cont == 8'h11)
				begin
					if(cont == 8'h00)
					begin
						$display("\nVALORES ENVIADOS:\n");
						$display("data1 : 0x%h", BLOCK1);
						$display("data2 : 0x%h", BLOCK2);
						$display("  key : 0x%h", KEY);
						if(OP_MODE != 3'h0)
							$display("   IV : 0x%h", IV);
					end
					write_state <= wc_write;
				end

			wc_write:
				write_state <= wc_wait_resp;

			wc_wait_resp:
				if(amba.B.VALID)
				begin
					if(amba.B.RESP == 0)
					begin
						cont <= cont + 1;
					end
					if(cont < 8'h0C || (cont >= 8'h10 && cont < 8'h15))
						write_state <= wc_write;
					else
						write_state <= wc_idle;
				end
		endcase
		
		case(read_state)
			rc_idle:
				if(cont == 8'h0D || cont == 8'h16)
					read_state <= rc_read;

			rc_read:
				read_state <= rc_wait_resp;

			rc_wait_resp:
				if(amba.R.VALID)
				begin
					if(amba.R.RESP == 0)
					begin
						cont <= cont + 1;
						case(cont)
							8'hd: //Ler [31:0] Result
								result[31:0] <= amba.R.DATA;
							8'he: //Ler [63:32] Result
								result[63:32] <= amba.R.DATA;
							8'hf: //Ler [95:64] Result
								result[95:64] <= amba.R.DATA;
							8'h10: //Ler [127:96] Result
								result[127:96] <= amba.R.DATA;
							8'h16: //Ler [31:0] Result
								result[31:0] <= amba.R.DATA;
							8'h17: //Ler [63:32] Result
								result[63:32] <= amba.R.DATA;
							8'h18: //Ler [95:64] Result
								result[95:64] <= amba.R.DATA;
							8'h19: //Ler [127:96] Result
								result[127:96] <= amba.R.DATA;
						endcase
					end
					if((cont < 8'h10 && cont > 8'h0C) || cont > 8'h15)
						read_state <= rc_read;
					else
						read_state <= rc_idle;
				end
		endcase

		if(cont == 8'h1a)
			cont <= 0;
	end
end


always #5 ACLK = ~ACLK;

initial
begin
	$vcdpluson;
	$vcdplusmemon;

	ACLK = 0;
	ARSTn = 0;
	#6;
	ARSTn = 1;

	#4994;
	$finish;

end

endmodule

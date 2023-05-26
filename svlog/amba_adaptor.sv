module amba_adaptor (
	axi4_lite_hierarchical	amba,
	input logic 		enable_amba,
	output logic 		wr_amba,
	input logic  [31:0] data_in,
	output logic [31:0] addr_rc,
	output logic [31:0] addr_wc,
	output logic [31:0] data_out,
	output logic [3:0] 	strb
);

import axi4_types::*;
typedef enum logic[1:0] {
	wc_idle,
	wc_wait_addr,
	wc_wait_data,
	wc_exec
} WC_STATE_E;
typedef enum logic[1:0] {
	rc_idle,
	rc_wait_addr,
	rc_exec
} RC_STATE_E;

WC_STATE_E STATE_wc;
RC_STATE_E STATE_rc;

// Rejected by irun 15.20-s013: localparam int unsigned SIZE_WORD = amba.SIZE_WORD;
localparam int unsigned SIZE_WORD = $size(amba.W.DATA);
localparam int unsigned SIZE_STRB = $size(amba.W.STRB);
localparam int unsigned SIZE_ADDR = $size(amba.AW.ADDR);

logic [SIZE_ADDR-1:0]read_AWADDR;
logic [SIZE_WORD-1:0]read_WDATA;
logic [SIZE_STRB-1:0]read_WSTRB;
logic wrote, leu, aux_wc, aux_rc;

logic [2:0]read_ARPROT;
logic [SIZE_ADDR-1:0]read_ARADDR;
logic [SIZE_WORD-1:0]read_RDATA;

/* Logica do write */
always_ff @(posedge amba.ACLK) begin
	if(~amba.ARSTn) begin
		STATE_wc 	<= wc_idle;
		read_AWADDR <= 0;
		read_WSTRB  <= 0;
		read_WDATA  <= 0;
		wrote 		<= 0;
	end 
	else begin
		unique case (STATE_wc)
			wc_idle:
			begin
				STATE_wc	<= wc_wait_addr;
				wrote		<= 0;
				aux_wc		<= 0;
			end
			wc_wait_addr:
			begin
				case({amba.AW.VALID,amba.W.VALID})
					2'b10:
					begin
						STATE_wc	<= wc_wait_data;
						read_AWADDR <= amba.AW.ADDR;
						aux_wc <= 0;
					end
					2'b11:
					begin
						STATE_wc 	<= wc_exec;
						read_AWADDR <= amba.AW.ADDR;
						read_WDATA	<= amba.W.DATA;
						read_WSTRB	<= amba.W.STRB;
						aux_wc <= enable_amba;
					end
					default: aux_wc <= 0;
				endcase
				wrote <= 0;
			end
			wc_wait_data:
			begin
				if(amba.W.VALID)
				begin
					STATE_wc    <= wc_exec;
					read_WDATA	<= amba.W.DATA;
					read_WSTRB	<= amba.W.STRB;
					aux_wc <= enable_amba;
				end
				else
					aux_wc <= 0;
				wrote <= 0;
			end
			wc_exec:
			begin
				if(amba.B.READY)
					STATE_wc   <= wc_wait_addr;
				wrote <= 1;
				aux_wc <= enable_amba;
			end
		endcase
	end
end // ALWAYS_ff write channel

always_comb  begin
	case (STATE_wc)
		wc_idle:
		begin
			amba.AW.READY = 0;
			amba.W.READY  = 0;
			amba.B.VALID  = 0;
			amba.B.RESP   = AXI4_RESP_L_OKAY;
			wr_amba		  = 0;
			data_out	  = 0;
			addr_wc		  = 0;
			strb		  = 0;
		end
		wc_wait_addr:
		begin
			data_out	  = 0;
			addr_wc		  = 0;
			strb		  = 0;
			amba.AW.READY = 1;
			amba.W.READY  = 1;
			amba.B.VALID  = 0;
			amba.B.RESP   = AXI4_RESP_L_OKAY;
			wr_amba		  = 0;
		end
		wc_wait_data:
		begin
			data_out	  = 0;
			addr_wc		  = 0;
			strb		  = 0;
			amba.AW.READY = 0;
			amba.W.READY  = 1;
			amba.B.VALID  = 0;
			amba.B.RESP   = AXI4_RESP_L_OKAY;
			wr_amba		  = 0;
		end
		wc_exec:
		begin
			data_out 	  = read_WDATA;
			addr_wc		  = read_AWADDR;
			strb		  = read_WSTRB;
			amba.AW.READY = 0;
			amba.W.READY  = 0;
			if(aux_wc && read_AWADDR[31:8] == 24'h000000 && read_AWADDR[7:0] < 8'h4C)
			begin
				amba.B.RESP	= AXI4_RESP_L_OKAY;
				wr_amba = (wrote) ? 0 : 1;
			end
			else
			begin
				amba.B.RESP = AXI4_RESP_L_SLVERR;
				wr_amba	= 0;
			end
			amba.B.VALID  = 1;
		end
	endcase
end 
/* End lógica do write */

/* Logica do READ */
always_ff @(posedge amba.ACLK)
begin	
	if(~amba.ARSTn)
	begin
		STATE_rc	<= rc_idle;
		read_ARPROT <= 0;
		read_ARADDR <= 0;
		read_RDATA  <= 0;
	end
	else
	begin
		unique case(STATE_rc)
			rc_idle:
			begin
				STATE_rc    <= rc_wait_addr;
				aux_rc		<= 0;
			end
			rc_wait_addr:begin
				if(amba.AR.VALID)begin
					read_ARADDR <= amba.AR.ADDR;
					read_ARPROT <= amba.AR.PROT;
					STATE_rc	<= rc_exec;
					aux_rc <= enable_amba;
				end
			end
			rc_exec:
			begin
				if(amba.R.READY)
					STATE_rc <= rc_wait_addr;
				aux_rc <= enable_amba;
			end
		endcase //CASE DO ESTADO
	end //else
end //always_ff read channel

always_comb begin	
	unique case (STATE_rc)
		rc_idle:
		begin
			amba.AR.READY = 0;
			amba.R.VALID  = 0;
			amba.R.RESP	  = AXI4_RESP_L_OKAY;
			amba.R.DATA   = 0;
			addr_rc		  = 0;
		end
		rc_wait_addr:
		begin
			addr_rc		  = 0;
			amba.AR.READY = 1;
			amba.R.VALID  = 0;
			amba.R.RESP	  = AXI4_RESP_L_OKAY;
			amba.R.DATA   = 0;
		end
		rc_exec:
		begin
			amba.AR.READY = 0;
			amba.R.VALID  = 1;
			addr_rc		  = read_ARADDR;

			if(aux_rc && read_ARADDR[31:8] == 24'h000000 && (read_ARADDR[7:0] < 8'h50))
			begin
				amba.R.RESP = AXI4_RESP_L_OKAY;
				amba.R.DATA = data_in;
			end
			else
			begin
				amba.R.RESP = AXI4_RESP_L_SLVERR;
				amba.R.DATA = 0;
			end
			//if(read_ARADDR[7:2] == {4'h4,2'b11}) // O STATUS PODE SER LIDO INDEPENDENTE DA AMBA ESTAR ATIVA
			if(read_ARADDR[31:8] == 24'h000000 && read_ARADDR[7:2] == {4'h4,2'b11}) // O STATUS PODE SER LIDO INDEPENDENTE DA AMBA ESTAR ATIVA
			begin
				amba.R.RESP	= AXI4_RESP_L_OKAY;
				amba.R.DATA = (amba.R.DATA) ? amba.R.DATA : data_in;
			end
		end
	endcase
end
endmodule

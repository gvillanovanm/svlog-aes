module ip_aes (
	axi4_lite_hierarchical amba_if
);

logic enable_amba;

logic wr_amba;
logic [3:0] strb;
logic [31:0] in_dpath_out_amba;
logic [31:0] addr_rc;
logic [31:0] addr_wc;
logic [31:0] out_dpath_in_amba;

ip_aes_noamba datapath(
	.ACLK(amba_if.ACLK),
	.ARSTn(amba_if.ARSTn),
	.enable_amba(enable_amba),
 	.wr_amba(wr_amba),
 	.strb(strb),
 	.data_in(in_dpath_out_amba),
 	.addr_rc(addr_rc),
 	.addr_wc(addr_wc),
 	.data_out(out_dpath_in_amba)
);

amba_adaptor AMBA (
	.amba(amba_if),
	.enable_amba(enable_amba),
	.wr_amba(wr_amba),
	.data_in(out_dpath_in_amba),
	.addr_rc(addr_rc),
	.addr_wc(addr_wc),
	.data_out(in_dpath_out_amba),
	.strb(strb)
);

endmodule

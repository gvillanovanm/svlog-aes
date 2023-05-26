`include "axi4_types.svh"
`include "../svlog/amba_adaptor.sv"
`include "../svlog/register_file.sv"

module tb_amba();
	// Sinais
	logic ACLK  	  = 1'b0;
	logic ARSTn 	  = 1'b0;

	/* Sinais de controle */
	axi4_lite_hierarchical amba(.ACLK(ACLK),.ARSTn(ARSTn));

	/* amba2reg (ignore) */
	logic enable_amba = 1'b1;
	logic wr_amba;
	logic [3:0]  strb;				
	logic [31:0] addr_wc;
	logic [31:0] addr_rc;				
	logic [31:0] data_amba2reg;		
	logic [31:0] data_reg2amba;		 

	/* reg_file (ignore) */
	logic [127:0] busR = 128'b0;
	logic [127:0] r0; 
	logic [127:0] r1; 
	logic [127:0] r2; 
	logic [31:0]  r3;
	logic [127:0] key; 
	logic [127:0] reg_conf;

	/* control */
	logic [1:0] reg_dest = 2'b0;
	logic wr_control 	 = 1'b0;
	
	// Instancia
	amba_adaptor amba_mod(
		.enable_amba(enable_amba),
		.amba(amba),
		.wr_amba(wr_amba),
		.data_in(data_reg2amba),
		.addr_rc(addr_rc),
		.addr_wc(addr_wc),
		.data_out(data_amba2reg),
		.strb(strb)
	);
	register_file reg_file(
		.ACLK(ACLK),  
		.ARSTn(ARSTn),

		/* AMBA */ 
		.wr_amba(wr_amba),
		.enable_amba(enable_amba), 	// sempre manter '1' para ignorar os sinais internos
		.data_in(data_amba2reg), 
		.addr_wc(addr_wc), 
		.addr_rc(addr_rc), 
		.strb(strb),
		.data_out(data_reg2amba),
		
		/* interno */
		.busR(busR),
		.r0(r0), 
		.r1(r1), 
		.r2(r2), 
		.key(key), 
		.r3(r3),
		.reg_dest(reg_dest),  
		.wr_control(wr_control),
		.reg_conf(reg_conf)
	);


always #10 ACLK=~ACLK;

initial begin

	@(posedge ACLK); #1;
		ARSTn=1'b0;
	@(posedge ACLK); #1;
		ARSTn=1'b1;
		reset();
		enable_amba=1'b1;
	// INICIO DE TESTES PARA O AMBA

	// TESTES NA KEY (ADDR DE 0X00 ATÉ 0X0C)
	/* Escrevendo o valor de 128'h5BFA839812BCDF784567A9AB12345ABF na chave */
		//write_addr__wc 	({OFFSET,8'h00},3'b011);
		//write_data_wc 	(32'h12345ABF,4'b1101);
		//write_addr__wc 	({OFFSET,8'h04},3'b011);
		//write_data_wc 	(32'h4567A9AB,4'b1111);	
		//write_addr__wc 	({OFFSET,8'h09},3'b011);
		//write_data_wc 	(32'h12BCDF78,4'b1111);
		//write_addr__wc 	({OFFSET,8'h0C},3'b011);
		//write_data_wc 	(32'h5BFA8398,4'b1111);
	/* Fim da escrita */
		
	/* Tentativa de ler a chave para um usuario que não tem acesso */
		//write_addr_rc({OFFSET,8'h00},3'b001); //esperasse que tenha erro
		//wait_data_rc();

	/* Lendo a key para um usuriao priveligiado e não seguro */
		//write_addr_rc 	({OFFSET,8'h00},3'b011);
		//wait_data_rc ();
		//write_addr_rc 	({OFFSET,8'h04},3'b011);
		//wait_data_rc ();
		//write_addr_rc 	({OFFSET,8'h08},3'b011);
		//wait_data_rc ();
		//write_addr_rc 	({OFFSET,8'h0C},3'b011);
		//wait_data_rc ();

	// FIM DE TESTES NA KEY

	//TESTES NO BLOCK (ADDR DE 0X10 ATÉ 0X1C)

	/* Escrevendo o valor de 128'h5BFA839812BCDF784567A9AB12345ABF no BLOCK */	
	 	//write_addr__wc 	({OFFSET,8'h10},3'b011);
		//write_data_wc 	(32'h12345ABF,4'b1101);  
		//write_addr__wc 	({OFFSET,8'h14},3'b011);
		//write_data_wc 	(32'h4567A9AB,4'b1111);	
		//write_addr__wc 	({OFFSET,8'h1A},3'b011);
		//write_data_wc 	(32'h12BCDF78,4'b1111);
		//write_addr__wc 	({OFFSET,8'h1C},3'b011);
		//write_data_wc 	(32'h5BFA8398,4'b1111);

	/* Tentativa de ler o block para um usuario que não tem acesso */
		// write_addr_rc({OFFSET,8'h10},3'b001); //esperasse que tenha erro
		// wait_data_rc();

	/* Lendo o block para um usuriao priveligiado e não seguro */
		//write_addr_rc 	({OFFSET,8'h10},3'b011);
		//wait_data_rc ();
		//write_addr_rc 	({OFFSET,8'h14},3'b011);
		//wait_data_rc ();
		//write_addr_rc 	({OFFSET,8'h18},3'b011);
		//wait_data_rc ();
		//write_addr_rc 	({OFFSET,8'h1C},3'b011);
		//wait_data_rc ();

	//FIM DE TESTES NO BLOCK

	//TESTES NO IV(ADDR DE 0X20 ATÉ 0X2C)

	/* Escrevendo o valor de 128'h5BFA839812BCDF784567A9AB12345ABF no IV */
		//write_addr__wc 	({OFFSET,8'h20},3'b011);
		//write_data_wc 	(32'h12345ABF,4'b1101);
		//write_addr__wc 	({OFFSET,8'h24},3'b011);
		//write_data_wc 	(32'h4567A9AB,4'b1111);	
		//write_addr__wc 	({OFFSET,8'h2A},3'b011);
		//write_data_wc 	(32'h12BCDF78,4'b1111);
		//write_addr__wc 	({OFFSET,8'h2C},3'b011);
		//write_data_wc 	(32'h5BFA8398,4'b1111);
	/* Fim da escrita */
		
	/* Tentativa de ler o IV para um usuario que não tem acesso */
		write_addr_rc 	({OFFSET,8'h00},3'b001); //esperasse que tenha erro
		wait_data_rc ();

	/* Lendo o IV para um usuriao priveligiado e não seguro */
		write_addr_rc 	({OFFSET,8'h20},3'b011);
		wait_data_rc ();
		write_addr_rc 	({OFFSET,8'h24},3'b011);
		wait_data_rc ();
		write_addr_rc 	({OFFSET,8'h28},3'b011);
		wait_data_rc ();
		write_addr_rc 	({OFFSET,8'h2C},3'b011);
		wait_data_rc ();

	// FIM DE TESTES NO IV
 
	// TESTES NO  RESULT (ADDR DE 0X30 ATÉ 0X3C)

	/* tentativa de escrita o valor de 128'h5BFA839812BCDF784567A9AB12345ABF no RESULT para usuário privegiliado e não seguro */
		//write_addr__wc 	({OFFSET,8'h30},3'b011);
		//write_data_wc 	(32'h12345ABF,4'b1101);
		//write_addr__wc 	({OFFSET,8'h24},3'b011);
		//write_data_wc 	(32'h4567A9AB,4'b1111);	
		//write_addr__wc 	({OFFSET,8'h28},3'b011);
		//write_data_wc 	(32'h12BCDF78,4'b1111);
		//write_addr__wc 	({OFFSET,8'h2C},3'b011);
		//write_data_wc 	(32'h5BFA8398,4'b1111);
	/*Fim da escrita*/

	/* tentativa de escrita no RESULT para usuário que não tem permissão */
		//write_addr__wc 	({OFFSET,8'h30},3'b001);
		//write_data_wc 	(32'h12345ABF,4'b1101);

	/* Fim da tentativa de escrita */

	/* Lendo o Result */
		//write_addr_rc 	({OFFSET,8'h30},3'b011);
		//wait_data_rc ();
		//write_addr_rc 	({OFFSET,8'h34},3'b011);
		//wait_data_rc ();
		//write_addr_rc 	({OFFSET,8'h38},3'b011);
		//wait_data_rc ();
		//write_addr_rc 	({OFFSET,8'h3C},3'b011);
		//wait_data_rc ();
	// fim da leitura

	// FIM DE TESTES NO RESULT

	@(posedge ACLK); #1;
		#1000;
		$finish;
end // initial

initial
	begin
		$vcdpluson;
		$vcdplusmemon;
	end




task write_addr__wc;
	input logic [31:0]	wc_addr;
	input logic [2:0] 	wc_prot;
	@(posedge ACLK); #1;
		amba.AW.VALID 	= 1'b1;
		amba.AW.PROT 	= wc_prot;
		amba.AW.ADDR 	= wc_addr;
endtask 

task write_data_wc;
	input logic [31:0]	wc_data;
	input logic [3:0]		wc_strb;

	@(posedge ACLK); 
		while(!amba.AW.READY) //@(posedge ACLK);
	#1;
	amba.AW.VALID 	= 1'b0;
	amba.W.DATA 	= wc_data;
	amba.W.STRB 	= wc_strb;
	amba.W.VALID 	= 1'b1;
	@(posedge ACLK); 
		while(!amba.W.READY) @(posedge ACLK);
	#1;
	amba.W.VALID 	= 1'b0;
	amba.B.READY 	= 1'b1;
	@(posedge ACLK); 
		while(!amba.B.VALID) @(posedge ACLK);
	#1;
	amba.B.READY 	= 1'b0;
endtask

task write_addr_rc;
	input logic [31:0]	rc_addr;
	input logic [3:0]	rc_prot;
	amba.AR.PROT 	= rc_prot;
	amba.AR.ADDR 	= rc_addr;
	amba.AR.VALID 	= 1'b1;
	
endtask

task wait_data_rc;
	@(posedge ACLK);
		while(!amba.AR.READY) @(posedge ACLK);
	#1;
	amba.AR.VALID 	= 1'b0;
	amba.R.READY 	= 1'b1;
	@(posedge ACLK);
		while(!amba.R.VALID) @(posedge ACLK); 
	#1;
	amba.R.READY 	= 1'b0;
endtask

task reset;
	amba.AW.VALID=0;
	amba.W.VALID=0;
	amba.B.READY=0;
endtask

endmodule

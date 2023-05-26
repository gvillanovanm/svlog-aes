OBJ=ip_aes_noamba.sv ula.sv mux_busR.sv mux_busA.sv mux_busB.sv control.sv register_file.sv key_expansion.sv aes.sv

compile: 
	#vcs -sverilog ula.sv
	#vcs -sverilog mux_busR.sv
	#vcs -sverilog mux_busA.sv
	#vcs -sverilog mux_busB.sv
	#vcs -sverilog control.sv
	#vcs -sverilog aes.sv key_expansion.sv
	#vcs -sverilog register_file.sv
	#vcs -sverilog amba_adaptor.sv
	vcs -sverilog -debug_pp +vcs+vcdpluson $(OBJ) -R
dve:
	dve -vpd vcdplus.vpd &
test:
	#vcs -sverilog -debug_pp +vcs+vcdpluson tb_ula.sv -R
clean:
	rm -rf csrc 
	rm -rf simv.daidir 
	rm -rf simv 
	rm -rf ucli.key 
	rm -rf *.vpd
	rm -rf *DVE*

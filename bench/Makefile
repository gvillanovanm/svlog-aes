TB=tb_ip_aes.sv
#TB=tb_amba.sv
#TB=tb_ip_aes_noamba.sv
PACKAGES = ../../axi/rtl/axi4_types.sv
RTL = ../bench_uvm/aes_config.sv \
      ./axi4_lite_hierarchical.sv \
      ./tb_config.svh \
      ../svlog/amba_adaptor.sv \
      ../svlog/ip_aes_noamba.sv \
      ../svlog/ula.sv \
      ../svlog/mux_busR.sv \
      ../svlog/mux_busA.sv \
      ../svlog/mux_busB.sv \
      ../svlog/control.sv \
      ../svlog/register_file.sv \
      ../svlog/key_expansion.sv \
      ../svlog/aes.sv \
      ../svlog/ip_aes.sv \


compile:
	vcs -sverilog -debug_pp +vcs+vcdpluson $(PACKAGES) $(RTL) $(TB) +define+$(MODE) -R
dve:
	dve -vpd vcdplus.vpd &
debug:
	vcs -sverilog -debug_all -debug_access+all +vcs+vcdpluson -gui -R $(TB)
tudo:
	vcs -sverilog -debug_pp +vcs+vcdpluson $(TB) +define+$(MODE) -R
	dve -vpd vcdplus.vpd &
clean:
	rm -rf csrc 
	rm -rf simv.daidir 
	rm -rf simv 
	rm -rf ucli.key 
	rm -rf vcdplus.vpd
	rm -rf DVE*

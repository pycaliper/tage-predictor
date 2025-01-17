
# src/v/bht.sv
# src/v/tage_predictor.sv
# src/v/tage_table.sv
# src/v/top.sv

SV_FILES=$(wildcard src/v/*.sv)
SV_HDRS=$(wildcard src/v/*.svh)

V_FILES=$(SV_FILES:src/v/%.sv=v/%.v)

v/%.v: src/v/%.sv $(SV_HDRS)
	sv2v -D VERILOG $< > $@

btor/%.btor: v/%.v
	yosys -p "read_verilog $<; proc; opt; memory -nomap; opt; dffunmap; clk2fflogic; write_btor $@"

verilog: $(V_FILES)

verilog_full_design: $(V_FILES)
	yosys -p "read_verilog $^; hierarchy -top top; hierarchy -check; proc; opt; memory; flatten; opt; write_verilog v/full_design.v"
# setundef -zero -undriven; 
# opt_expr -mux_undef; opt;

btor: $(SV_FILES:src/v/%.sv=btor/%.btor)

# btor_full_design: $(V_FILES)
# 	yosys -p "read_verilog $^; hierarchy -check; hierarchy -top top; flatten; proc; opt; memory -nomap; opt; clk2fflogic; write_btor btor/full_design.btor"

btor_full_design: v/full_design.v
	yosys -p "read_verilog $^; hierarchy -check; hierarchy -top top; proc; opt; memory; flatten; clk2fflogic; write_btor btor/full_design.btor"


clean:
	rm -f v/*.v btor/*.btor

.PHONY: clean
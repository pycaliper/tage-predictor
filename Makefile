
# src/v/bht.sv
# src/v/tage_predictor.sv
# src/v/tage_table.sv
# src/v/top.sv

SV_FILES=$(wildcard src/v/*.sv)
SV_HDRS=$(wildcard src/v/*.svh)

V_FILES=$(SV_FILES:src/v/%.sv=v/%.v)
PARAMV_FILES=$(SV_FILES:src/v/%.sv=paramv/%.v)

CONFIG_FILE=config_$(BHTWIDTH)_$(TAGEWIDTH).conf

$(CONFIG_FILE):
	rm -f *.conf # remove old .conf files, -f so no error when no .conf files are found
	touch $(CONFIG_FILE) #create a new file with the right name

v/%.v: src/v/%.sv $(SV_HDRS)
	sv2v -D VERILOG $< > $@

paramv/%.v: src/v/%.sv $(SV_HDRS) $(CONFIG_FILE)
	sv2v -D VERILOG -D PARAMV --define=BHT_IDX_WIDTH=$(BHTWIDTH) --define=TAGE_IDX_WIDTH=$(TAGEWIDTH) $< > $@

btor/%.btor: v/%.v
	yosys -p "read_verilog $<; proc; opt; memory -nomap; opt; dffunmap; clk2fflogic; write_btor $@"

parambtor/%.btor: paramv/%.v
	yosys -p "read_verilog $<; proc; opt; memory -nomap; opt; dffunmap; clk2fflogic; write_btor $@"

verilog: $(V_FILES)

paramverilog: $(PARAMV_FILES)

verilog_full_design: $(V_FILES)
	yosys -p "read_verilog $^; hierarchy -top top; hierarchy -check; proc; opt; memory; flatten; opt; write_verilog v/full_design.v"
# setundef -zero -undriven; 
# opt_expr -mux_undef; opt;

btor: $(SV_FILES:src/v/%.sv=btor/%.btor)

parambtor: $(PARAMV_FILES:src/v/%.sv=parambtor/%.btor)

# btor_full_design: $(V_FILES)
# 	yosys -p "read_verilog $^; hierarchy -check; hierarchy -top top; flatten; proc; opt; memory -nomap; opt; clk2fflogic; write_btor btor/full_design.btor"

btor_full_design: $(V_FILES)
	yosys -p "read_verilog $^; hierarchy -top miter; hierarchy -check; proc; opt; memory; flatten; clk2fflogic; write_btor btor/full_design.btor"

parambtor_full_design: $(PARAMV_FILES)
	yosys -p "read_verilog $^; hierarchy -top miter; hierarchy -check; proc; opt; memory; flatten; clk2fflogic; write_btor btor/full_design_$(BHTWIDTH)_$(TAGEWIDTH).btor"

clean:
	rm -f v/*.v btor/*.btor paramv/*.v parambtor/*.btor

.PHONY: clean
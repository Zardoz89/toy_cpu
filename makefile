# Makefile
TESTBENCHPATH = tb/$(TESTBENCHFILE).vhld
TESTBENCHFILE = $(TESTBENCH)_tb

#GHDL config
GHDL=ghdl
GHDLFLAGS= --std=08 --workdir=$(WORKDIR)
GHDLRUNFLAGS=

WORKDIR = work
SIMDIR = sim
WAVEFORM_VIEWER = gtkwave

MODULES=\
	alu32.vhdl \
	alu32_tb.vhdl \
	registers.vhdl \
	registers_tb.vhdl

.PHONY: clean

all : clean alu_wave reg_file_wave

alu_wave: alu_tb
	$(GHDL) -r $(GHDLFLAGS) $< $(GHDLRUNFLAGS) --vcd=$<.vcd

alu_tb: init
	$(GHDL) -e $(GHDLFLAGS) $@

reg_file_wave: reg_file_tb
	$(GHDL) -r $(GHDLFLAGS) $< $(GHDLRUNFLAGS) --vcd=$<.vcd

reg_file_tb: init
	$(GHDL) -e $(GHDLFLAGS) $@

# Object file depends on source
init: $(MODULES)
	@mkdir -p $(WORKDIR)
	@mkdir -p $(SIMDIR)
	$(GHDL) -a $(GHDLFLAGS) $^


run:
	@$(SIMDIR)/$(TESTBENCHFILE) $(GHDL_SIM_OPT) --vcdgz=$(SIMDIR)/$(TESTBENCHFILE).vcdgz

view:
	@gunzip --stdout $(SIMDIR)/$(TESTBENCHFILE).vcdgz | $(WAVEFORM_VIEWER) --vcd

clean:
	@rm -rf $(SIMDIR)
	@rm -rf $(WORKDIR)


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

CODE_STYLER = vsg

MODULES=\
	umul.vhdl \
	umul_tb.vhdl \
	alu32.vhdl \
	alu32_tb.vhdl \
	registers.vhdl \
	registers_tb.vhdl \
	toy_cpu.vhdl \
	toy_cpu_tb.vhdl \
	i_memory.vhdl


.PHONY: all clean style

all : clean umul_wave alu_wave reg_file_wave toy_cpu_wave

umul_wave: umul_tb
	$(GHDL) -r $(GHDLFLAGS) $< $(GHDLRUNFLAGS) --wave=$<.ghw

umul_tb: init
	$(GHDL) -e $(GHDLFLAGS) $@

alu_wave: alu_tb
	$(GHDL) -r $(GHDLFLAGS) $< $(GHDLRUNFLAGS) --wave=$<.ghw

alu_tb: init
	$(GHDL) -e $(GHDLFLAGS) $@

reg_file_wave: reg_file_tb
	$(GHDL) -r $(GHDLFLAGS) $< $(GHDLRUNFLAGS) --wave=$<.ghw

reg_file_tb: init
	$(GHDL) -e $(GHDLFLAGS) $@

toy_cpu_wave: toy_cpu_tb
	$(GHDL) -r $(GHDLFLAGS) $< $(GHDLRUNFLAGS) --wave=$<.ghw

toy_cpu_tb: init
	$(GHDL) -e $(GHDLFLAGS) $@

# Object file depends on source
init: $(MODULES)
	@mkdir -p $(WORKDIR)
	@mkdir -p $(SIMDIR)
	$(GHDL) -a $(GHDLFLAGS) $^


run:
	@$(SIMDIR)/$(TESTBENCHFILE) $(GHDL_SIM_OPT) --wave=$(SIMDIR)/$(TESTBENCHFILE).ghw

view:
	@gunzip --stdout $(SIMDIR)/$(TESTBENCHFILE).ghwgz | $(WAVEFORM_VIEWER) --wave

# Enforce code style
style: $(MODULES)
	$(CODE_STYLER) --fix -f $^

clean:
	@rm -rf $(SIMDIR)
	@rm -rf $(WORKDIR)


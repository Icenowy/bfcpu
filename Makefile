IVERILOG = iverilog

IVFLAGS = -y .

VVP = vvp

OBJCOPY = objcopy

INSTRUCTIONS_DEPTH = 256

%.vvp: %.v
	$(IVERILOG) $(IVFLAGS) $< -o $@

%.vcd: %.vvp
	$(VVP) $(VVPFLAGS) -n $<

%.hex: %.bin
	$(OBJCOPY) -I binary -O verilog $< $@

TD ?= td

TD_SOURCES = bfcpu.v instr_decode.v ip_controller.v stack_ram.v al_ip/i_mem_tang_bram.v al_ip/d_mem_tang_bram.v d_mem_tang.v i_mem_tang.v top_tang.v

.PHONY: bitstream
bitstream: bfcpu.bit

.PHONY: program
program: bfcpu.bit
	$(TD) program.tcl

bfcpu.bit: bfcpu.al td.tcl instructions.mif io.adc $(TD_SOURCES)
	$(TD) td.tcl

sim: instr_decode_tb.vcd top_sim.vcd

instr_decode_tb.vvp: instr_decode_tb.v instr_decode.vvp
top_sim.vvp: top_sim.v i_mem_sim.vvp d_mem_sim.vvp io_sim.vvp bfcpu.vvp
bfcpu.vvp: bfcpu.v ip_controller.vvp instr_decode.vvp stack_ram.vvp

top_sim.vcd: top_sim.vvp instructions.hex

gen_mif: gen_mif.o

instructions.mif: instructions.bin gen_mif
	./gen_mif $(INSTRUCTIONS_DEPTH) < instructions.bin > instructions.mif

clean:
	rm -f *.vvp *.vcd

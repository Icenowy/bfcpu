IVERILOG = iverilog

IVFLAGS = -y .

VVP = vvp

OBJCOPY = objcopy

INSTRUCTIONS_DEPTH = 1024

%.vvp: %.v
	$(IVERILOG) $(IVFLAGS) $< -o $@

%.vcd: %.vvp
	$(VVP) $(VVPFLAGS) -n $<

%.hex: %.bin
	$(OBJCOPY) -I binary -O verilog $< $@

%.mif: %.bin gen_mif
	./gen_mif $(INSTRUCTIONS_DEPTH) < $< > $@

COMMON_SOURCES = bfcpu.v instr_decode.v ip_controller.v stack_ram.v

TD ?= td
QUARTUS_SH ?= quartus_sh
QUARTUS_PGM ?= quartus_pgm

TANG_SOURCES = $(COMMON_SOURCES) al_ip/i_mem_tang_bram.v al_ip/d_mem_tang_bram.v d_mem_tang.v i_mem_tang.v top_tang.v
A_E115FB_SOURCES = $(COMMON_SOURCES) quartus_ip/d_mem_a_e115fb_bram.v quartus_ip/i_mem_a_e115fb_bram.v d_mem_a_e115fb.v i_mem_a_e115fb.v top_a_e115fb.v
DE0_NANO_SOURCES = $(COMMON_SOURCES) quartus_ip/d_mem_de0_nano_bram.v quartus_ip/i_mem_de0_nano_bram.v d_mem_de0_nano.v i_mem_de0_nano.v top_de0_nano.v
ICECREAM_V1_SOURCES = $(COMMON_SOURCES) d_mem_icecream_v1.v i_mem_icecream_v1.v top_icecream_v1.v

.PHONY: sim
sim: instr_decode_tb.vcd top_sim.vcd

.PHONY: bitstream_tang
bitstream_tang: bfcpu_tang.bit

.PHONY: bitstream_a_e115fb
bitstream_a_e115fb: bfcpu_a_e115fb.sof

.PHONY: bitstream_de0_nano
bitstream_de0_nano: bfcpu_de0_nano.sof

.PHONY: bitstream_icecream_v1
bitstream_icecream_v1: bfcpu_icecream_v1.icebin

.PHONY: program_tang
program_tang: bfcpu_tang.bit
	$(TD) program_tang.tcl

.PHONY: program_a_e115fb
program_a_e115fb: bfcpu_a_e115fb.sof
	$(QUARTUS_PGM) -c usb-blaster -m JTAG -o "p;bfcpu_a_e115fb.sof"

.PHONY: program_de0_nano
program_de0_nano: bfcpu_de0_nano.sof
	$(QUARTUS_PGM) -c usb-blaster -m JTAG -o "p;bfcpu_de0_nano.sof"

.PHONY: program_icecream_v1
program_icecream_v1: bfcpu_icecream_v1.icebin
	$(MAKE) -f Makefile_icecream_v1 flash

bfcpu_tang.bit: bfcpu_tang.al td_tang.tcl instructions_tang.mif io_tang.adc timing_tang.sdc $(TANG_SOURCES)
	$(TD) td_tang.tcl

bfcpu_a_e115fb.sof: bfcpu_a_e115fb.qpf top_a_e115fb.qsf quartus_a_e115fb.tcl instructions_a_e115fb.mif top_a_e115fb.sdc $(A_E115FB_SOURCES)
	$(QUARTUS_SH) -t quartus_a_e115fb.tcl && cp output_files/top_a_e115fb.sof bfcpu_a_e115fb.sof

bfcpu_de0_nano.sof: bfcpu_de0_nano.qpf top_de0_nano.qsf quartus_de0_nano.tcl instructions_de0_nano.mif top_de0_nano.sdc $(DE0_NANO_SOURCES)
	$(QUARTUS_SH) -t quartus_de0_nano.tcl && cp output_files/top_de0_nano.sof bfcpu_de0_nano.sof

bfcpu_icecream_v1.icebin: Makefile_icecream_v1 icecream_v1.pcf instructions_icecream_v1.hex $(ICECREAM_V1_SOURCES)
	$(MAKE) -f Makefile_icecream_v1 "$@"

instr_decode_tb.vvp: instr_decode_tb.v instr_decode.vvp
top_sim.vvp: top_sim.v i_mem_sim.vvp d_mem_sim.vvp io_sim.vvp bfcpu.vvp
bfcpu.vvp: bfcpu.v ip_controller.vvp instr_decode.vvp stack_ram.vvp

top_sim.vcd: top_sim.vvp instructions_sim.hex

gen_mif: gen_mif.o

clean:
	rm -f *.vvp *.vcd

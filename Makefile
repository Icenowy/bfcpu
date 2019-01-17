IVERILOG = iverilog

IVFLAGS = -y .

VVP = vvp

OBJCOPY = objcopy

%.vvp: %.v
	$(IVERILOG) $(IVFLAGS) $< -o $@

%.vcd: %.vvp
	$(VVP) $(VVPFLAGS) -n $<

%.hex: %.bin
	$(OBJCOPY) -I binary -O verilog $< $@

sim: instr_decode_tb.vcd top_sim.vcd

instr_decode_tb.vvp: instr_decode_tb.v instr_decode.vvp
top_sim.vvp: top_sim.v i_mem_sim.vvp d_mem_sim.vvp io_sim.vvp bfcpu.vvp
bfcpu.vvp: bfcpu.v ip_controller.vvp instr_decode.vvp stack_ram.vvp

clean:
	rm -f *.vvp *.vcd

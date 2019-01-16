IVERILOG = iverilog

IVFLAGS = -y .

VVP = vvp

%.vvp: %.v
	$(IVERILOG) $(IVFLAGS) $< -o $@

%.vcd: %.vvp
	$(VVP) $(VVPFLAGS) -n $<

sim: instr_decode_tb.vcd

clean:
	rm -f *.vvp *.vcd

`include "config/tb_timescale.v"

module instr_decode_tb();

reg [7:0]instr;

output inc_dp;
output dec_dp;
output inc_d;
output dec_d;
output out_d;
output in_d;
output loop_start;
output loop_end;
output nop;

instr_decode dec(instr, inc_dp, dec_dp, inc_d, dec_d, out_d, in_d, loop_start, loop_end, nop);

initial begin
	$dumpfile("instr_decode_tb.vcd");
        $dumpvars(0,instr_decode_tb);
	instr = 0;
	#4000
	$stop;
end

always begin
	#10
	instr <= "<";
	#20
	instr <= ">";
	#30
	instr <= "+";
	#40
	instr <= "-";
	#50
	instr <= ",";
	#60
	instr <= ".";
	#70
	instr <= "[";
	#80
	instr <= "]";
	#90
	instr <= "~";
end

endmodule

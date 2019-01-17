`include "config/tb_timescale.v"

module instr_decode_tb();

reg [7:0]instr;

wire inc_dp;
wire dec_dp;
wire inc_d;
wire dec_d;
wire out_d;
wire in_d;
wire loop_start;
wire loop_end;
wire nop;

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

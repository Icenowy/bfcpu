module instr_decode(
	input [7:0] instr,
	output inc_dp,
	output dec_dp,
	output inc_d,
	output dec_d,
	output out_d,
	output in_d,
	output loop_start,
	output loop_end,
	output nop
);

assign inc_dp = instr == ">";
assign dec_dp = instr == "<";
assign inc_d = instr == "+";
assign dec_d = instr == "-";
assign out_d = instr == ".";
assign in_d = instr == ",";
assign loop_start = instr == "[";
assign loop_end = instr == "]";

assign nop = !inc_dp && !dec_dp && !inc_d && !dec_d && !out_d && !in_d && !loop_start && !loop_end;

endmodule

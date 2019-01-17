module stack_ram#(
	parameter [7:0]i_addr_width = 8'd16,
	parameter [31:0]max_loop_depth = 32'h100
)(
	input clk,

	input [31:0]write_addr,
	input write_en,
	input [i_addr_width-1:0]write_data,

	input [31:0]read_addr,
	output [i_addr_width-1:0]read_data
);

reg [i_addr_width-1:0]read_data;

reg [i_addr_width-1:0]memory[0:max_loop_depth];

always @(posedge clk) begin
	if (write_en)
		memory[write_addr] <= write_data;

	read_data <= memory[read_addr];
end

endmodule

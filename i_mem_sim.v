module i_mem_sim #(
	parameter [7:0]i_addr_width = 8'd16,
	parameter [31:0]i_mem_length = 32'd256
)(
	input clk,

	input i_req,
	input [i_addr_width-1:0]i_addr,
	output i_ack,
	output [7:0]i_rdata
);

reg [7:0]memory[0:i_mem_length-1];

initial begin
	$readmemh("instructions_sim.hex", memory);
end

assign i_ack = i_req;
assign i_rdata = memory[i_addr];

endmodule

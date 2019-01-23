module i_mem_tang #(
	parameter [7:0]i_addr_width = 8'd16,
	parameter [31:0]i_mem_length = 32'd1024
)(
	input clk,

	input i_req,
	input [i_addr_width-1:0]i_addr,
	output i_ack,
	output [7:0]i_rdata
);

wire [7:0]read_data;

assign i_rdata = read_data;

reg ready;

assign i_ack = i_req ? ready : 0;

always @(posedge clk) begin
	if (i_req)
		ready <= 1;
	else
		ready <= 0;
end

i_mem_tang_bram bram(
	.doa(read_data),
	.addra(i_addr),
	.clka(clk),
	.rsta(0)
);

endmodule

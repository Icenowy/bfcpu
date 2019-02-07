module d_mem_tang #(
	parameter [7:0]d_addr_width = 8'd8,
	parameter [31:0]d_mem_length = 32'd64
)(
	input clk,

	input d_req,
	input d_dir,
	input [d_addr_width-1:0]d_addr,
	input [7:0]d_wdata,
	output d_ack,
	output [7:0]d_rdata
);

`include "macros/direction.vh"

wire write_en;
wire [7:0]write_data;
wire [7:0]read_data;

assign write_en = d_req && d_dir == `DIRECTION_WRITE;
assign write_data = d_wdata;
assign d_rdata = read_data;

reg ready;

assign d_ack = d_req ? ready : 0;

always @(posedge clk) begin
	if (d_req)
		ready <= 1;
	else
		ready <= 0;
end

d_mem_tang_bram bram(
	.doa(read_data),
	.dia(write_data),
	.addra(d_addr),
	.clka(clk),
	.wea(write_en),
	.rsta(0)
);

endmodule

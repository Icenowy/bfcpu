module top_a_e115fb(
	input clk,
	input ext_rst_n,
	output reg [3:0]led_n
);

`include "macros/direction.vh"

reg [2:0] int_rst_cnt = 0;

always @(posedge clk) begin
	if (int_rst_cnt != 3'b111)
		int_rst_cnt <= int_rst_cnt + 1;
end

wire int_rst_n = int_rst_cnt == 3'b111;
wire rst_n = int_rst_n & ext_rst_n;

wire i_req;
wire [15:0]i_addr;
wire i_ack;
wire [7:0]i_rdata;

wire d_req;
wire d_dir;
wire [7:0]d_addr;
wire [7:0]d_wdata;
wire d_ack;
wire [7:0]d_rdata;

wire io_req;
wire io_dir;
wire [7:0]io_wdata;
reg io_ack;
reg [7:0]io_rdata;

bfcpu cpu(
	.clk(clk),
	.rst_n(rst_n),

	.i_req(i_req),
	.i_addr(i_addr),
	.i_ack(i_ack),
	.i_rdata(i_rdata),

	.d_req(d_req),
	.d_dir(d_dir),
	.d_addr(d_addr),
	.d_wdata(d_wdata),
	.d_ack(d_ack),
	.d_rdata(d_rdata),

	.io_req(io_req),
	.io_dir(io_dir),
	.io_wdata(io_wdata),
	.io_ack(io_ack),
	.io_rdata(io_rdata)
);

i_mem_a_e115fb im(
	.clk(clk),
	
	.i_req(i_req),
	.i_addr(i_addr),
	.i_ack(i_ack),
	.i_rdata(i_rdata)
);

d_mem_a_e115fb dm(
	.clk(clk),

	.d_req(d_req),
	.d_dir(d_dir),
	.d_addr(d_addr),
	.d_wdata(d_wdata),
	.d_ack(d_ack),
	.d_rdata(d_rdata)
);

always @(posedge clk) begin
	if (!rst_n) begin
		led_n <= 4'b1111;
		io_ack <= 0;
	end else begin
		if (io_req) begin
			io_ack <= 1;
			if (io_dir == `DIRECTION_WRITE)
				led_n <= ~io_wdata[3:0];
			else
				io_rdata <= {4'b0, ~led_n};
		end else begin
			io_ack <= 0;
		end
	end
end

endmodule

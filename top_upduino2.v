module top_upduino2(
	output [2:0]led_n
);

`include "macros/direction.vh"

wire clk;

reg [2:0] int_rst_cnt = 0;

always @(posedge clk) begin
	if (int_rst_cnt != 3'b111)
		int_rst_cnt <= int_rst_cnt + 1;
end

wire int_rst_n = int_rst_cnt == 3'b111;
wire rst_n = int_rst_n;

reg [2:0]led;

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

SB_HFOSC #(
	.CLKHF_DIV("0b10")
) hfosc (
	.CLKHFEN(1),
	.CLKHFPU(1),
	.CLKHF(clk)
);

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

i_mem_upduino2 im(
	.clk(clk),
	
	.i_req(i_req),
	.i_addr(i_addr),
	.i_ack(i_ack),
	.i_rdata(i_rdata)
);

d_mem_upduino2 dm(
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
		led <= 3'b000;
		io_ack <= 0;
	end else begin
		if (io_req) begin
			io_ack <= 1;
			if (io_dir == `DIRECTION_WRITE)
				led <= io_wdata[2:0];
			else
				io_rdata <= {5'b0, led};
		end else begin
			io_ack <= 0;
		end
	end
end

SB_RGBA_DRV #(
	.RGB0_CURRENT("0b000001"),
	.RGB1_CURRENT("0b000001"),
	.RGB2_CURRENT("0b000001")
) rgb_driver(
	.RGBLEDEN(1),
	.CURREN(1),
	.RGB0PWM(led[0]),
	.RGB1PWM(led[1]),
	.RGB2PWM(led[2]),
	.RGB0(led_n[0]),
	.RGB1(led_n[1]),
	.RGB2(led_n[2])
);

endmodule

`include "config/tb_timescale.v"

module top_sim();

reg clk;
reg rst_n;

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
wire io_ack;
wire [7:0]io_rdata;

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

i_mem_sim im(
	.clk(clk),
	
	.i_req(i_req),
	.i_addr(i_addr),
	.i_ack(i_ack),
	.i_rdata(i_rdata)
);

d_mem_sim dm(
	.clk(clk),

	.d_req(d_req),
	.d_dir(d_dir),
	.d_addr(d_addr),
	.d_wdata(d_wdata),
	.d_ack(d_ack),
	.d_rdata(d_rdata)
);

io_sim io(
	.io_req(io_req),
	.io_dir(io_dir),
	.io_wdata(io_wdata),
	.io_ack(io_ack),
	.io_rdata(io_rdata)
);

initial begin
	$dumpfile("top_sim.vcd");
        $dumpvars(0,top_sim);
	clk = 0;
	#10
	rst_n = 0;
	#50
	rst_n = 1;
	#40000
	$stop;
end

always begin
	#5
	clk = ~clk;
end

endmodule

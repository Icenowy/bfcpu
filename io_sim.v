module io_sim(
	input io_req,
	input io_dir,
	input [7:0]io_wdata,
	output io_ack,
	output [7:0]io_rdata
);

`include "macros/direction.vh"

assign io_ack = io_req;

reg [7:0]io_rdata;

always @(posedge io_req) begin
	if (io_dir == `DIRECTION_WRITE) begin
		io_rdata <= io_wdata;
		$display("IO Output %c\n", io_wdata);
	end
end

endmodule

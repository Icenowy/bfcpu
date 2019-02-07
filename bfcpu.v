module bfcpu #(
	parameter [8:0]i_addr_width = 8'd16,
	parameter [8:0]d_addr_width = 8'd8,
	parameter [31:0]reset_vector = 32'h0,
	parameter [31:0]reset_dp = 32'h0,
	parameter [31:0]max_loop_depth = 32'h100,
	parameter [7:0]sp_width = 8'd8
)(
	input clk,
	input rst_n,

	output reg i_req,
	output reg [i_addr_width-1:0]i_addr,
	input i_ack,
	input [7:0]i_rdata,

	output reg d_req,
	output reg d_dir,
	output reg [d_addr_width-1:0]d_addr,
	output reg [7:0]d_wdata,
	input d_ack,
	input [7:0]d_rdata,

	output reg io_req,
	output reg io_dir,
	output reg [7:0]io_wdata,
	input io_ack,
	input [7:0]io_rdata,

	output reg halt_n
);

`include "macros/states.vh"
`include "macros/direction.vh"

wire [i_addr_width-1:0]ip;
reg [d_addr_width-1:0]dp;

reg [7:0]instruction;
wire inc_dp;
wire dec_dp;
wire inc_d;
wire dec_d;
wire out_d;
wire in_d;
wire loop_start;
wire loop_end;
wire nop;

reg [7:0]d;
reg d_valid;
reg d_dirty;

reg [5:0]state;
reg [5:0]state_next;

wire update_ip = halt_n && state_next == `STATE_IF_REQ;
reg jmp;
reg [i_addr_width-1:0]jmp_target;

reg last_loop_end_success;
reg [i_addr_width-1:0]last_loop_end_ip;

reg [sp_width-1:0]skip_loop_count;

reg [sp_width-1:0]sp;
reg [sp_width-1:0]stack_write_addr;
wire [sp_width-1:0]stack_read_addr = sp;
reg stack_write_en;
reg [i_addr_width-1:0]stack_write_data;
wire [i_addr_width-1:0]stack_read_data;
reg [i_addr_width-1:0]stack_read_data_reg;

instr_decode i_dec(
	.instr(instruction),
	.inc_dp(inc_dp),
	.dec_dp(dec_dp),
	.inc_d(inc_d),
	.dec_d(dec_d),
	.out_d(out_d),
	.in_d(in_d),
	.loop_start(loop_start),
	.loop_end(loop_end),
	.nop(nop)
);

ip_controller#(
	.i_addr_width(i_addr_width),
	.reset_vector(reset_vector)
) ip_ctrl(
	.clk(clk),
	.rst_n(rst_n),
	.update_ip(update_ip),
	.jmp(jmp),
	.jmp_target(jmp_target),
	.ip(ip)
);

stack_ram#(
	.i_addr_width(i_addr_width),
	.max_loop_depth(max_loop_depth),
	.sp_width(sp_width)
) st_mem(
	.clk(clk),

	.write_addr(stack_write_addr),
	.write_en(stack_write_en),
	.write_data(stack_write_data),

	.read_addr(stack_read_addr),
	.read_data(stack_read_data)
);

always @(posedge clk) begin
	if (!rst_n) begin
		state <= `STATE_START;
		state_next <= `STATE_START;

		jmp <= 0;
		skip_loop_count <= 8'b0;
	end else begin
		if (halt_n) begin
			state <= state_next;

			case (state_next)
			`STATE_IF_REQ:
				state_next <= `STATE_IF_WAIT;
			`STATE_IF_WAIT:
				if (i_ack)
					state_next <= `STATE_IF_ACK;
			`STATE_IF_ACK: begin
				instruction <= i_rdata;
				state_next <= `STATE_INSTR_DECODE;
			end
			`STATE_DATA_R_REQ:
				state_next <= `STATE_DATA_R_WAIT;
			`STATE_DATA_R_WAIT:
				if (d_ack)
					state_next <= `STATE_DATA_R_ACK;
			`STATE_DATA_R_ACK: begin
				if (inc_d || dec_d)
					state_next <= `STATE_D_EX;
				else if (out_d)
					state_next <= `STATE_IO_W_REQ;
				else if (loop_start)
					state_next <= `STATE_LOOP_START_EX;
				else
					state_next <= `STATE_LOOP_END_EX;
			end
			`STATE_DATA_W_REQ:
				state_next <= `STATE_DATA_W_WAIT;
			`STATE_DATA_W_WAIT:
				if (d_ack)
					state_next <= `STATE_DATA_W_ACK;
			`STATE_DATA_W_ACK:
				state_next <= `STATE_DP_EX;
			`STATE_IO_R_REQ:
				state_next <= `STATE_IO_R_WAIT;
			`STATE_IO_R_WAIT:
				if (io_ack)
					state_next <= `STATE_IO_R_ACK;
			`STATE_IO_R_ACK:
				state_next <= `STATE_IF_REQ;
			`STATE_IO_W_REQ:
				state_next <= `STATE_IO_W_WAIT;
			`STATE_IO_W_WAIT:
				if (io_ack)
					state_next <= `STATE_IO_W_ACK;
			`STATE_IO_W_ACK:
				state_next <= `STATE_IF_REQ;
			`STATE_START:
				state_next <= `STATE_IF_REQ;
			`STATE_INSTR_DECODE:
				if (skip_loop_count != 0) begin
					state_next <= `STATE_IF_REQ;
					if (loop_start)
						skip_loop_count <= skip_loop_count + 1;
					else if (loop_end)
						skip_loop_count <= skip_loop_count - 1;
					jmp <= 0;
				end else if (inc_dp || dec_dp) begin
					state_next <= d_dirty ? `STATE_DATA_W_REQ : `STATE_DP_EX;
					jmp <= 0;
				end else if (inc_d || dec_d) begin
					state_next <= !d_valid ? `STATE_DATA_R_REQ : `STATE_D_EX;
					jmp <= 0;
				end else if (out_d) begin
					state_next <= !d_valid ? `STATE_DATA_R_REQ : `STATE_IO_W_REQ;
					jmp <= 0;
				end else if (in_d) begin
					state_next <= `STATE_IO_R_REQ;
					jmp <= 0;
				end else if (loop_start) begin
					state_next <= !d_valid ? `STATE_DATA_R_REQ : `STATE_LOOP_START_EX;
				end else if (loop_end) begin
					state_next <= !d_valid ? `STATE_DATA_R_REQ : `STATE_LOOP_END_EX;
				end else begin
					state_next <= `STATE_IF_REQ;
					jmp <= 0;
				end
			`STATE_DP_EX:
				state_next <= `STATE_IF_REQ;
			`STATE_D_EX:
				state_next <= `STATE_IF_REQ;
			`STATE_LOOP_START_EX: begin
				if (!d) begin
					if (last_loop_end_success) begin
						jmp <= 1;
					end else begin
						jmp <= 0;
						skip_loop_count <= skip_loop_count + 1;
					end
				end else begin
					jmp <= 0;
				end
				state_next <= `STATE_IF_REQ;
			end
			`STATE_LOOP_END_EX: begin
				if (d)
					jmp <= 1;
				else
					jmp <= 0;
				stack_read_data_reg <= stack_read_data;
				state_next <= `STATE_IF_REQ;
			end
			default:
				state_next <= `STATE_IF_REQ;
			endcase
		end
	end
end

always @(posedge clk) begin
	if (!rst_n) begin
		d_valid <= 0;
		d_dirty <= 0;
	end else begin
		case (state_next)
		`STATE_DATA_R_ACK: begin
			d <= d_rdata;
			d_valid <= 1;
			d_dirty <= 0;
		end
		`STATE_DATA_W_ACK:
			d_dirty <= 0;
		`STATE_IO_R_ACK: begin
			d <= io_rdata;
			d_valid <= 1;
			d_dirty <= 1;
		end
		`STATE_DP_EX: begin
			d_valid <= 0;
			d_dirty <= 0;
		end
		`STATE_D_EX: begin
			d_dirty <= 1;
			if (inc_d)
				d <= d + 1;
			else
				d <= d - 1;
		end
		endcase
	end
end

always @(negedge clk) begin
	if (!rst_n) begin
		i_req <= 0;
	end else begin
		case (state)
		`STATE_IF_REQ: begin
			i_addr <= ip;
			i_req <= 1;
		end
		`STATE_IF_ACK:
			i_req <= 0;
		endcase
	end
end

always @(negedge clk) begin
	if (!rst_n) begin
		d_req <= 0;
	end else begin
		case (state)
		`STATE_DATA_R_REQ: begin
			d_addr <= dp;
			d_dir <= `DIRECTION_READ;
			d_req <= 1;
		end
		`STATE_DATA_R_ACK:
			d_req <= 0;
		`STATE_DATA_W_REQ: begin
			d_addr <= dp;
			d_dir <= `DIRECTION_WRITE;
			d_wdata <= d;
			d_req <= 1;
		end
		`STATE_DATA_W_ACK:
			d_req <= 0;
		endcase
	end
end

always @(negedge clk) begin
	if (!rst_n) begin
		io_req <= 0;
	end else begin
		case (state)
		`STATE_IO_R_REQ: begin
			io_dir <= `DIRECTION_READ;
			io_req <= 1;
		end
		`STATE_IO_R_ACK:
			io_req <= 0;
		`STATE_IO_W_REQ: begin
			io_dir <= `DIRECTION_WRITE;
			io_wdata <= d;
			io_req <= 1;
		end
		`STATE_IO_W_ACK:
			io_req <= 0;
		endcase
	end
end

always @(negedge clk) begin
	if (!rst_n) begin
		dp <= 0;
	end else begin
		case (state)
		`STATE_DP_EX:
			if (inc_dp)
				dp <= dp + 1;
			else if (dec_dp)
				dp <= dp - 1;
		endcase
	end
end

always @(negedge clk) begin
	if (!rst_n) begin
		last_loop_end_success = 0;
		sp <= 0;
		stack_write_en <= 0;
		halt_n <= 1;
	end else begin
		if (state == `STATE_LOOP_START_EX) begin
			if (!d) begin
				if (last_loop_end_success)
					jmp_target <= last_loop_end_ip + 1;
			end else begin
				stack_write_addr <= sp + 1;
				stack_write_en <= 1;
				stack_write_data <= ip;
				sp <= sp + 1;
			end
		end else begin
			stack_write_en <= 0;
		end
		if (state == `STATE_LOOP_END_EX) begin
			if (d) begin
				jmp_target <= stack_read_data_reg + 1;
				last_loop_end_success <= 1;
				last_loop_end_ip <= ip;
			end else begin
				last_loop_end_success <= 0;
				if (sp == 0)
					halt_n <= 0;
				sp <= sp - 1;
			end
		end
	end
end

endmodule

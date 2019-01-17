module ip_controller #(
	parameter [8:0]i_addr_width = 8'd16,
	parameter [31:0]reset_vector = 32'h0
)(
	input clk,
	input rst_n,
	input update_ip,
	input jmp,
	input jmp_target,
	output ip
);

reg [i_addr_width-1:0]ip;

always @(posedge clk) begin
	if (rst_n) begin
		ip <= reset_vector - 1;
	end else begin
		if (update_ip) begin
			if (jmp)
				ip <= jmp_target;
			else
				ip <= ip + 1;
		end
	end
end

endmodule

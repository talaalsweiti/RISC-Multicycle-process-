`timescale 1ns / 1ps

module reg_alu_out(
		input clk,
		input rst,
		input [31:0] ALUIn,
		output reg [31:0] ALUOut
    );
	 
	always @(posedge clk)
		begin
		if (rst)
			begin
			ALUOut <= 32'd0;
			end
		else
			begin
			ALUOut <= ALUIn;
			end
		end
		
endmodule
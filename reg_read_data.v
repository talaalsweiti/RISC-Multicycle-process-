	   module reg_read_data(
		input clk,
		input rst,
		input [31:0] readIn,
		output reg [31:0] readOut
    );
	 
	always @(posedge clk)
		begin
		if (rst)
			begin
			readOut <= 32'h00000000;
			end
		else
			begin
			readOut <= readIn;
			end
		end
		
endmodule
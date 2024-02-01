module left_shift_two (in_data, out_data);
	input [31:0] in_data;
	output reg[31:0] out_data;
	assign out_data = in_data << 2;

endmodule



module left_shift_two_tb();
	reg [31:0] in_data; 
	wire [31:0] out_data;
	
	left_shift_two m(in_data, out_data);	  
	
	initial
		begin
			in_data = 32'b1;	
			
			#5ns in_data = 32'b10;
			
			#5ns in_data = 32'b11; 
			
			#5ns ;
	end
	
endmodule
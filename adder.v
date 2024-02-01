module adder(in1,in2,out);	
	
	input [31:0] in1 , in2 ; 
	output reg  [31:0] out;  
	
	assign out = in1 + in2; 
	  
endmodule 	 



module adder_tb();	
	
	reg [31:0] in1 , in2  ; 
	wire  [31:0] out;		  
	adder a(in1,in2,out);
	initial begin
		// Apply some initial inputs
		in1 = 4;
		
		in2=4;	 
		// Display updated values
		$display("Time=%0t, input_data=%b, output_data=%b", $time, in1, out);

	end
	
endmodule 
`timescale 1ns / 1ps
module mux_2x1(
		output [31:0] out,
		input select,
		input [31:0] in0,
		input [31:0] in1
	);

parameter DATA_WIDTH = 32;

genvar i;
generate
	for(i = 0; i < DATA_WIDTH; i = i + 1)
		begin: mux
		nbit_mux #(.SELECT_WIDTH(1)) mux ({in1[i], in0[i]}, out[i], select);
		end
endgenerate

endmodule  



module mux_2x1_tb()	  ;
	reg [31:0] data_0;
 	reg [31:0] data_1;
  
  
  	reg selection;
  	wire [31:0] mux_out; 
	  
	mux_2x1 UUT(mux_out,selection,data_0 ,data_1);  
	
	initial
		begin
			data_0=4'b11;data_1=4'b01;   
			selection =0; 		 
				
	end
endmodule
	  
	  
	
	
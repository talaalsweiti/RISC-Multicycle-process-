
module mux_3x1(
		output [31:0] out,
		input [1:0] select,
		input [31:0] in0,
		input [31:0] in1,
		input [31:0] in2
	);

parameter DATA_WIDTH = 32;

genvar i;
generate
	for(i = 0; i < DATA_WIDTH; i = i + 1)
		begin: mux
		nbit_mux #(.SELECT_WIDTH(2)) mux ({1'b0, in2[i], in1[i], in0[i]}, out[i], select);
		end
endgenerate

endmodule

module mux_3x1_tb(); 
	reg [31:0] data_0;
 	reg [31:0] data_1;
  	reg [31:0] data_2;
  
  	reg [1:0] selection;
  	wire [31:0] mux_out; 
	  
	mux_3x1 m(mux_out,selection,data_0 ,data_1, data_2);  
	
	initial
		begin
			data_0=32'b11;data_1=32'b01;data_2=32'b00;   
			selection =0; 		 
				
	end
	
endmodule
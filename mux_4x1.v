module mux_4x1(
		output [31:0] out,
		input [1:0] select,
		input [31:0] in0,
		input [31:0] in1,
		input [31:0] in2,
		input [31:0] in3
	);

parameter DATA_WIDTH = 32;

genvar i;
generate
	for(i = 0; i < DATA_WIDTH; i = i + 1)
		begin: mux
		nbit_mux #(.SELECT_WIDTH(2)) mux ({in3[i], in2[i], in1[i], in0[i]}, out[i], select);
		end
endgenerate

endmodule



`timescale 1ns/1ns // Set timescale for simulation

module tb_mux_4x1;

  // Inputs and outputs
  reg [31:0] out;
  reg [1:0] select;
  reg [31:0] in0, in1, in2, in3;

  // Instantiate the 4x1 multiplexer module
  mux_4x1 uut(
    .out(out),
    .select(select),
    .in0(in0),
    .in1(in1),
    .in2(in2),
    .in3(in3)
  );

  // Clock generation
  reg clk = 0;
  always #5 clk = ~clk;

  // Initializations
  initial begin
    // Initialize inputs
    select = 2'b00;
    in0 = 32'hAAAAAAAA;
    in1 = 32'hBBBBBBBB;
    in2 = 32'hCCCCCCCC;
    in3 = 32'hDDDDDDDD;

    // Apply reset (if any)
    // You can also add a reset signal in the mux_4x1 module and use it here

    // Stimulus generation
    // Change inputs and select values as needed
    #10 select = 2'b01;
    #10 in2 = 32'h12345678;
    #10 select = 2'b10;
    #10 in3 = 32'h87654321;
    #10 select = 2'b11;
    #10 in0 = 32'h11111111;

    // Add more test cases as needed

    // End simulation
    #10 $finish;
  end

endmodule

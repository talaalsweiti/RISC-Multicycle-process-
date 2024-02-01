`timescale 1ns/1ns //set time for delays to be in ns with percision of ns

module pc(
	input clk,
	input rst,
	input [31:0] new_pc,
	input PCWrite,
	output reg [31:0] PC);	
	
	always @(posedge clk)
		begin
		if (rst)
			begin
			PC <= 32'd0;
			end
		else if (PCWrite)
			begin
			PC <= new_pc;
			end
		end
    
endmodule

	  
module pc_tb();	  
	reg [31:0] pc_in; 
	reg clk,rst;
	reg pcwrite;
	wire [31:0] pc_out;
	
	pc p(clk,rst,pc_in,pcwrite,pc_out);	  

	// Clock generation
	initial begin
	clk = 0;
	forever #5 clk = ~clk; // Generate a clock with a period of 10 time units
	end
	
	// Test stimulus
	initial begin 
	rst = 1;	
	
	#10 rst = 0;
	// Apply some initial inputs
	pc_in = 32'h00000001; // Example value for pc_in
	pcwrite = 1;        // Example value for state
	
	// Allow some time for the initial block to set pc_out to -4
	#10;
	
	// Display initial values
	$display("Time=%0t, clk=%b, pc_in=%h, state=%b, pc_out=%h", $time, clk, pc_in, pcwrite, pc_out);
	
	// Apply more inputs and observe the behavior
	pc_in = 32'h00000002;
	
	
	// Allow time for the always block to update pc_out
	#10;
	
	// Display updated values
	$display("Time=%0t, clk=%b, pc_in=%h, state=%b, pc_out=%h", $time, clk, pc_in, pcwrite, pc_out);
	
	// Add more test scenarios as needed
	
	// End the simulation
	$stop;
	end

endmodule
	
`timescale 1ns/1ns //set time for delays to be in ns with percision of ns

module sp(clk, rst, stack_sig, SP_OUT);
    input clk, rst;
    input stack_sig; // 1 means push, 0 means pop
    output reg [31:0] SP_OUT;

    always @* begin
        if (rst) begin
            SP_OUT = 32'd512;
        end else if (stack_sig == 1) begin
            if (SP_OUT < 32'd764) begin
                SP_OUT = SP_OUT + 4;
            end else begin
                SP_OUT = 32'd512;
            end
        end else if (stack_sig == 0) begin
            if (SP_OUT > 32'd515) begin
                SP_OUT = SP_OUT - 4;
            end else begin
                SP_OUT = 32'd512;
            end
        end
    end
endmodule



	  
module sp_tb();	  
	reg clk ,rst;
	 
	reg stack_sig ; // 1 means push, 0 means pop
	wire  [31:0] sp_out;
	
	sp p(clk,rst,stack_sig,sp_out);	  

	// Clock generation
	initial begin
	clk = 0;
	forever #5 clk = ~clk; // Generate a clock with a period of 10 time units
	end
	
	// Test stimulus
	initial begin 
	rst = 1;	
	
	#10;
	// Apply some initial inputs
 
	stack_sig = 1;        
		rst = 0;	
	// Allow some time for the initial block to set pc_out to -4
	#10;
	
	$display("Time=%0t, clk=%b,rest= %b,  state=%b, pc_out=%d", $time, clk, rst, stack_sig, sp_out);
	// Apply more inputs and observe the behavior
 
	
	  stack_sig = 0;
	// Allow time for the always block to update pc_out
	#10;
	
$display("Time=%0t, clk=%b,rest= %b,  state=%b, pc_out=%d", $time, clk, rst, stack_sig, sp_out);
	
		
	  stack_sig = 0;
	// Allow time for the always block to update pc_out
	#10;
	
$display("Time=%0t, clk=%b,rest= %b,  state=%b, pc_out=%d", $time, clk, rst, stack_sig, sp_out);
	
	
	// End the simulation
	$stop;
	end

endmodule
	
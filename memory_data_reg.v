`timescale 1ns / 1ps

module Memory_Data_Register(
    input clock,
	input rst,
    input [31:0] data_in,
    output reg[31:0] data_out
);

 

always @(posedge clock)
		begin
		if (rst)
			begin
			data_out <= 32'd0;
			end
		else
			begin
			data_out <= data_in;
			end
		end

endmodule


// Testbench for Memory_Data_Register
module Memory_Data_Register_tb;

// Inputs
reg clock;
reg [31:0] data_in;
reg rst ;
// Outputs
wire [31:0] data_out;

// Instantiate the Unit Under Test (UUT)
Memory_Data_Register uut (
.clock(clock),
.rst(rst),
    .data_in(data_in),
    .data_out(data_out)
);

// Clock generation
initial begin
    clock = 0;
    forever #10 clock = ~clock; // 50MHz clock
end

// Test stimulus
initial begin
    // Initialize Inputs
    data_in = 0;
	rst = 0;
    // Wait for global reset
    #100;
	
	
    // Apply test stimulus
    data_in = 32'hAAAAAAAA;
    #20;

    data_in = 32'h55555555;
    #20;

    data_in = 32'h12345678;
    #20;

    // Add additional stimulus as required

    // Finish the simulation
    #100;
    $finish;
end

// Optional: Monitor changes
initial begin
    $monitor("At time %t, data_in = %h, data_out = %h",
             $time, data_in, data_out);
end

endmodule

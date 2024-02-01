// Code your design here
module register_file(
    input clk,
    input [3:0] RA1, RA2, // Read addresses (4 bits for 0-15)
    input [3:0] RW1, RW2, // Write addresses (4 bits for 0-15)
    input RegWrite1, RegWrite2, // Write enable signals for each write port
    input [31:0] Bus_W1, Bus_W2, // Write data inputs
    output reg [31:0] Bus_A1, Bus_A2 // Read data outputs, declared as 'reg'
);
    
    reg [31:0] register_file [0:15]; // 16 registers, each 32 bits wide

    // Initialize register file to 0
    integer i;
    initial begin
        for(i = 0; i < 16; i = i + 1) begin
            register_file[i] = 32'b0;
        end
    end
	
	assign	Bus_A1 = register_file[RA1];
    assign	Bus_A2 = register_file[RA2];
    // Write operations
    always @(posedge clk) begin
        if (RegWrite1) begin
            register_file[RW1] <= Bus_W1;
        end
        if (RegWrite2) begin
            register_file[RW2] <= Bus_W2;
        end
    end

   

endmodule		  
`timescale 1ns / 1ps

module RegFile_tb;

    // Inputs
    reg clk;
    reg [3:0] RA1, RA2;
    reg [3:0] RW1, RW2;
    reg RegWrite1, RegWrite2;
    reg [31:0] Bus_W1, Bus_W2;

    // Outputs
    wire [31:0] Bus_A1, Bus_A2;

    // Instantiate the Unit Under Test (UUT)
    register_file uut (
        .clk(clk), 
        .RA1(RA1), 
        .RA2(RA2), 
        .RW1(RW1), 
        .RW2(RW2), 
        .RegWrite1(RegWrite1), 
        .RegWrite2(RegWrite2), 
        .Bus_W1(Bus_W1), 
        .Bus_W2(Bus_W2), 
        .Bus_A1(Bus_A1), 
        .Bus_A2(Bus_A2)
    );

    // Clock generation
    initial begin
        clk = 0;
        forever #10 clk = ~clk;
    end

    // Test stimulus
    initial begin
        // Initialize Inputs
        RA1 = 0;
        RA2 = 0;
        RW1 = 0;
        RW2 = 0;
        RegWrite1 = 0;
        RegWrite2 = 0;
        Bus_W1 = 0;
        Bus_W2 = 0;

        // Wait for global reset
        #100;

        // Test Case 1: Write to register 1 and read from it
        RW1 = 1; Bus_W1 = 32'hAAAA_AAAA; RegWrite1 = 1;
        #20;
        RegWrite1 = 0; RA1 = 1;
        #20;

        // Test Case 2: Write to another register and read from it
        RW2 = 2; Bus_W2 = 32'hBBBB_BBBB; RegWrite2 = 1;
        #20;
        RegWrite2 = 0; RA2 = 2;
        #20;

        // Test Case 3: Write to two registers at the same time
        RW1 = 3; Bus_W1 = 32'hCCCC_CCCC; RegWrite1 = 1;
        RW2 = 4; Bus_W2 = 32'hDDDD_DDDD; RegWrite2 = 1;
        #20;
        RegWrite1 = 0; RegWrite2 = 0; RA1 = 3; RA2 = 4;
        #20;

        // Test Case 4: Read from a register that hasn't been written to
        RA1 = 5; RA2 = 6;
        #20;

        // Test Case 5: Simultaneous read and write
        RW1 = 1; Bus_W1 = 32'hEEEE_EEEE; RegWrite1 = 1; RA1 = 1;
        #20;
        RegWrite1 = 0;

        // Add more test cases as needed

        // Complete the test
        #100;
        $finish;
    end
      
endmodule

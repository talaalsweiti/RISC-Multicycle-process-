module Extender(
    input wire [15:0] imm16,
    input wire ExtOp,
    output wire [31:0] imm32
);

    // Perform sign-extension if ExtOp is high, zero-extension if ExtOp is low
    assign imm32 = ExtOp ? {{16{imm16[15]}}, imm16} : {16'd0, imm16};

endmodule
`timescale 1ns / 1ps

module Extender_tb;

reg [15:0] imm16;
reg ExtOp;
wire [31:0] imm32;

// Instantiate the Extender
Extender uut (
    .imm16(imm16),
    .ExtOp(ExtOp),
    .imm32(imm32)
);

initial begin
    // Initialize Inputs
    imm16 = 16'h0000;
    ExtOp = 0;

    // Wait 100 ns for global reset to finish
    #100;

    // Add stimulus here

    // Test case 1: Zero extension
    imm16 = 16'h7FFF; // Largest positive 16-bit number
    ExtOp = 0; // Zero extension
    #10;

    // Check the result
    if (imm32 !== 32'h00007FFF) $display("Test Case 1 Failed");

    // Test case 2: Sign extension with a positive number
    imm16 = 16'h7FFF; // Largest positive 16-bit number
    ExtOp = 1; // Sign extension
    #10;

    // Check the result
    if (imm32 !== 32'h00007FFF) $display("Test Case 2 Failed");

    // Test case 3: Sign extension with a negative number
    imm16 = 16'h8000; // Largest negative 16-bit number in 2's complement
    ExtOp = 1; // Sign extension
    #10;

    // Check the result
    if (imm32 !== 32'hFFFF8000) $display("Test Case 3 Failed");

    // Finish the simulation
    $finish;
end

endmodule

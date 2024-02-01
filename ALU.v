// Code your design here
module ALU (
    input [31:0] A,
    input [31:0] B,
    input [1:0] opcode, //  bit opcode
    output reg [31:0] result,
    output reg carry,
    output reg zero,
    output reg negative,
    output reg overflow
);

initial begin 
    carry = 0;
    zero = 0;
    negative = 0;
    overflow = 0;
end 

always @(*) begin 
    // Reset the flags for each operation
    carry = 0;
    zero = 0;
    negative = 0;
    overflow = 0;

    case (opcode)
        2'b01: begin // ADD
            {carry, result} = A + B; // Carry out
            overflow = A[31] ^ B[31] ^ result[31] ^ carry; // Overflow for addition
        end

        2'b10: begin // SUB
            {carry, result} = A - B; // Borrow in subtraction is the carry here
            overflow = A[31] ^ B[31] ^ result[31] ^ carry; // Overflow for subtraction
        end

        2'b00: begin // AND
            result = A & B;
        end

        default: begin
            result = 0; // Default case to handle unused opcodes
        end
    endcase

    zero = (result == 0); // Zero flag
    negative = result[31]; // Negative flag if MSB is 1
end

endmodule	
`timescale 1ns / 1ps

module ALU_tb;

reg [31:0] A;
reg [31:0] B;
reg [1:0] opcode;
wire [31:0] result;
wire carry, zero, negative, overflow;

// Instantiate the ALU module
ALU uut (
    .A(A), 
    .B(B), 
    .opcode(opcode), 
    .result(result), 
    .carry(carry), 
    .zero(zero), 
    .negative(negative), 
    .overflow(overflow)
);

initial begin
    // Initialize Inputs
    A = 0;
    B = 0;
    opcode = 0;

    // Wait 100 ns for global reset to finish
    #100;

    // Add stimulus here

    // Test case 1: ADD
    A = 32'd10; // 10 in decimal
    B = 32'd15; // 15 in decimal
    opcode = 2'b01; // ADD operation
    #10; // Wait for 10 ns

    // Test case 2: SUB
    A = 32'd20;
    B = 32'd10;
    opcode = 2'b10; // SUB operation
    #10;

    // Test case 3: AND
    A = 32'd12; // Binary: 1100
    B = 32'd5;  // Binary: 0101
    opcode = 2'b00; // AND operation
    #10;

    // Add more test cases as needed

    // Finish the simulation
    $finish;
end

endmodule

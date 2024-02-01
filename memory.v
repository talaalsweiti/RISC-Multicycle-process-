module memory(
    input wire clk,                // Clock signal
    input wire memRead,            // Memory read signal
    input wire memWrite,           // Memory write signal
    input wire [31:0] address,     // 32-bit input address
    input wire [31:0] data_in,     // 32-bit input data to write
    output reg [31:0] data_out     // 32-bit output data read
);

    // Define memory size for each segment; adjust sizes as needed
    parameter INSTR_SEGMENT_SIZE = 256;  // 256 words 
    parameter DATA_SEGMENT_SIZE = 256;   //  256 words
    parameter STACK_SEGMENT_SIZE = 256;  //  256 words 

    // Total memory size in bytes
    parameter TOTAL_MEMORY_SIZE = (INSTR_SEGMENT_SIZE + DATA_SEGMENT_SIZE + STACK_SEGMENT_SIZE);

    // Memory array (word-addressable)
    reg [31:0] memory_array [0:TOTAL_MEMORY_SIZE-1];
	
	// Initialize memory with instructions, data, and stack values
    initial begin
        //Instructions segment initialization 
		
		//AND			   
		///	
		/*
		op = 000000
		rd = 0010
		rs1=  0011
		rs2 = 0100
		
		answer = 0000
		*/
        memory_array[0] = 32'b00000000100011010000000000000000;
		
		//ADD
		memory_array[1] = 32'b00000101110011010000000000000000;
	 
		//SUB
		memory_array[2] = 32'b00001000100111010100000000000000;
	 
		//ANDI
		memory_array[3] = 32'b00001100110100000000000000100000;
	 
		//ADDI
		memory_array[4] = 32'b00010010100001000000000000100100;
		 
	 
		//LW
		memory_array[5] = 32'b00010100010011000001000000000000;
 
		//LW.POI
		memory_array[6] = 32'b00011000010101000001000000000001;
		 	
		//SW
		memory_array[7] = 32'b00011100011001000001000000000000;
	
		//BGT
		memory_array[8] = 32'b00100000011001000001000000000000;
		 	
		//BLT
		memory_array[9] = 32'b00100100011000000001000000000000;
		 	
		//BEQ
		memory_array[10] = 32'b00101000010101000001000000000000;
		 
		//BNQ
		memory_array[11] = 32'b00101100010101000001000000000000;
		 
		//JMP
		memory_array[12] = 32'b00110000000000000000001111101000;
	 
		//CALL
		memory_array[13] = 32'b00110100000000000000000001100100;
		 
		//RET
		memory_array[14] = 32'b00111000000000000000011111010000;
	 
		//PUSH
		memory_array[15] = 32'b00111110010000000000000000000000;
	 
		//POP
		memory_array[16] = 32'b01000010000000000000000000000000;
	 
		
        //Data segment initialization
        memory_array[INSTR_SEGMENT_SIZE] = 32'h12345678;	 //at address 256	   (first address)
		memory_array[INSTR_SEGMENT_SIZE+DATA_SEGMENT_SIZE-1] = 32'h67DB5800;	 //at address 511 (last address)

        //Stack segment initialization
      	memory_array[(INSTR_SEGMENT_SIZE + DATA_SEGMENT_SIZE)] = 32'h9ABCDEF0;		 //at address 512 (first address)
		memory_array[(INSTR_SEGMENT_SIZE + DATA_SEGMENT_SIZE + STACK_SEGMENT_SIZE -1 )]  = 32'h55BE48F0;		 //at address 767 (last address)
    end
	
    // Memory read and write operations
    always @(posedge clk) begin
        if (memWrite)begin
            // Write operation
            memory_array[address]     <= data_in[31:0];
        end
        if (memRead) begin
            // Read operation
            data_out[31:0] <= memory_array[address];
        end
    end

endmodule


`timescale 1ns / 1ps

module memory_tb;

    // Inputs
    reg clk;
    reg memRead;
    reg memWrite;
    reg [31:0] address;
    reg [31:0] data_in;

    // Outputs
    wire [31:0] data_out;

    // Instantiate the memory module
    memory uut (
        .clk(clk), 
        .memRead(memRead), 
        .memWrite(memWrite), 
        .address(address), 
        .data_in(data_in), 
        .data_out(data_out)
    );

    // Clock generation
    always #5 clk = ~clk;

    // Test sequence
    initial begin
        // Initialize Inputs
        clk = 0;
        memRead = 0;
        memWrite = 0;
        address = 0;
        data_in = 0;

        // Wait for global reset
        #100;

        // Write to Instruction segment
        address = 32'h00000000; // Beginning of instruction segment
        data_in = 32'h00000123; // Example instruction
        memWrite = 1; // Enable write
        #10;
        memWrite = 0; // Disable write
        #10;

        // Read from Instruction segment
        memRead = 1; // Enable read
        #10;
        memRead = 0; // Disable read
        #10;

        // Write to Data segment
        address = 32'd256; // Beginning of data segment (assuming 256 words per segment)
        data_in = 32'h456789AB; // Example data
        memWrite = 1; // Enable write
        #10;
        memWrite = 0; // Disable write
        #10;

        // Read from Data segment
        memRead = 1; // Enable read
        #10;
        memRead = 0; // Disable read
        #10;

        // Write to Stack segment
        address = 32'd512; // Beginning of stack segment (assuming 256 words per segment)
        data_in = 32'hCDEF0123; // Example stack data
        memWrite = 1; // Enable write
        #10;
        memWrite = 0; // Disable write
        #10;

        // Read from Stack segment
        memRead = 1; // Enable read
        #10;
        memRead = 0; // Disable read
        #10;

        // Finish the simulation
        $finish;
    end

    // Monitor
    initial begin
        $monitor("At time %t, address %h, data written %h, data read %h", $time, address, data_in, data_out);
    end

endmodule

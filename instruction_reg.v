`timescale 1ns / 1ps
module instruction_register (  
	input clk,
	input rst,
    input ir_write,             // Control signal to enable writing to the IR
    input [31:0] instruction_in,// 32-bit instruction input
	output reg [31:0] instruction_out,// 32-bit instruction output
    output reg [5:0] opcode,         // 6-bit opcode
    output reg [3:0] rd,             // 4-bit destination register
    output reg [3:0] rs1,            // 4-bit source register 1
    output reg [3:0] rs2,            // 4-bit source register 2 (for R-type)
    output reg [15:0] immediate,     // 16-bit immediate (for I-type)
    output reg [25:0] jump_offset    // 26-bit jump offset (for J-type) and unused for ret instruction  
);
//opcodes for format types
	//parameter r_type = 2'b00, i_type = 2'b01, j_type = 2'b10, s_type = 2'b11;
    // Opcodes for the instruction types
    //R type opcodes
    parameter AND = 6'b000000, ADD = 6'b000001, SUB = 6'b000010;
    
	//I type opcodes
	parameter ANDI = 6'b000011, ADDI = 6'b000100, LW = 6'b000101, LW_POI = 6'b000110, SW = 6'b000111,
	BGT = 6'b001000, BLT = 6'b001001, BEQ = 6'b001010, BNE = 6'b001011;
	
	//j type opcodes 
	parameter JMP = 6'b001100, CALL = 6'b001101, RET = 6'b001110;
	
	//s tepe opcodes 
	parameter PUSH = 6'b001111, POP = 6'b010000;
	
	//wire [1:0] format_type;
	
    always @(posedge  clk) begin	
		if (rst)  
			begin
				opcode <= 6'd0;
				rd <= 4'd0;
				rs1 <= 2'd0;
				rs2 <= 4'd0;
				immediate <= 16'd0;
				jump_offset <= 26'd0;
				
			end
			
		else if(ir_write == 1) begin
			//r type --> 6-op,4-rd,4-rs1,4-rs2,14-unused
			if((instruction_in[31:26] == AND) || (instruction_in[31:26] == ADD) || (instruction_in[31:26] == SUB))
				begin
				 opcode <= instruction_in[31:26];
				 rd <= instruction_in[25:22];
				 rs1 <= instruction_in[21:18];
				 rs2 <= instruction_in[17:14]; 
				 immediate <= 16'd0;
				 jump_offset <= 26'd0;
			end
			//i type --> 6-op,4-rd,4-rs1,16-imm,2-mode
			else if((instruction_in[31:26] == ANDI) || (instruction_in[31:26] == ADDI) || (instruction_in[31:26] == LW)
				|| (instruction_in[31:26] == LW_POI) || (instruction_in[31:26] == SW) || (instruction_in[31:26] == BGT)
				|| (instruction_in[31:26] == BLT) || (instruction_in[31:26] == BEQ) || (instruction_in[31:26] == BNE))
				begin
				opcode <= instruction_in[31:26];
				rd <= instruction_in[25:22];
				rs1 <= instruction_in[21:18];
				immediate <= instruction_in[17:2]; 
				rs2 <= 4'd0;
				jump_offset <= 26'd0;
			end
			//j type --> 6-op,26-offset or unused
			else if((instruction_in[31:26] == JMP) || (instruction_in[31:26] == CALL) || (instruction_in[31:26] == RET))
				begin
				opcode <= instruction_in[31:26];
				jump_offset <= instruction_in[25:0];  
					rd <= 4'd0;
				rs1 <= 2'd0;
				rs2 <= 4'd0;
				immediate <= 16'd0;
			end
			//s type --> 6-op,4-rd,22-unused
			else if((instruction_in[31:26] == PUSH) || (instruction_in[31:26] == POP))
				begin
				opcode = instruction_in[31:26];
				rd = instruction_in[25:22];	 
					rs1 <= 2'd0;
				rs2 <= 4'd0;
				immediate <= 16'd0;
				jump_offset <= 26'd0;
	
			end
		
		  instruction_out <= instruction_in;
		end	//end larg if
		
    end //end always
endmodule


// Test Bench for instruction_register
module instruction_register_tb;
    
    // Inputs to the instruction_register
    reg clk ;
	reg rst ; 
	reg ir_write;
    reg [31:0] instruction_in;
	
    
    // Outputs from the instruction_register
	wire [31:0] instruction_out;
    wire [5:0] opcode;
    wire [3:0] rd;
    wire [3:0] rs1;
    wire [3:0] rs2;
    wire [15:0] immediate;
    wire [25:0] jump_offset;

    
    // Instantiate the instruction_register
    instruction_register uut (	
	.clk(clk),
	.rst(rst),
        .ir_write(ir_write),
        .instruction_in(instruction_in),
		.instruction_out(instruction_out),
        .opcode(opcode),
        .rd(rd),
        .rs1(rs1),
        .rs2(rs2),
        .immediate(immediate),
        .jump_offset(jump_offset)
    );
    
// Clock generation
	initial begin
	clk = 0;
	forever #5 clk = ~clk; // Generate a clock with a period of 10 time units
	end
		
    initial begin
        // Initialize inputs
        ir_write = 0;	
		rst = 1;
        instruction_in = 32'd0;
	 
        
        // Wait for the global reset
        #100;
         rst = 0;
		 ir_write = 1;	
        // Test R-type instruction (e.g., ADD)
     
        instruction_in = {6'b000001, 4'd2, 4'd3, 4'd4, 14'd0}; // ADD Rd=2, Rs1=3, Rs2=4
        #10; // Wait for instruction to be written
        
        // Test I-type instruction (e.g., ADDI)
        instruction_in = {6'b000100, 4'd5, 4'd6, 16'd10, 2'b01}; // ADDI Rd=5, Rs1=6, Imm=10, Mode=01
        #10; // Wait for instruction to be written
        
        // Test J-type instruction (e.g., JMP)
        instruction_in = {6'b001100, 26'd15}; // JMP Jump_Offset=15
        #10; // Wait for instruction to be written
        
        // Test S-type instruction (e.g., PUSH)
        instruction_in = {6'b001111, 4'd7, 22'd0}; // PUSH Rd=7
        #10; // Wait for instruction to be written
        
        // Finish the simulation
        $finish;
    end
    
    // Monitor changes in the outputs
    initial begin
        $monitor("At time %t, Opcode: %b, Rd: %d, Rs1: %d, Rs2: %d, Immediate: %d,  Jump_Offset: %d",
                 $time, opcode, rd, rs1, rs2, immediate,  jump_offset);
    end
endmodule

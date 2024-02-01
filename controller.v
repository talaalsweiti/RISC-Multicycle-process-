module controller(
	input clk,
	input rst,
	input [5:0]	op_code,
	output  [1:0] IorD,
	output  MemRead,  
	output  MemWrite,
	output  IRWrite,
	output  ReadDest,
	output  MemtoReg,
	output  RegWrite1,
	output  RegWrite2,
	output  ALUSrcA, 
	output  [1:0] ALUSrcB, 
	output  [1:0] ALUOp,
	output [1:0] PCSource,
	output  SignSig ,
	output  StackSig,
	output  DataWrite , 
	output PCWrite     ,
	output   PCWriteCond,
	output   BLTCond,
	output   BGTCond,  
	output ALUZeroCond,
	output reg [4:0] State);	   	 

//op_code[1:0] 
// create a dictionary here for readability
parameter R_TYPE_ADD  = 6'b000000;	   
parameter R_TYPE_AND  = 6'b000001;		
parameter R_TYPE_SUB  = 6'b000010;		 
parameter ANDI        = 6'b000011;		  
parameter ADDI        = 6'b000100;		   
parameter LW          = 6'b000101;			
parameter LW_POI      = 6'b000110;			 
parameter SW          = 6'b000111;			  
parameter BRANCH_MASK = 4'b0010;			   				   
parameter J         = 6'b001100;					
parameter CALL        = 6'b001101;					   
parameter RET         = 6'b001110;						 
parameter PUSH        = 6'b001111;						   
parameter POP         = 6'b100000;							 

parameter BGT = 2'b00;
parameter BLT = 2'b01;
parameter BEQ = 2'b10;
parameter BNQ = 2'b11; 

  initial begin 
  State <= 5'd0;
end 

  always @(posedge clk)
		begin
		if (rst)
			begin
			State <= 5'd0;
			end
		else
			begin
			case (State)
				5'd0:
					#5 State <= 5'd1;
				5'd1:
					// most of the work is done here
					if (op_code == R_TYPE_ADD || op_code == R_TYPE_AND || op_code == R_TYPE_SUB)
						State <= 5'd2;
					else if (op_code == ADDI)
						State <= 5'd4;
					else if (op_code == ANDI)
						State <= 5'd5;
					else if (op_code == LW || op_code==SW || op_code==LW_POI)
						State <= 5'd6;
					else if (op_code[5:2] == BRANCH_MASK)
						if(op_code[1:0]==BGT)
							State <= 5'd11;
						else if(op_code[1:0]==BLT) 
							State <= 5'd12;
						else if(op_code[1:0] == BEQ)
							State <= 5'd13;
						else 
							State <= 5'd14;
							
					else if (op_code == J)
						State <= 5'd15;
					else if (op_code == CALL)
						State <= 5'd22;
					else if (op_code == RET)
						State <= 5'd18;
					else if (op_code == PUSH)
						State <= 5'd16;
					else if (op_code == POP)
						State <= 5'd20;
					// if we have a bad opcode go back to State 1
					else
						State <= 5'd0;	   
						
						
				5'd2:
                  	State <= 4'd3;
                  
              5'd4:
                	State <= 4'd3;
                
              5'd5:
					State <= 4'd3;
				
				5'd6:
				if(op_code==SW)
					State <= 5'd7;
				else
					State <= 5'd8;	
				
				5'd8:
				if(op_code==LW)
					State <= 5'd9;
				else
					State <= 5'd10;	
					
				5'd16:
					 State <= 5'd17;
					 
				5'd18:
					State <= 5'd19;
				5'd20:
					State <= 5'd21;	
				5'd22:
					State <= 5'd23;
			
				default:
					State <= 5'd0;
			endcase
			end
		end	
		
		
  		assign PCWrite= (rst == 1'b1) ? 1'b0 : 	( ((State == 5'd15) || (State == 5'd0) || (State == 5'd22) || (State == 5'd19)) ? 1'b1 : 1'b0 );
		assign IorD = (rst == 1'b1)	? 2'b00	: (((State == 5'd7) || (State == 5'd8)) ? 2'b10 : ((State == 5'd17) || (State == 5'd18)|| (State == 5'd20)|| (State == 5'd23)) ? 2'b01: 2'b00);
		assign MemRead = (rst == 1'b1) ? 1'b0:	(((State == 5'd0) || (State == 5'd18) || (State == 5'd20) || (State == 5'd8) ) ?  1'b1 : 1'b0);
  
		assign MemWrite = (rst == 1'b1)? 1'b0:	 ((( State == 5'd7) || (State == 5'd23)  || (State == 5'd21)  || (State == 5'd19) || (State == 5'd17) )? 1'b1 : 1'b0);
  
  		assign IRWrite = (rst == 1'b1)? 1'b0 : ((State == 5'd0) ? 1'b1 : 1'b0);
		assign ReadDest = (rst == 1'b1)? 1'b0 :  ((State == 5'd2) ? 1'b1 : 1'b0);   
		assign MemtoReg = (rst == 1'b1)	? 1'b0 :  ( (State == 5'd3) ? 1'b1 : 1'b0);   
		assign RegWrite1 = (rst == 1'b1) ? 1'b0 :  (( (State == 5'd3) || (State == 5'd9) || (State == 5'd10) || (State == 5'd21)) ? 1'b1 : 1'b0);   
		assign RegWrite2 = (rst == 1'b1) ? 1'b0 : ((State == 5'd10) ? 1'b1 : 1'b0);	  
		
		assign ALUSrcA = (rst == 1'b1) ? 1'b0 : (( (State == 5'd0) || (State == 5'd1) || (State == 5'd22) ) ? 1'b0 : 1'b1); 
		
		assign ALUSrcB = (rst == 1'b1) ? 2'b00 : ( (State == 5'd1) ?  2'b11 : ((State == 5'd4) || (State == 5'd5) || (State == 5'd6)) ? 2'b10 : ((State == 5'd0) ||(State == 5'd22) ) ? 2'b01 : 2'b00  ); 
		
		assign ALUOp = (rst == 1'b1) ? 2'b00 :  ( (State == 5'd5) ? 2'b00 : ((State==5'd11)||(State==5'd12)||(State==5'd13)||(State==5'd14)) ? 2'b10  : (State==5'd2)  ? op_code[1:0] : 2'b01  ) ;
	
  		assign PCSource = (rst == 1'b1) ? 2'b00	: ( (State == 5'd0)? 2'b10 :( (State==5'd11) ||  (State==5'd12) ||  (State==5'd13) ||  (State==5'd14)) ? 2'b11  : ((State==5'd22) ||  (State==5'd15))? 2'b01 : 2'b00  );	   
		
		assign SignSig = (rst == 1'b1) ? 1'b0 : (  ( (State == 5'd1) || (State == 5'd4) || (State == 5'd6) )  ? 1'b1  : 1'b0 );	
		
		assign StackSig = (rst == 1'b1) ? 1'b0 : ( ((State == 5'd23) || (State == 5'd16) ) ? 1'b1  : 1'b0);	
		
		assign DataWrite = (rst == 1'b1) ? 1'b0 : ( (State == 5'd23) ? 1'b0  : 1'b1);	
		
		assign   PCWriteCond = (rst == 1'b1) ? 1'b0 : ( ((State == 5'd13) || (State == 5'd14))? 1'b1  : 1'b0);		
		
		assign   BLTCond = (rst == 1'b1) ? 1'b0 : ((State == 5'd12) ? 1'b1  : 1'b0);	
		assign   BGTCond  = (rst == 1'b1) ? 1'b0 : ((State == 5'd11) ? 1'b1  : 1'b0);	
		assign ALUZeroCond   = (rst == 1'b1) ? 1'b0 : ((State == 5'd13) ? 1'b1  : 1'b0);	
		

		
		

	endmodule		
	
	
	
	`timescale 1ns/1ns

module tb_controller;

  // Inputs and outputs
  reg clk;
  reg rst;
  reg [5:0] op_code;
  wire [1:0] IorD;
  wire MemRead;
  wire MemWrite;
  wire IRWrite;
  wire ReadDest;
  wire MemtoReg;
  wire RegWrite1;
  wire RegWrite2;
  wire ALUSrcA;
  wire [1:0] ALUSrcB;
  wire [1:0] ALUOp;
  wire [1:0] PCSource;
  wire SignSig;
  wire StackSig;
  wire DataWrite;
  wire PCWrite;
  wire PCWriteCond;
  wire BLTCond;
  wire BGTCond;
  wire ALUZeroCond;
  reg [4:0] State;

  // Instantiate the controller module
  controller uut(
    .clk(clk),
    .rst(rst),
    .op_code(op_code),
    .IorD(IorD),
    .MemRead(MemRead),
    .MemWrite(MemWrite),
    .IRWrite(IRWrite),
    .ReadDest(ReadDest),
    .MemtoReg(MemtoReg),
    .RegWrite1(RegWrite1),
    .RegWrite2(RegWrite2),
    .ALUSrcA(ALUSrcA),
    .ALUSrcB(ALUSrcB),
    .ALUOp(ALUOp),
    .PCSource(PCSource),
    .SignSig(SignSig),
    .StackSig(StackSig),
    .DataWrite(DataWrite),
    .PCWrite(PCWrite),
    .PCWriteCond(PCWriteCond),
    .BLTCond(BLTCond),
    .BGTCond(BGTCond),
    .ALUZeroCond(ALUZeroCond),
    .State(State)
  );

  // Clock generation
  initial begin
    clk = 0;
    forever #5 clk = ~clk;
  end

  // Initializations
  initial begin
    rst = 1;
    //op_code = 6'b000000; // Initial opcode
    #10 rst = 0; // Release reset after 10 time units

    // Test Case 1: R_TYPE_ADD
    op_code = 6'b000000;
    #35;
    
    // Test Case 2: ADDI
    op_code = 6'b000101;
    #50;
    
    // Add more test cases as needed

    // End simulation
    #20 $finish;
  end

endmodule

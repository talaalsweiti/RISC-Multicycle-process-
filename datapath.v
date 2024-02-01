module datapath(
		input clk,
		input rst,
		output [4:0] State
 );
 						    
 	wire   [1:0] IorD;
	wire   MemRead; 
	wire   MemWrite;
	wire   IRWrite;
	wire   ReadDest;
	wire   MemtoReg;
	wire   RegWrite1;
	wire   RegWrite2;
	wire   ALUSrcA;
	wire   [1:0] ALUSrcB; 
	wire   [1:0] ALUOp;
	wire  [1:0] PCSource;
	wire   SignSig ;
	wire   StackSig;
	wire   DataWrite ; 
	wire  PCWrite    ;
	wire    PCWriteCond;
	wire    BLTCond;
	wire    BGTCond;
	wire  ALUZeroCond;	   
	wire PCWrite_Final;
 	
	
		
	wire [31:0] PC_IN;
	wire [31:0] PC_OUT;
	
	
  pc pc_reg(
		.clk(clk),
		.rst(rst),
		.new_pc(PC_IN),
		.PCWrite(PCWrite_Final),				// CTRL
		.PC(PC_OUT)
	); 
	
	
	wire [31:0] SP_OUT;
	
	sp sp_reg(
	.clk(clk), 
	.rst(rst),
	.stack_sig(StackSig) ,
	.SP_OUT(SP_OUT)
	);
 
	wire [31:0] address_to_memory;
	
		
	wire [31:0] REG_ALU_OUT;
		
	wire [31:0] ALU_OUT; 
	
	mux_3x1 IOR_mux(
		.out(address_to_memory),
		.select(IorD),
		.in0(PC_OUT),
		.in1(SP_OUT),
		.in2(REG_ALU_OUT)
	
	);
	wire [31:0] memory_out;
	wire [31:0] data_to_write_in_memory;
	
	 mux_2x1 data_write_mux(
		.out(data_to_write_in_memory),
		.select(DataWrite),
		.in0(rd),
		.in1(ALU_OUT) 
	
	);
	
	memory main_memory(
    .clk(clk),                
    .memRead(MemRead),            
    .memWrite(MemWrite),          
    .address(address_to_memory),      
    .data_in(data_to_write_in_memory),      
    .data_out(memory_out)     
);


	reg_alu_out ALUOut(
		.clk(clk),
		.rst(rst),
		.ALUIn(ALU_OUT),
		.ALUOut(REG_ALU_OUT)
	);
	
 wire [5:0] opcode;
 wire [3:0] rd;	
 wire [3:0] rs1;
 wire [3:0] rs2;
 wire [15:0] immediate;
 wire [25:0]jump_offset;
 wire [31:0] instruction_out;
 
 instruction_register IR(  
	.clk(clk),
	.rst(rst),
    .ir_write(IRWrite),              
    .instruction_in(memory_out),
	.instruction_out(instruction_out), 
    .opcode(opcode),         
    .rd(rd),             
    .rs1(rs1),          
    .rs2(rs2),            
    .immediate(immediate),    
   .jump_offset(jump_offset)    
);
	

 wire [31:0] MDR_out;
 

Memory_Data_Register MDR(
    .clock(clk),
	.rst(rst),
    .data_in(memory_out),
    .data_out(MDR_out)
);

wire [3:0] RA2;
 mux_2x1 RA2_mux(
		.out(RA2),
		.select(ReadDest),
		.in0(rd),
		 .in1(rs2)
	);

wire [31:0] rs_plus_one;	
	adder rs_adder(
	.in1(32'd1),
	.in2(rs1),
	.out(rs_plus_one))	;
	
	
wire [31:0] Bus_W1;	

mux_2x1 Bus_W1_mux(
		.out(Bus_W1),
		.select(MemtoReg),
		.in0(MDR_out),
		.in1(REG_ALU_OUT)
	);	 
	
wire [31:0] Bus_A;
wire [31:0] Bus_B;

register_file RF(
    .clk(clk),
    .RA1(rs1), 
	.RA2(RA2), 
    .RW1(rd),
	.RW2(rs1),
    .RegWrite1(RegWrite1), 
	.RegWrite2(RegWrite2),  
    .Bus_W1(Bus_W1),
	.Bus_W2(rs_plus_one),
    .Bus_A1(Bus_A), 
	.Bus_A2(Bus_B)  
);	 

wire [31:0] SRC_A;	
wire [31:0] SRC_B; 

wire [31:0] imm_32;

wire [31:0] shift_imm_32;

Extender extender(
    .imm16(immediate),
    .ExtOp(SignSig),
    .imm32(imm_32)
);

left_shift_two ls(
.in_data(imm_32),
.out_data(shift_imm_32));

mux_2x1 Src_A_mux(
		.out(SRC_A),
		.select(ALUSrcA),
		.in0(A_to_Mux_ReadDataA),
		.in1(PC_OUT)
	);	

wire [31:0] A_to_Mux_ReadDataA;
  wire [31:0] B_to_Mux_ReadDataB;

 mux_4x1 Src_B_mux(
		.out(SRC_B),
		.select(ALUSrcB),
		.in0(B_to_Mux_ReadDataB),
   .in1(32'd1),
		.in2(imm_32),
		.in3(shift_imm_32)
	);
	
	reg_read_data A(
		.clk(clk),
		.rst(rst),
		.readIn(Bus_A),
		.readOut(A_to_Mux_ReadDataA)
	);
	
	reg_read_data B(
		.clk(clk),
		.rst(rst),
      .readIn(Bus_B),
		.readOut(B_to_Mux_ReadDataB)
	);
  
  
  
	
wire carry , zero, negative , overflow;	
ALU alu(
    .A(SRC_A),
    .B(SRC_B),
    .opcode(ALUOp),
   	.result(ALU_OUT),
    .carry(carry),
    .zero(zero),
    .negative(negative),
    .overflow(overflow)
);


 mux_4x1 pc_source_mux(
		.out(PC_IN),
		.select(PCSource),
		.in0(memory_out),
		.in1({PC_OUT[31:26],jump_offset}),
		.in2(ALU_OUT),
		.in3(REG_ALU_OUT)
	);

  	wire AND_BLTCond_to_OR;	
	wire AND_BGTCond_to_OR;
	wire not_negative;  
	wire XOR_ALUZeroCond_to_AND;
	wire AND_ALUZeroCond_to_OR;
	
	and  and1  (AND_BLTCond_to_OR,      negative,   BLTCond);  
	not  not1(not_negative,negative);
	and  and2  (AND_BGTCond_to_OR,      not_negative,   BGTCond); 
	
	xnor xnor1 (XOR_ALUZeroCond_to_AND, zero,    ALUZeroCond);
	
	and  and3  (AND_ALUZeroCond_to_OR,  XOR_ALUZeroCond_to_AND, PCWriteCond);
	or   or1   (PCWrite_Final, PCWrite, AND_ALUZeroCond_to_OR,  AND_BLTCond_to_OR,AND_BGTCond_to_OR);

 
	controller CTRL(
		.clk(clk),
		.rst(rst),
		.op_code(opcode), 
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
		.DataWrite(DataWrite) , 
		.PCWrite(PCWrite)     ,
		.PCWriteCond(PCWriteCond),
		.BLTCond(BLTCond),
		.BGTCond(BGTCond),
		.ALUZeroCond(ALUZeroCond),
		.State(State)
	);
	
	


 endmodule
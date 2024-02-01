 module control_unit(clk,next_state,op_code,mode,zero_flg,negative_flg,
	  IorD, MemRead,  
	MemWrite, IRWrite,
	ReadDest, MemtoReg,
	RegWrite1, RegWrite2,
	ALUSrcA, ALUSrcB, ALUOp,
	PCSource, SignSig
	StackSig, DataWrite , pcsig);	   	 

// next_state may be needed as input
input clk; 
input [2:0] next_state; //IF , ID , EX , MEM, WB
input zero_flg;	// to check if branch
input negative_flg ;	// to check if branch
input [5:0]	op_code;  // instruction type 
input [1:0] mode; // for POI in load

// determine if we should write on the PC with branch value	

wire PCWriteCond;

// to write new PC value
 wire PCWrite;

// instruction or data
output reg [1:0] IorD;

output reg  pcsig	= 0; 

output reg MemRead = 0 , MemWrite = 0 ;

//determine if the output of the memory is written into the Instruction Register
output reg IRWrite =0 ;	

// choose between rd or rs2 
output reg ReadDest; 

// choose write port to the IR
output reg MemtoReg; 

// if 1 = write on IR 
output reg RegWrite1 = 0; 

// only 1 if we have LW.POI
output reg RegWrite2 = 0;

output reg ALUSrcA;
output reg [1:0]ALUSrcB;

output reg [1:0]ALUOp;

output reg[1:0]PCSource = 2'b10;  
// if 1 = signed extened
output reg SignSig;	

// 1 = push , 0 = pop
output reg StackSig;  

// determine the data written to the memory
output reg DataWrite;					

//ALU OPERATIONS 
parameter ADD = 0;
parameter SUB = 1;
parameter AND = 2;
	

parameter IF_STAGE = 'b000;
parameter ID_STAGE = 'b001;
parameter EX_STAGE = 'b010;
parameter MEM_STAGE ='b011;
parameter WB_STAGE = 'b100;

// Main control signals
// 
always@ (negedge clk) begin	 
	casex (op_code)
		6'b000000: begin	// R-type and
			
			//RegWrite2<=0;
			IorD <= 00;
			//MemRead <=0;
			//MemWrite <=0 ;
			IRWrite <= 1;
			ReadDest <= 1;
			
			if(next_state==4) begin 
				RegWrite1<=1;  
				MemtoReg <= 1; 
			end	
		else begin
				RegWrite1<=0;  
			end
			
		end
		
		
		6'b000001: begin // R-type add
			RegWrite1<=1;
			IorD <= 00;
			//RegWrite2<=0;
			//MemRead <=0;
			//MemWrite <=0 ;
				  
			ReadDest <= 1;
			//MemtoReg <= 1; 
			
			if(next_state==4) begin 
				RegWrite1<=1;  
				MemtoReg <= 1; 
			
			end	
			else begin
				RegWrite1<=0;
			
			end	  
			
			
		end
		
		6'b000010: begin  // R-type sub
			
			//RegWrite2<=0;
			IorD <= 00;
			//MemRead <=0;
			//MemWrite <=0 ;
			
			ReadDest <= 1;
			//MemtoReg <= 1;  
			if(next_state==4) begin 
				RegWrite1<=1;  
				MemtoReg <= 1; 
			
			end	
			else begin
				RegWrite1<=0;
			
			end	 
		end
		
		6'b000011: begin  // ANDI
			
			//RegWrite2<=0;
			IorD <= 00;
			//MemRead <=0;
			//MemWrite <=0 ;
			//IRWrite <= 1;
			//MemtoReg <= 1;	
			SignSig <=0;
			
			if(next_state==4) begin 
				RegWrite1<=1;  
				MemtoReg <= 1; 
			
			end	
			else begin
				RegWrite1<=0;
			
			end	 
		end
		
		6'b000100: begin  /// ADDI
			 
			//RegWrite2<=0;
			IorD <= 00;
			//MemRead <=0;
			//MemWrite <=0 ;
			//IRWrite <= 1;
			//MemtoReg <= 1;	
			SignSig < =1;
			
				
			if(next_state==4) begin 
				RegWrite1<=1;  
				MemtoReg <= 1; 
			
			end	
			else begin
				RegWrite1<=0;
			
			end	 
		end
		
		6'b000101: begin  // LW
			
			//RegWrite2<=0;
			IorD <= 10;
			MemRead <=1;
			//MemWrite <=0 ;
			//IRWrite <= 0;
		
			//MemtoReg <= 0;	
			SignSig <= 1;
			if(next_state==4) begin 
				RegWrite1<=1;  
				MemtoReg <= 0; 
			
			end	
			else begin
				RegWrite1<=0;
			
			end	 
		end
		
		6'b000110: begin //	LW.POI
			//RegWrite1<= 1;
			
			IorD <= 10;
			MemRead <= 1;
			//MemWrite <=0 ;
			//IRWrite <= 0;
			//MemtoReg <= 0;	
			SignSig <= 1;
			
			if(next_state==4) begin 
				RegWrite1<=1;  
				MemtoReg <= 0; 
				RegWrite2<= 1;
			
			end	
			else begin
				RegWrite1<=0;
				RegWrite2<= 0;
			
			end	
			
		end
		
		6'b000111: begin  // SW
			
			IorD <= 10;
		
			SignSig <= 1;
			
			if(next_state==3) begin
				MemWrite <= 1;
				DataWrite <= 1;
				
			end
		else
			begin
				MemWrite <= 0;
				
			end
			
		end
		
		6'b0010??: begin //	   BRANCH
			//RegWrite1<= 0;
			//RegWrite2<= 0;
			IorD <= 00;
			//MemRead <= 0;
			//MemWrite <= 0;
			ReadDest <= 0;
		end	  
			
		6'b001100: begin  // JMP
			//RegWrite1<= 0;
			//RegWrite2<= 0;
			IorD <= 00;
			//MemRead <= 0;
			//MemWrite <= 0;
			//IRWrite <= 0;
		end
			
		6'b001101: begin  // CALL
			//RegWrite1<= 0;
			//RegWrite2<= 0;
			IorD <= 01;	   
			StackSig <= 1;	
				//IRWrite <= 0;
			///MemRead <= 0;
			if(next_state==3) begin
				MemWrite <= 1;	 
				DataWrite <= 0;
			end
		else	  
			MemWrite <= 0;
		end
		
			
		
			
		end
		
		6'b001110: begin  // RET
			//RegWrite1<= 0;
			//RegWrite2<= 0;
			IorD <= 01;
			//MemRead <= 0;
			
			StackSig <= 0;
			if(next_state==3) begin
				  MemWrite <= 1;
			end
		else
			  	MemWrite <= 0;
			end
			
			
		end
		
		6'b001111: begin  // PUSH
			
			IorD <= 01;
			
			StackSig <= 1;
			
			ReadDest <= 0;
			 
		
			if(next_state==3) begin
			  MemWrite <= 1;
			  DataWrite <= 1;
			end
			else
				  MemWrite <= 0;
				end
			
		end
		
		6'b010000: begin  // POP
			
		
			IorD <= 01;
		
			StackSig <= 0;
			if(next_state==3) begin
				MemWrite <= 1;
			end
			else
			  MemWrite <= 0;
			end	
			
			if(next_state==4) begin
				RegWrite1 <= 1;
			end
			else
			  RegWrite1 <= 0;
			end
			
		end
		
	endcase	
	
end


// PC control
  always @(negedge clk) begin
  
    
    if(next_state == IF_STAGE)	begin
    casex (op_code)
        6'b001110: begin // RET
            PCWrite <= 1;
            PCWriteCond <= 0; 
			pcsig <= (PCWrite || PCWriteCond);
            PCSource <= 2'b00;
        end
        6'b001100: begin // JMP
            PCWrite <= 1;
            PCWriteCond <= 0; 
			pcsig <= (PCWrite || PCWriteCond);
            PCSource <= 2'b01;
        end
        6'b001101: begin // CALL
            PCWrite <= 1;
            PCWriteCond <= 0;
			pcsig <= (PCWrite || PCWriteCond);
            PCSource <= 2'b01;
        end
        6'b001010: begin // BEQ
            PCWrite <= 0;
            PCWriteCond <= 1;
            pcsig <= (PCWrite || (PCWriteCond && zero_flg));
            PCSource <= pcsig ? 2'b11 : 2'b10;
        end
        6'b001011: begin // BNE
            PCWrite <= 0;
            PCWriteCond <= 1;
            pcsig <= (PCWrite || (PCWriteCond && !zero_flg));
            PCSource <= pcsig ? 2'b11 : 2'b10;
        end
        6'b001000: begin // BGT
            PCWrite <= 0;
            PCWriteCond <= 1;
            pcsig <= (PCWrite || (PCWriteCond && !zero_flg && !negative_flg));
            PCSource <= pcsig ? 2'b11 : 2'b10;
        end
        6'b001001: begin // BLT
            PCWrite <= 0;
            PCWriteCond <= 1;
            pcsig <= (PCWrite || (PCWriteCond && !zero_flg && negative_flg));
            PCSource <= pcsig ? 2'b11 : 2'b10;
        end
        
    endcase
	
	end
    
end
			
			
// ALU control signal 	
  always @(posedge clk,op_code) begin
		casex(op_code)
			6'b000000: begin // AND	
				ALUSrcA <= 1;
				ALUSrcB <= 00;
				ALUOp <= AND;
			end	 
			
			6'b000001: begin // ADD
				ALUSrcA <= 1;
				ALUSrcB <= 00;
				ALUOp <= ADD;
			end
			
			6'b000010: begin // SUB
				ALUSrcA <= 1;
				ALUSrcB <= 00;
				ALUOp <= SUB;
			end
			
			6'b000011: begin // ANDI
				ALUSrcA <= 1;
				ALUSrcB <= 10;
				ALUOp <= AND;
			end
			
			6'b000100: begin // ADDI
				ALUSrcA <= 1;
				ALUSrcB <= 10;
				ALUOp <= ADD;
			end
			
			6'b000101: begin // LW
				ALUSrcA <= 1;
				ALUSrcB <= 10;
				ALUOp <= ADD;
			end	
			
			6'b000110: begin // LW.poi
				ALUSrcA <= 1;
				ALUSrcB <= 10;
				ALUOp <= ADD;
			end
			
			6'b000111: begin // SW
				ALUSrcA <= 1;
				ALUSrcB <= 10;
				ALUOp <= ADD;
			end
          
          	6'b0010??: begin // BRANCH
				ALUSrcA <= 1;
				ALUSrcB <= 00;
				ALUOp <= SUB;
			end	
			
			6'b001101: begin // CALL
				ALUSrcA <= 0;
				ALUSrcB <= 01;
				ALUOp <= ADD;
			end	
			
		endcase
		
	end
 










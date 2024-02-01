// `timescale 1ns / 1ps


module datapath_tb;

	// Inputs
  reg clk ,rst;
  wire [4:0] state;
 
  datapath dut(.clk(clk) , .rst(rst),.State(state) );	 
 
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

  end

   /*
    initial begin 
    $dumpfile("dump.vcd"); 
    $dumpvars;
    #2000
    $finish ; 
    end   */
	
      
endmodule
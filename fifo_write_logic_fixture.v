// fifo_write_logic_fixture.v
// Author: Vladislav Rykov

`include "fifo_write_logic.v"

`define CLK_1     5 // for test ease

`define PTR_SZ 	  2

module fifo_write_logic_fixture;
  reg clk1, rst;

  reg winc;
  reg [`PTR_SZ:0] rq2_raddr;
  wire [(`PTR_SZ-1):0] waddr;
  wire [`PTR_SZ:0] waddr_gray;
  wire wfull, write_en;

  reg [(4-1):0] i, k;
  reg [8:0] j;

  
  fifo_write_logic #(.PTR_SZ(`PTR_SZ)) fwl (.clk(clk1), .rst(rst), .winc(winc), .rq2_raddr(rq2_raddr), .wfull(wfull), .write_en(write_en), .waddr(waddr), .waddr_gray(waddr_gray));

  initial begin
   fork
     begin: clock_1_thread
       clk1 = 1'b0;
       forever #`CLK_1 clk1 =~ clk1;
     end
     begin: stimulus_thread
       rst = 0; winc = 0; rq2_raddr = 0;
       // packet 1
       #`CLK_1 rst = 1;
       #(`CLK_1*2) winc = 1;
       #`CLK_1 winc = 0;
       #`CLK_1 winc = 1;
       #`CLK_1 winc = 0;
       #`CLK_1 winc = 1;
       #`CLK_1 winc = 0;
       $display("no reaction at winc toggle");
       #`CLK_1 winc = 1;
       #`CLK_1 winc = 0;
       #(`CLK_1*2) rq2_raddr = 1;
       #(`CLK_1*2) winc = 1;
       #`CLK_1 winc = 0;
       #(`CLK_1*3) rq2_raddr = 0;
       #`CLK_1 winc = 1;
       #`CLK_1 winc = 0;
       #`CLK_1 winc = 1;
       #`CLK_1 winc = 0;
    
     end
     begin: dve_thread
       $vcdpluson;
     end
     begin: ending_thread
       #(24*`CLK_1) disable clock_1_thread; disable stimulus_thread; disable dve_thread;
     end
   join
   $finish;
  end
  
  initial
    $monitor("Time %3d, clk = %b rst = %b, winc = %d, rq2_raddr = %d, wfull = %d, write_en = %d, waddr = %d, waddr_gray = %d", $time, clk1, rst, fwl.winc, fwl.rq2_raddr, fwl.wfull, fwl.write_en, fwl.waddr, fwl.waddr_gray);

endmodule

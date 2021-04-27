// fifo_read_logic_fixture.v
// Author: Vladislav Rykov

`include "fifo_read_logic.v"

`define CLK_1     5 // for test ease
`define PTR_SZ 	  2

module fifo_write_logic_fixture;
  reg clk1, rst;

  reg rinc;
  reg [`PTR_SZ:0] waddr;
  wire [`PTR_SZ:0] rq2_waddr;
  assign rq2_waddr = (waddr >> 1) ^ waddr;
  wire [(`PTR_SZ-1):0] raddr;
  wire [`PTR_SZ:0] raddr_gray;
  wire rempty, read_en;

  reg [(4-1):0] i, k;
  reg [8:0] j;

  
  fifo_read_logic #(.PTR_SZ(`PTR_SZ)) frl (.clk(clk1), .rst(rst), .rinc(rinc), .rq2_waddr(rq2_waddr), .rempty(rempty), .read_en(read_en), .raddr(raddr), .raddr_gray(raddr_gray));

  initial begin
   fork
     begin: clock_1_thread
       clk1 = 1'b0;
       forever #`CLK_1 clk1 =~ clk1;
     end
     begin: stimulus_thread
       rst = 0; rinc = 0; waddr = 3;
       // packet 1
       #`CLK_1 rst = 1;
       #(`CLK_1*2) rinc = 1;
       #`CLK_1 rinc = 0;
       #`CLK_1 rinc = 1;
       #`CLK_1 rinc = 0;
       #`CLK_1 rinc = 1;
       #`CLK_1 rinc = 0;
       $display("no reaction at winc toggle");
       #`CLK_1 rinc = 1;
       #`CLK_1 rinc = 0;
       #`CLK_1 waddr = 3;
       #(`CLK_1*2) rinc = 1;
       #`CLK_1 rinc = 0;
       #`CLK_1 waddr = 0;
       #`CLK_1 rinc = 1;
       #`CLK_1 rinc = 0;
       #`CLK_1 rinc = 1;
       #`CLK_1 rinc = 0;
       #`CLK_1 rinc = 1;
       #`CLK_1 rinc = 0;
       #`CLK_1 rinc = 1;
       #`CLK_1 rinc = 0;
       #`CLK_1 rinc = 1;
       #`CLK_1 rinc = 0;
     end
     begin: dve_thread
       $vcdpluson;
     end
     begin: ending_thread
       #(28*`CLK_1) disable clock_1_thread; disable stimulus_thread; disable dve_thread;
     end
   join
   $finish;
  end
  
  initial
    $monitor("Time %3d, clk = %b rst = %b, rinc = %d, waddr = %d rq2_waddr = %d, rempty = %d, read_en = %d, raddr = %d, rgray = %d", $time, clk1, rst, frl.rinc, waddr, frl.rq2_waddr, frl.rempty, frl.read_en, frl.raddr, frl.raddr_gray);
    //$monitor("Time %3d, clk = %b rst = %b, cs = %d, ns = %d, rinc = %d, waddr = %d rq2_waddr = %d, rempty = %d, read_en = %d, raddr = %d, rgray = %d", $time, clk1, rst, frl.current_state, frl.next_state, frl.rinc, waddr, frl.rq2_waddr, frl.rempty, frl.read_en, frl.raddr, frl.raddr_gray);

endmodule

// fifo_fixture.v
// Author: Vladislav Rykov

`include "fifo.v"

//`define CLK_1     5 // for test ease
`define CLK_1     2 // F=250KHz T=4us
`define CLK_2     5 // F=100KHz T=10us

`define DEPTH     4
`define WIDTH     11
`define UWIDTH    8
`define PTR_SZ 	  2
`define PTR_IN_SZ 4

module fifo_fixture;
  reg clk1, clk2, rst;

  reg winc, rinc;
  reg [(`PTR_IN_SZ-1):0] waddr_in, raddr_in;
  reg [(`UWIDTH-1):0] wdata;
  wire [(`UWIDTH-1):0] rdata;
  wire wfull, rempty;

  reg [(4-1):0] i, k;
  reg [8:0] j;

  fifo #(.DEPTH(`DEPTH), .WIDTH(`WIDTH), .UWIDTH(`UWIDTH), .PTR_SZ(`PTR_SZ), .PTR_IN_SZ(`PTR_IN_SZ)) f (.clk1(clk1), .clk2(clk2), .rst(rst), .winc(winc), .rinc(rinc), .waddr_in(waddr_in), .raddr_in(raddr_in), .wdata(wdata), .rdata(rdata), .wfull(wfull), .rempty(rempty));

  initial begin
   fork
     begin: clock_1_thread
       clk1 = 1'b0;
       forever #`CLK_1 clk1 =~ clk1;
     end
     begin: clock_2_thread
       clk2 = 1'b0;
       forever #`CLK_2 clk2 =~ clk2;
     end
     begin: stimulus_thread
       rst = 0; winc = 0; rinc = 0; waddr_in = 0; raddr_in = 0;
       wdata = 0;
       // packet 1
       #`CLK_1 rst = 1; 
       #(`CLK_1*2) waddr_in = 0; wdata = 10; // source_id
       #`CLK_1 waddr_in = 1; wdata = 160; // dest_id
       #`CLK_1 waddr_in = 2; wdata = 3; // size
       #`CLK_1 waddr_in = 3; wdata = 0; // data 1
       #`CLK_1 waddr_in = 4; wdata = 1; // data 2
       #`CLK_1 waddr_in = 5; wdata = 2; // data 3
       #`CLK_1 waddr_in = 6; wdata = 15; winc = 1; // crc
        
       $display("=======================================packet 1 done");
       // packet 2 
       #`CLK_1 winc = 0; waddr_in = 0; wdata = 100; // source_id
       #`CLK_1 waddr_in = 1; wdata = 10; // dest_id
       #`CLK_1 waddr_in = 2; wdata = 4; // size
       #`CLK_1 waddr_in = 3; wdata = 0; // data 1
       #`CLK_1 waddr_in = 4; wdata = 1; // data 2
       #`CLK_1 waddr_in = 5; wdata = 2; // data 3
       #`CLK_1 waddr_in = 6; wdata = 3; // data 4
       #`CLK_1 waddr_in = 7; wdata = 55; winc = 1; // crc

       $display("=======================================packet 2 done");
       // packet 3
       #`CLK_1 winc = 0; waddr_in = 0; wdata = 255; // source_id
       #`CLK_1 waddr_in = 1; wdata = 63; // dest_id
       #`CLK_1 waddr_in = 2; wdata = 5; // size
       #`CLK_1 waddr_in = 3; wdata = 0; // data 1
       #`CLK_1 waddr_in = 4; wdata = 1; // data 2
       #`CLK_1 waddr_in = 5; wdata = 2; // data 3
       #`CLK_1 waddr_in = 6; wdata = 3; // data 4
       #`CLK_1 waddr_in = 7; wdata = 4; // data 5
       #`CLK_1 waddr_in = 8; wdata = 55; winc = 1; // crc
       
       $display("=======================================packet 3 done");
       // packet 4
       #`CLK_1 winc = 0; waddr_in = 0; wdata = 63; // source_id
       #`CLK_1 waddr_in = 1; wdata = 31; // dest_id
       #`CLK_1 waddr_in = 2; wdata = 6; // size
       #`CLK_1 waddr_in = 3; wdata = 0; // data 1
       #`CLK_1 waddr_in = 4; wdata = 1; // data 2
       #`CLK_1 waddr_in = 5; wdata = 2; // data 3
       #`CLK_1 waddr_in = 6; wdata = 3; // data 4
       #`CLK_1 waddr_in = 7; wdata = 4; // data 5
       #`CLK_1 waddr_in = 8; wdata = 5; // data 5
       #`CLK_1 waddr_in = 9; wdata = 127; winc = 1; // crc
       #`CLK_1 winc = 0; 

       $display("=======================================packet 4 done");
       #`CLK_2 rinc = 1;
       #`CLK_2 rinc = 0;
       #`CLK_2 rinc = 1;
       #`CLK_2 rinc = 0;
       #`CLK_2 rinc = 1;
       #`CLK_2 rinc = 0;
       #`CLK_2 rinc = 1;
       #`CLK_2 rinc = 0;
       #`CLK_2 rinc = 1;
       #`CLK_2 rinc = 0;
     end
     begin: checking_thread
       for (j = 0; j < 52; j = j+1) begin
         // 1. memory dump
         #(`CLK_1) for (i = 0; i < 11; i = i+1) 
                       $display("[0][%d] = %b [1][%d] = %b [2][%d] = %b [3][%d] = %b", i, f.fm.memory[0][i], i, f.fm.memory[1][i], i, f.fm.memory[2][i], i, f.fm.memory[3][i]);
         
         // fifo_write_logic
         $display("Write Logic\nwinc = %d, rq2_raddr = %d, wfull = %d, write_en = %d, waddr = %d, waddr_gray = %d", f.fwl.winc, f.fwl.rq2_raddr, f.fwl.wfull, f.fwl.write_en, f.fwl.waddr, f.fwl.waddr_gray);
                  
         // fifo_read_logic
         $display("Read Logic\nrinc = %d, rq2_waddr = %d, rempty = %d, read_en = %d, raddr = %d, rgray = %d", f.frl.rinc, f.frl.rq2_waddr, f.frl.rempty, f.frl.read_en, f.frl.raddr, f.frl.raddr_gray);
       end
     end
     begin: dve_thread
       $vcdpluson;
     end
     begin: ending_thread
       #(52*`CLK_1) disable clock_1_thread; disable clock_2_thread; disable stimulus_thread; disable checking_thread; disable dve_thread;
     end
   join
   $finish;
  end
  
  initial
    $monitor("Time %d, clk1 = %b, clk2 = %b, rst = %b", $time, clk1, clk2, rst);

endmodule

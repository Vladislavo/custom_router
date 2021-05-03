// synchronizer_fixture.v
// Authors: Vladislav Rykov, Vikas Gundapuneedi

`include "synchronizer.v"

`define CLK_1  10
`define CLK_2  5
`define PTR_SZ 2

module synchronizer_fixture;

  reg  rst;
  reg  clk1, clk2;
  reg  [`PTR_SZ:0] raddr_gray, waddr_gray;
  wire [`PTR_SZ:0] rq2_raddr, rq2_waddr;

  synchronizer #(`PTR_SZ) s (.clk1(clk1), .clk2(clk2), .rst(rst), .waddr_gray(waddr_gray), .raddr_gray(raddr_gray), .rq2_raddr(rq2_raddr), .rq2_waddr(rq2_waddr));

  initial begin
    clk1 = 0;
    forever #`CLK_1 clk1 =~ clk1;
  end

  initial begin
    clk2 = 0;
    forever #`CLK_2 clk2 =~ clk2;
  end


  initial begin
    rst=0; raddr_gray = 0; waddr_gray = 0;
    #`CLK_1; rst=1; raddr_gray = 1; waddr_gray = 7;
    #`CLK_1 raddr_gray = 3; waddr_gray = 5;
    #(`CLK_1*4); rst=1; raddr_gray = 1; waddr_gray = 7;
    #(`CLK_1*4) $finish;
  end 


  initial begin
    $monitor ($time, " clk1=%d, clk2=%d, rst=%d, wgray=%d, rq1w=%d, rq2w=%d, rgray=%d, rq1r=%d, rq2r=%d", clk1, clk2, rst, waddr_gray, s.rq1_waddr, rq2_waddr, raddr_gray, s.rq1_raddr, rq2_raddr);
  end

endmodule

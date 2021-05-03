// synchronizer
// Author: Vladislav Rykov
`include "DFF1.v"

module synchronizer #(parameter PTR_SZ=2)
                     (input clk1, clk2, rst,
                      input [PTR_SZ:0] waddr_gray, raddr_gray,
                      output [PTR_SZ:0] rq2_raddr, rq2_waddr
);
  wire [PTR_SZ:0] rq1_waddr, rq1_raddr;

  DFF1 #(.PTR_SZ(PTR_SZ)) w2rdff1 (.rst(rst), .clk(clk2), .addr_gray(waddr_gray), .rq1_addr(rq1_waddr), .rq2_addr(rq2_waddr));
  DFF1 #(.PTR_SZ(PTR_SZ)) r2wdff1 (.rst(rst), .clk(clk1), .addr_gray(raddr_gray), .rq1_addr(rq1_raddr), .rq2_addr(rq2_raddr));

endmodule


// DFF1.v
// Author: Vikas Gundapuneedi

module DFF1 #(parameter PTR_SZ=2)
             (input  rst,
              input  clk,
              input  [PTR_SZ:0] addr_gray,
              output reg [PTR_SZ:0] rq2_addr, rq1_addr
);
 
 //synchronizing the read pointer into the write clock domain 

  always @(posedge clk or negedge rst)
  begin
    if (!rst) begin
      { rq2_addr, rq1_addr } <= 2'b0;
    end else begin 
      { rq2_addr, rq1_addr } <= { rq1_addr, addr_gray };
    end
  end

endmodule

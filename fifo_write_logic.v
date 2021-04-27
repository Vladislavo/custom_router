// fifo_write_logic.v
// Author: Vladislav Rykov

// PTR_SZ    - FIFO entry index size in bits
module fifo_write_logic #(parameter PTR_SZ = 2)
			 (input clk, rst,
			  input winc,
			  input [PTR_SZ:0] rq2_raddr,
			  output wfull, write_en,
			  output reg [(PTR_SZ-1):0] waddr,
			  output [PTR_SZ:0] waddr_gray
);
  reg [PTR_SZ:0] waddr_aux;
 
  assign waddr_gray = (waddr_aux >> 1) ^ waddr_aux;
  assign wfull = (waddr_gray[PTR_SZ:(PTR_SZ-1)] == ~rq2_raddr[PTR_SZ:(PTR_SZ-1)]) &&
                 (waddr_gray[(PTR_SZ-2):0] == rq2_raddr[(PTR_SZ-2):0]);
  assign write_en = !wfull;
  
  always @(posedge clk or negedge rst)
  begin
    if (!rst) waddr_aux = 0;
    else      waddr = waddr_aux[(PTR_SZ-1):0];
  end

  always @(winc)
  begin
    if (winc && !wfull) waddr_aux = waddr_aux + 1;
  end

endmodule

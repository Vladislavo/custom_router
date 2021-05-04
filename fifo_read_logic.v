// fifo_read_logic.v
// Author: Vladislav Rykov

// PTR_SZ    - FIFO entry index size in bits
module fifo_read_logic #(parameter PTR_SZ = 2)
			(input clk, rst,
			 input rinc,
			 input [PTR_SZ:0] rq2_waddr,
			 output rempty, read_en,
			 output reg [(PTR_SZ-1):0] raddr,
			 output [PTR_SZ:0] raddr_gray
);
  reg [PTR_SZ:0] raddr_aux;

  assign raddr_gray = (raddr_aux >> 1) ^ raddr_aux;
  assign rempty = (rq2_waddr == raddr_gray);
  assign read_en = !rempty;

  always @(rinc or rst)
  begin
    if (!rst) raddr_aux = 0;
    else 
      if (rinc && !rempty) raddr_aux = raddr_aux + 1;
  end

  always @(posedge clk)
  begin
    raddr = raddr_aux[(PTR_SZ-1):0];
  end

endmodule

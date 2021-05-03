// fifo_memory.v
// Author: Vladislav Rykov

// DEPTH     - FIFO size
// WIDTH     - FIFO entry width in units (bytes in our case)
// UWIDTH    - FIFO entry unit width in bits
// PTR_SZ    - FIFO entry index size in bits
// PTR_IN_SZ - FIFO index within entry size in bits (ideally ceil(log2(WIDTH)) )
module fifo_memory #(parameter DEPTH = 4, WIDTH = 11, UWIDTH = 8, PTR_SZ = 2, PTR_IN_SZ = 4)
		    (input read_en, input write_en,
		     input [(PTR_SZ-1):0]      raddr,
		     input [(PTR_IN_SZ-1):0]   raddr_in,
		     input [(PTR_SZ-1):0]      waddr,
		     input [(PTR_IN_SZ-1):0]   waddr_in,
		     input [(UWIDTH-1):0]      wdata,
		     output reg [(UWIDTH-1):0] rdata
);

  reg [(UWIDTH-1):0] memory [(DEPTH-1):0][(WIDTH-1):0];
  // reg [(UWIDTH*WIDTH-1):0] memory [(DEPTH-1):0];

  always @(*)
  begin
    if (write_en) memory[waddr][waddr_in] = wdata;
    if (read_en)  rdata = memory[raddr][raddr_in];
  end
endmodule

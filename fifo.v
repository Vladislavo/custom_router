// fifo.v
// Author: Vladislav Rykov

`include "fifo_write_logic.v"
`include "fifo_memory.v"
`include "fifo_read_logic.v"
`include "synchronizer.v"

// DEPTH     - FIFO size (for right rollover should be 2^PTR_SZ, otherwise use*
//             for PTR_SZ range)
// WIDTH     - FIFO entry width in units (bytes in our case)
// UWIDTH    - FIFO entry unit width in bits
// PTR_SZ    - FIFO entry index size in bits (log2(DEPTH))
// PTR_IN_SZ - FIFO index within entry size in bits (ideally ceil(log2(WIDTH)) )
//
// * if depth is not ^2 PTR_SZ => [ (2^PTR_SZ -DEPTH)/2 , (2^PTR_SZ +DEPTH)/2 -1 ]
module fifo #(DEPTH = 4, WIDTH = 11, UWIDTH = 8, PTR_SZ = 2, PTR_IN_SZ = 4)
             (input clk1, clk2, rst,
              input winc, rinc,
              input [(PTR_IN_SZ-1):0] waddr_in, raddr_in,
              input [(UWIDTH-1):0] wdata,
              output [(UWIDTH-1):0] rdata,
              output wfull, rempty
);
  wire write_en, read_en;
  wire [(PTR_SZ-1):0] waddr, raddr;
  wire [PTR_SZ:0] rq2_waddr, waddr_gray, rq2_raddr, raddr_gray;

  fifo_write_logic #(.PTR_SZ(PTR_SZ)) fwl (.clk(clk1), .rst(rst), .winc(winc), .rq2_raddr(rq2_raddr), .wfull(wfull), .write_en(write_en), .waddr(waddr), .waddr_gray(waddr_gray));

  fifo_memory #(.DEPTH(DEPTH), .WIDTH(WIDTH), .UWIDTH(UWIDTH), .PTR_SZ(PTR_SZ), .PTR_IN_SZ(PTR_IN_SZ)) fm (.read_en(read_en), .write_en(write_en), .raddr(raddr), .raddr_in(raddr_in), .waddr(waddr), .waddr_in(waddr_in), .wdata(wdata), .rdata(rdata));

  fifo_read_logic #(.PTR_SZ(PTR_SZ)) frl (.clk(clk2), .rst(rst), .rinc(rinc), .rq2_waddr(rq2_waddr), .rempty(rempty), .read_en(read_en), .raddr(raddr), .raddr_gray(raddr_gray));

  synchronizer #(.PTR_SZ(PTR_SZ)) fs (.clk1(clk1), .clk2(clk2), .rst(rst), .waddr_gray(waddr_gray), .rq2_raddr(rq2_raddr), .raddr_gray(raddr_gray), .rq2_waddr(rq2_waddr));

endmodule

// fifo_write_logic.v
// Author: Vladislav Rykov

// PTR_SZ    - FIFO entry index size in bits
module fifo_write_logic #(parameter PTR_SZ = 2)
			 (input clk, rst,
			  input winc,
			  input [PTR_SZ:0] rq2_raddr,
			  output reg wfull, write_en,
			  output reg [(PTR_SZ-1):0] waddr,
			  output [PTR_SZ:0] waddr_gray
);
  localparam IDLE = 2'b00, WRITE = 2'b01, FULL = 2'b10;
  reg [1:0] current_state, next_state;
  
  reg [PTR_SZ:0] raddr, waddr_tmp;

  assign waddr_gray = (waddr_tmp >> 1) ^ waddr_tmp;
  assign wfull_tmp = (waddr_gray[PTR_SZ:(PTR_SZ-1)] == ~rq2_raddr[PTR_SZ:(PTR_SZ-1)]) &&
                     (waddr_gray[(PTR_SZ-2):0] == rq2_raddr[(PTR_SZ-2):0]);

  // FSM sequential block
  always @(posedge clk or negedge rst)
  begin
    if (!rst) current_state <= IDLE;
    else      current_state <= next_state;
  end

  // FSM combinational block
  always @(current_state or wfull_tmp)
  begin
    next_state = current_state;
    write_en = 0;

    case (current_state)
      IDLE: begin
        write_en = 0;
        if (!wfull_tmp) next_state = WRITE;
        else        next_state = IDLE;
      end
      WRITE: begin
        write_en = 1;
        if (wfull_tmp)  next_state = FULL;
        else        next_state = WRITE;
      end
      FULL: begin
        write_en = 0;
        if (!wfull_tmp) next_state = WRITE;
        else        next_state = FULL;
      end
    endcase
  end

  // sequential block
  always @(posedge clk or negedge rst)
  begin
    if (!rst) begin
      write_en <= 0;
      wfull <= 0;
      waddr <= 0;

      waddr_tmp = 0;
    end else begin
      wfull <= wfull_tmp;
      waddr <= waddr_tmp[(PTR_SZ-1):0];
    end
  end

  // combinational blocks
  always @(winc)
  begin
    if (winc && !wfull_tmp) waddr_tmp = waddr_tmp + 1;
  end

endmodule

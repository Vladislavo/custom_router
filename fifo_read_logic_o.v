// fifo_read_logic.v
// Author: Vladislav Rykov

// PTR_SZ    - FIFO entry index size in bits
module fifo_read_logic #(parameter PTR_SZ = 2)
			(input clk, rst,
			 input rinc,
			 input [PTR_SZ:0] rq2_waddr,
			 output reg rempty, read_en,
			 output reg [(PTR_SZ-1):0] raddr,
			 output [PTR_SZ:0] raddr_gray
);
  localparam IDLE = 2'b00, READ = 2'b01, EMPTY = 2'b10;
  reg [1:0] current_state, next_state;
  
  reg [PTR_SZ:0] waddr, raddr_tmp;

  assign raddr_gray = (raddr_tmp >> 1) ^ raddr_tmp;
  assign rempty_tmp = (rq2_waddr == raddr_gray);

  // FSM sequential block
  always @(posedge clk or negedge rst)
  begin
    if (!rst) current_state <= IDLE;
    else      current_state <= next_state;
  end

  // FSM combinational block
  always @(current_state or rempty_tmp)
  begin
    next_state = current_state;
    read_en = 0;

    case (current_state)
      IDLE: begin
        read_en = 0;
        if (!rempty_tmp) next_state = READ;
        else             next_state = IDLE;
      end
      READ: begin
        read_en = 1;
        if (rempty_tmp)  next_state = EMPTY;
        else             next_state = READ;
      end
      EMPTY: begin
        read_en = 0;
        if (!rempty_tmp) next_state = READ;
        else             next_state = EMPTY;
      end
    endcase
  end

  // sequential block
  always @(posedge clk or negedge rst)
  begin
    if (!rst) begin
      read_en <= 0;
      rempty <= 0;
      raddr <= 0;

      raddr_tmp = 0;
    end else begin
      rempty <= rempty_tmp;
      raddr <= raddr_tmp[(PTR_SZ-1):0];
    end
  end

  // combinational blocks
  always @(rinc)
  begin
    if (rinc && !rempty_tmp) raddr_tmp = raddr_tmp + 1;
  end

endmodule

// packet_sender.v
// Author: Vladislav Rykov

`define SRC_ID 0
`define DST_ID 1
`define SIZE   2
`define DATA   3

`define SIZE_BITS 3

module packet_sender #(UWIDTH = 8, PTR_IN_SZ = 4)
                      (input clk, rst,
                       input rempty,
                       input [(UWIDTH-1):0] rdata,
                       output reg rinc, packet_valid,
                       output reg [(PTR_IN_SZ-1):0] raddr_in,
                       output [(UWIDTH-1):0] packet_out
);
  localparam IDLE = 3'd0, SRC = 3'd1, DST = 3'd2, SIZE = 3'd3, DATA = 3'd4, CRC = 3'd5;
  reg [2:0] current_state, next_state;

  reg [(`SIZE_BITS-1):0] dsz;
  //reg [(PTR_IN_SZ-1):0]  raddr_in_next;

  assign packet_out = rdata;

  always @(negedge clk or negedge rst)
  begin
    if (!rst) current_state <= IDLE;
    else      current_state <= next_state;
  end

  /*
  // fsm combinational state block
  always @(current_state or rempty)
  begin
    next_state = current_state;
    packet_valid = 1;

    case (current_state)
      IDLE: begin
        packet_valid = 0;
        if (!rempty) next_state = SRC;
        else         next_state = IDLE;
      end
      SRC: begin
        next_state = DST;
      end
      DST: begin
        next_state = SIZE;
      end
      SIZE: begin
        next_state = DATA;
      end
      DATA: begin
        if (dsz) next_state = DATA;
        else     next_state = CRC;
      end
      CRC: begin
        next_state = IDLE;
      end
  end
  */

  // fsm combinational output block
  always @(current_state or rempty or dsz)
  begin
    next_state = current_state;
    packet_valid = 1;
    rinc = 0;
    raddr_in = `SIZE;

    case (current_state)
      IDLE: begin
        packet_valid = 0;
        if (!rempty) begin
          next_state = SRC;
        end else begin
          next_state = IDLE;
        end
      end
      SRC: begin
        dsz = rdata[(`SIZE_BITS-1):0];
        raddr_in = `SRC_ID;
        next_state = DST;
      end
      DST: begin
        raddr_in = `DST_ID;
        next_state = SIZE;
      end
      SIZE: begin
        raddr_in = `SIZE;
        next_state = DATA;
      end
      DATA: begin
        if (dsz) begin
          next_state = DATA;
        end else begin
          next_state = CRC;
        end
      end
      CRC: begin
	raddr_in = raddr_in + 1;
        rinc = 1;
        next_state = IDLE;
      end
    endcase
  end

  always @(posedge clk or negedge rst) begin
    if (!rst) begin
      dsz <= 0;
      raddr_in <= 0;
    end else begin
      if (current_state == DATA) begin
        raddr_in <= raddr_in + 1;
        dsz <= dsz - 1;
      end
    end
  end

endmodule

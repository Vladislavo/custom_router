// packet_sender.v
// Author: Vladislav Rykov
// Note: current version of design requires two clock cycle between successive packets.

`define SRC_ID 0
`define DST_ID 1
`define SIZE   2
`define DATA   3

`define SIZE_BITS 3

module packet_sender #(parameter UWIDTH = 8, PTR_IN_SZ = 4)
                      (input clk, rst,
                       input rempty,
                       input [(UWIDTH-1):0] rdata,
                       output reg rinc, packet_valid,
                       output reg [(PTR_IN_SZ-1):0] raddr_in,
                       output [(UWIDTH-1):0] packet_out
);
  localparam IDLE = 3'd0, SRC = 3'd1, DST = 3'd2, SIZE = 3'd3, DATA = 3'd4, CRC = 3'd5, sCRC = 3'd6;
  reg [2:0] current_state, next_state;

  reg [(`SIZE_BITS-1):0] dsz;
  reg rinc_next;
  reg rempty_sync;

  assign packet_out = rdata;

  // clk negedge is chosen here to make it synchronous to the posedge
  always @(negedge clk or negedge rst)
  begin
    if (!rst) current_state <= IDLE;
    else      current_state <= next_state;
  end

  // fsm state logic
  always @(current_state or rempty_sync or dsz)
  begin
    next_state = current_state;

    case (current_state)
      IDLE: begin
        if (!rempty_sync) begin
          next_state = SRC;
        end else begin
          next_state = IDLE;
        end
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
        if (dsz) begin
          next_state = DATA;
        end else begin
          next_state = CRC;
        end
      end
      CRC: begin
        //next_state = sCRC;
        next_state = IDLE;
      end
      sCRC: begin
        next_state = IDLE;
      end
    endcase
  end

  // fsm output logic
  always @(current_state or rempty_sync or dsz)
  begin
    rinc_next = 0;
    packet_valid = 1;
    //raddr_in = raddr_in + 1;

    case (current_state)
      IDLE: begin
        packet_valid = 0;
        if (!rempty_sync) begin
          raddr_in = `SIZE;
        end
      end
      SRC: begin
        raddr_in = 0;
        //packet_valid = 0;
        //dsz = rdata[(`SIZE_BITS-1):0]-1;
      end
      DST: begin
        raddr_in = raddr_in + 1;
      end
      SIZE: begin
        raddr_in = raddr_in + 1;
      end
      DATA: begin
        //dsz = dsz - 1;
        raddr_in = raddr_in + 1;
      end
      CRC: begin
        rinc_next = 1;
      end
      sCRC: begin
        //rinc_next = 1;
      end
    endcase
  end

  always @(current_state or rdata)
  begin

    case (current_state)
      SRC: begin
        dsz = rdata[(`SIZE_BITS-1):0]-1;
      end
      DATA: begin
        dsz = dsz - 1;
      end
    endcase
  end
  

  /*
  // fsm combinational output block
  always @(current_state or rempty_sync or dsz)
  begin
    next_state = current_state;
    rinc_next = 0;
    packet_valid = 1;

    case (current_state)
      IDLE: begin
        packet_valid = 0;
        if (!rempty_sync) begin
          //raddr_in = `SIZE;
          next_state = SRC;
        end else begin
          next_state = IDLE;
        end
      end
      SRC: begin
        packet_valid = 0;
        //dsz = rdata[(`SIZE_BITS-1):0]-1;
        //raddr_in = `SRC_ID;
        next_state = DST;
      end
      DST: begin
        next_state = SIZE;
      end
      SIZE: begin
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
        //rinc_next = 1;
        //next_state = IDLE;
        next_state = sCRC;
      end
      sCRC: begin
        rinc_next = 1;
        next_state = IDLE;
      end
    endcase
  end
  */
  always @(negedge clk or negedge rst) begin
    if (!rst) begin
      //dsz = 0;
      rinc <= 0;
      rempty_sync <= 1;
    end else begin
      //if (current_state != IDLE) raddr_in = raddr_in + 1;
      //else if (!rempty) begin
      //  raddr_in = `SIZE;
      //end
      //if (current_state == DATA) dsz = dsz - 1;
      //if (current_state == SRC) begin
      //  raddr_in = 0;
      //  dsz = rdata[(`SIZE_BITS-1):0]-1;
      //end
      rinc <= rinc_next;
      rempty_sync <= rempty;
    end
  end
endmodule

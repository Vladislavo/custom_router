// packet_receiver.v
// Author: Vladislav Rykov, Sushma Kakarla

module packet_receiver #(parameter TS1=8'd0, TS2=8'd1, TS3=8'd2, PTR_IN_SZ = 4, UWIDTH = 8)
                        (input clk1, rst, packet_valid_i,
                         input [(UWIDTH-1):0] pdata,
                         input wfull_port_1, wfull_port_2, wfull_port_3,
                         output reg stop_packet_send,
                         output reg [(PTR_IN_SZ-1):0] waddr_in_port_1, waddr_in_port_2, waddr_in_port_3,    
                         output reg winc_port_1,winc_port_2,winc_port_3,	
                         output reg [7:0]wdata_port_1,wdata_port_2,wdata_port_3
);
 
  localparam  IDLE = 4'b0000,
	      SRC  = 4'b0001,
	      DST  = 4'b0010,
	      SIZE = 4'b0011,
	      DATA = 4'b0100,
	      CRC  = 4'b0101;
			
  reg trusted;                                       //To send whole trusted packet into samr port
  reg [1:0] dest_p;                                  //Destination port
  reg [3:0] present_state, next_state;
  reg [7:0] temp1, temp2, temp3;                            //temporary registers for storing input packet data byte 
  reg pv_temp1, pv_temp2, pv_temp3;
  reg [3:0]x;                                        //variable used for packet size
  reg [2:0]k;                                        //variable used for count operation
  reg winc_port_1_next, winc_port_2_next, winc_port_3_next;
//-------------------------------------------------------------------------------------------------------------------------------------------
//temp logic
  always @(posedge clk1 or negedge rst) begin
    if (!rst) begin
      temp1 <= 0;
      temp2 <= 0;
      temp3 <= 0;
      pv_temp1 <= 0;
      pv_temp2 <= 0;
      pv_temp3 <= 0;
    end else begin
      temp1 <=pdata;                                      //temp1 carry present data entered in
      temp2 <=temp1;                                      //temp2 holds byte stored in register to be sent after delay
      temp3 <=temp2;                                      //temp2 holds byte stored in register to be sent after delay
      pv_temp1 <= packet_valid_i;
      pv_temp2 <= pv_temp1;
      pv_temp3 <= pv_temp2;
    end
  end
//--------------------------------------------------------------------------------------------------------------------------------------------
// rst logic for states
  always @(posedge clk1 or negedge rst) begin
    if (!rst) present_state <= IDLE;  
     else     present_state <= next_state;
  end
//--------------------------------------------------------------------------------------------------------------------------------------------
// stop packet send enable and disable block
  always@(posedge clk1 or negedge rst) begin 
    if (!rst) stop_packet_send <= 0;
    else      stop_packet_send <= wfull_port_1 || wfull_port_2 || wfull_port_3;
  end
//-------------------------------------------------------------------------------------------------------------------------------------------	
  always @(present_state or packet_valid_i or stop_packet_send or k) begin
    next_state = present_state;

    case (present_state)
      IDLE: begin
        if (packet_valid_i && !stop_packet_send) begin
          next_state = SRC;
        end else begin
          next_state = IDLE;
        end
      end
      SRC: begin
        if (!stop_packet_send) begin
          next_state = DST;
        end else begin
          next_state = IDLE;
        end
      end
      DST: begin
        if (!stop_packet_send) begin
          next_state = SIZE; 
        end else begin
          next_state = IDLE;
        end
      end
      SIZE: begin
        next_state = DATA;
      end
      DATA: begin
        if (!k) begin
          next_state = CRC;
        end else begin
          next_state = DATA; 
        end
      end
      CRC: begin
        next_state = IDLE;
        if (!stop_packet_send) begin
          if (pv_temp2 && pv_temp1) begin // back-to-back packets
            next_state = DST;
          end else if (pv_temp1) begin // incoming packet after 1 clk period 
            next_state = SRC;
          end
        end
      end
    endcase
  end

  always @(present_state or temp3) begin
    winc_port_1_next = 0;
    winc_port_2_next = 0;
    winc_port_3_next = 0; 
    x = 0;

    case (present_state)
      IDLE: begin
        if (present_state == IDLE && !stop_packet_send) begin
          waddr_in_port_1 = 0;
          waddr_in_port_2 = 0;
          waddr_in_port_3 = 0;
        end
      end
      SRC: begin
        if (!stop_packet_send) begin
          trusted = temp2 == TS1 || temp2 == TS2 || temp2 == TS3;
        end
      end
      DST: begin
        trusted = temp3 == TS1 || temp3 == TS2 || temp3 == TS3;

        if (!stop_packet_send && trusted) begin
          if (0 <= temp2 && temp2 <= 127) begin
            wdata_port_1 = temp3;
            waddr_in_port_1 = 0;
            dest_p = 1; 
          end else if (128 <= temp2 && temp2 <= 195) begin
            wdata_port_2 = temp3;
            waddr_in_port_2 = 0;
            dest_p=2;
          end else if (196 <= temp2 && temp2 <= 255) begin
            wdata_port_3 = temp3;
            waddr_in_port_3 = 0;
            dest_p = 3;
          end
        end
      end
      SIZE: begin
        if (trusted) begin
          case (dest_p)
            1: begin
              wdata_port_1 = temp3;
              waddr_in_port_1 = waddr_in_port_1 + 1;
            end
            2: begin
              wdata_port_2 = temp3;
              waddr_in_port_2 = waddr_in_port_2 + 1;
            end
            3: begin
              wdata_port_3 = temp3;
              waddr_in_port_3 = waddr_in_port_3 + 1;
            end
          endcase
        end
  
        k = temp2[2:0] + 1;
        x = k + 4;
      end
      DATA: begin
        if (trusted) begin
          case (dest_p)
            1: begin
              wdata_port_1 = temp3;
              waddr_in_port_1 = waddr_in_port_1 + 1;
            end
            2: begin
              wdata_port_2 = temp3;
              waddr_in_port_2 = waddr_in_port_2 + 1;
            end
            3: begin
              wdata_port_3 = temp3;
              waddr_in_port_3 = waddr_in_port_3 + 1;
            end
          endcase
        end
  
        k = k - 1;
      end
      CRC: begin
        if (trusted) begin
          case (dest_p)
            1: begin
              wdata_port_1 = temp3;
              waddr_in_port_1 = waddr_in_port_1 + 1;
              winc_port_1_next = 1;
            end
            2: begin 
              wdata_port_2 = temp3;
              waddr_in_port_2 = waddr_in_port_2 + 1;
              winc_port_2_next = 1;
            end
            3: begin
              wdata_port_3 = temp3;
              waddr_in_port_3 = waddr_in_port_3 + 1;
              winc_port_3_next = 1;
            end
          endcase
        end
      end
    endcase
  end

  always @(posedge clk1 or negedge rst) begin
    if (!rst) begin
      winc_port_1 <= 0;
      winc_port_2 <= 0;
      winc_port_3 <= 0;
    end else begin
      winc_port_1 <= winc_port_1_next;
      winc_port_2 <= winc_port_2_next;
      winc_port_3 <= winc_port_3_next;
    end
  end
endmodule      

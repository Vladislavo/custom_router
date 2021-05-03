`include "packet_receiver.v"
`define CLK_1     5 // for test ease
 module receiver_fixture;
        reg clk1, rst;
        reg packet_valid_i;
        reg [7:0]pdata;
        reg wfull_port_1,wfull_port_2,wfull_port_3;
        wire stop_packet_send;
        wire [3:0]waddr_in_port_1,waddr_in_port_2,waddr_in_port_3;   
        wire winc_port_1,winc_port_2,winc_port_3;//,waddr_in_port_1,waddr_in_port_2,waddr_in_port_3;
        wire [7:0]wdata_port_1,wdata_port_2,wdata_port_3;

  
  packet_receiver rf(.clk1(clk1), .rst(rst), .packet_valid_i(packet_valid_i), .pdata(pdata), .wfull_port_1(wfull_port_1), .wfull_port_2(wfull_port_2), .wfull_port_3(wfull_port_3), .stop_packet_send(stop_packet_send), .winc_port_1(winc_port_1), .winc_port_2(winc_port_2), .winc_port_3(winc_port_3), .wdata_port_1(wdata_port_1), .wdata_port_2(wdata_port_2), .wdata_port_3(wdata_port_3), .waddr_in_port_1(waddr_in_port_1), .waddr_in_port_2(waddr_in_port_2), .waddr_in_port_3(waddr_in_port_3));

  initial begin
   fork
      begin: clock_1_thread
      clk1 = 1'b0;
      forever #`CLK_1 clk1 =~ clk1;
      end
      begin: stimulus_thread
       rst = 0; 
// packet 1   ............trusted packet to dest-1...........
       #`CLK_1 rst = 1; packet_valid_i = 1;wfull_port_1 = 0; wfull_port_2 = 0; wfull_port_3 = 0;
                   pdata = 8'b00000001;              //Src_id
       #(2*`CLK_1) pdata = 8'b00000110;              //Dest_id
       #(2*`CLK_1) pdata = 8'b00000010;              //SIZE

       #(2*`CLK_1) pdata = 8'b10101011;              //DATA
       #(2*`CLK_1) pdata = 8'b11011000;

       #(2*`CLK_1) pdata = 8'b01110011;              //CRC
      // #(4*`CLK_1)$display("packet1 end");
// packet 2    ...........trusted packet to dest-2.............
    // #(`CLK_1) rst = 0;
    #(2*`CLK_1) rst = 1; packet_valid_i = 1; wfull_port_1 = 0; wfull_port_2 = 0; wfull_port_3 = 0;
                   pdata = 8'b00000001;              //Src_id
       #(2*`CLK_1) pdata = 8'b00000010;              //Dest_id
       #(2*`CLK_1) pdata = 8'b00000100;              //SIZE

       #(2*`CLK_1) pdata = 8'b00100111;              //DATA
       #(2*`CLK_1) pdata = 8'b10111000;
       #(2*`CLK_1) pdata = 8'b00101101;
       #(2*`CLK_1) pdata = 8'b00000110;

       #(2*`CLK_1) pdata = 8'b10110100;              //CRC
//        //#(4*`CLK_1)$display("packet2 end");
// packet 3    ...........non trusted packet.........
// #`CLK_1 rst = 0;
       #(2*`CLK_1) rst = 1; packet_valid_i = 1;wfull_port_1 = 0; wfull_port_2 = 0; wfull_port_3 = 0;
                   pdata = 8'b11001101;              //Src_id
       #(2*`CLK_1) pdata = 8'b11000101;              //Dest_id
       #(2*`CLK_1) pdata = 8'b00000010;              //SIZE

       #(2*`CLK_1) pdata = 8'b00000111;              //DATA
       #(2*`CLK_1) pdata = 8'b11111000;

       #(2*`CLK_1) pdata = 8'b11111111;              //CRC
//       // #(4*`CLK_1)$display("packet3 end");
// packet 4     ...............trusted but stop_packet_send is asserted............
// #`CLK_1 rst = 0;
       #(2*`CLK_1) rst = 1; packet_valid_i = 1;wfull_port_1 = 0; wfull_port_2 = 0; wfull_port_3 = 0;
                   pdata = 8'b00000000;              //Src_id
       #(2*`CLK_1) pdata = 8'b11110110;              //Dest_id
       #(2*`CLK_1) pdata = 8'b00000001;              //SIZE

       #(2*`CLK_1) pdata = 8'b00011000;              //DATA

       #(2*`CLK_1) pdata = 8'b00011000;              //CRC
//        //#(4*`CLK_1)$display("packet4 end");
// // packet 5  ................packet_valid_i deasserted...................
// #`CLK_1 rst = 0;
//       #`CLK_1 rst = 1; packet_valid_i = 0; wfull_port_1 = 0; wfull_port_2 = 0; wfull_port_3 = 0;
//                    pdata = 8'b00000001;              //Src_id
//        #(2*`CLK_1) pdata = 8'b11000101;              //Dest_id
//        #(2*`CLK_1) pdata = 8'b00000001;              //SIZE

//        #(2*`CLK_1) pdata = 8'b00000111;              //DATA

//        #(2*`CLK_1) pdata = 8'b00000111;              //CRC
//        //#(4*`CLK_1)$display("packet5 end");
      end
      begin: ending_thread
       #(56*`CLK_1) disable clock_1_thread; disable stimulus_thread;
      end
   join
    #`CLK_1 $finish;
  end
  
  initial
    $monitor("Time=%3d,ps=%1d,ns=%1d,clk=%b,wf1=%b,wf2=%b,wf3=%b,pd=%3d,t1=%3d,k=%d,x=%2d,t2=%3d,wd_p1=%3d,wd_p2=%3d,wd_p3=%3d,wincp1=%d,wincp2=%d,wincp3=%d,tst=%b,wa1=%d,wa2=%d,wa3=%d",$time,rf.present_state,rf.next_state,clk1,wfull_port_1,wfull_port_2,wfull_port_3,pdata,rf.temp1,rf.k,rf.x,rf.temp2,wdata_port_1,wdata_port_2,wdata_port_3,winc_port_1,winc_port_2,winc_port_3,rf.trusted,waddr_in_port_1,waddr_in_port_2,waddr_in_port_3);
endmodule
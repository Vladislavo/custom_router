// router_fixture.v
// Author: Vladislav Rykov

`include "router.v"

`define CLK_1     2 // F=250KHz T=4us
`define CLK_2     5 // F=100KHz T=10us

`define DEPTH     4
`define WIDTH     11
`define UWIDTH    8
`define PTR_SZ 	  2
`define PTR_IN_SZ 4

`define TS1       8'd0
`define TS2       8'd1
`define TS3       8'd2

module router_fixture;
  reg clk1, clk2, rst;

  reg packet_valid_i;
  reg [(`UWIDTH-1):0] packet_in;
  
  wire stop_packet_send;
  wire packet_valid_o1, packet_valid_o2, packet_valid_o3;
  wire [(`UWIDTH-1):0] packet_out1, packet_out2, packet_out3;

  reg [(`UWIDTH-1):0] crc;
  reg [(4-1):0] i, k;
  reg [8:0] j;

  router #(.DEPTH(`DEPTH), .WIDTH(`WIDTH), .UWIDTH(`UWIDTH), .PTR_SZ(`PTR_SZ), .PTR_IN_SZ(`PTR_IN_SZ), .TS1(`TS1), .TS2(`TS2), .TS3(`TS3)) r (.clk1(clk1), .clk2(clk2), .rst(rst), .packet_valid_i(packet_valid_i), .packet_in(packet_in), .stop_packet_send(stop_packet_send), .packet_valid_o1(packet_valid_o1), .packet_valid_o2(packet_valid_o2), .packet_valid_o3(packet_valid_o3), .packet_out1(packet_out1), .packet_out2(packet_out2), .packet_out3(packet_out3));

  initial begin
   fork
     begin: clock_1_thread
       clk1 = 1'b0;
       forever #`CLK_1 clk1 =~ clk1;
     end
     begin: clock_2_thread
       clk2 = 1'b0;
       forever #`CLK_2 clk2 =~ clk2;
     end
     begin: stimulus_thread
       rst = 0; packet_valid_i = 0; packet_in = 0; crc = 0;
       // packet 1
       #`CLK_1 rst = 1; packet_valid_i = 1; packet_in = 0; crc = ^packet_in; // source_id
       #(`CLK_1*2) packet_in = 16; crc = (^packet_in)^crc; // dest_id port 1
       #(`CLK_1*2) packet_in = 3; crc = (^packet_in)^crc; // size
       #(`CLK_1*2) packet_in = 0; crc = (^packet_in)^crc; // data 1
       #(`CLK_1*2) packet_in = 1; crc = (^packet_in)^crc; // data 2
       #(`CLK_1*2) packet_in = 2; crc = (^packet_in)^crc; // data 3
       #(`CLK_1*2) packet_in = crc; // crc
       
       // packet 2 
       #(`CLK_1*2) $display("=======================================Packet 1 received -> Port 1");
                    packet_in = 127; crc = ^packet_in; // source_id UNTRUSTED
       #(`CLK_1*2) packet_in = 245; crc = (^packet_in)^crc; // dest_id
       #(`CLK_1*2) packet_in = 2; crc = (^packet_in)^crc; // size
       #(`CLK_1*2) packet_in = 0; crc = (^packet_in)^crc; // data 1
       #(`CLK_1*2) packet_in = 1; crc = (^packet_in)^crc; // data 2
       #(`CLK_1*2) packet_in = crc; // crc

       #(`CLK_1*2) $display("=======================================Untrusted packet dropped");
                   packet_valid_i = 0;

       #(`CLK_1*2) packet_valid_i = 1; packet_in = 1; crc = ^packet_in; // source_id
       #(`CLK_1*2) packet_in = 128; crc = (^packet_in)^crc; // dest_id port 2
       #(`CLK_1*2) packet_in = 4; crc = (^packet_in)^crc; // size
       #(`CLK_1*2) packet_in = 0; crc = (^packet_in)^crc; // data 1
       #(`CLK_1*2) packet_in = 1; crc = (^packet_in)^crc; // data 2
       #(`CLK_1*2) packet_in = 2; crc = (^packet_in)^crc; // data 3
       #(`CLK_1*2) packet_in = 3; crc = (^packet_in)^crc; // data 4
       #(`CLK_1*2) packet_in = crc; // crc
       
       
       #(`CLK_1*2) $display("=======================================Packet 2 received -> Port 2");
                    packet_in = 2; crc = ^packet_in; // source_id
       #(`CLK_1*2) packet_in = 254; crc = (^packet_in)^crc; // dest_id port 3
       #(`CLK_1*2) packet_in = 5; crc = (^packet_in)^crc; // size
       #(`CLK_1*2) packet_in = 0; crc = (^packet_in)^crc; // data 1
       #(`CLK_1*2) packet_in = 1; crc = (^packet_in)^crc; // data 2
       #(`CLK_1*2) packet_in = 2; crc = (^packet_in)^crc; // data 3
       #(`CLK_1*2) packet_in = 3; crc = (^packet_in)^crc; // data 4
       #(`CLK_1*2) packet_in = 4; crc = (^packet_in)^crc; // data 5
       #(`CLK_1*2) packet_in = crc; // crc
       
       #(`CLK_1*2) $display("=======================================Packet 3 received -> Port 3");
                    packet_in = 1; crc = ^packet_in; // source_id
       #(`CLK_1*2) packet_in = 240; crc = (^packet_in)^crc; // dest_id port 3
       #(`CLK_1*2) packet_in = 6; crc = (^packet_in)^crc; // size
       #(`CLK_1*2) packet_in = 0; crc = (^packet_in)^crc; // data 1
       #(`CLK_1*2) packet_in = 1; crc = (^packet_in)^crc; // data 2
       #(`CLK_1*2) packet_in = 2; crc = (^packet_in)^crc; // data 3
       #(`CLK_1*2) packet_in = 3; crc = (^packet_in)^crc; // data 4
       #(`CLK_1*2) packet_in = 4; crc = (^packet_in)^crc; // data 5
       #(`CLK_1*2) packet_in = 5; crc = (^packet_in)^crc; // data 6
       #(`CLK_1*2) packet_in = crc;// crc
       
       #(`CLK_1*2) $display("=======================================Packet 4 stored while Port 3 is busy");
                   $display("=======================================Let's fill up the router");
                   packet_valid_i = 0;
       #(`CLK_1*2*4) packet_valid_i = 1; packet_in = 1; crc = ^packet_in; // source_id
       #(`CLK_1*2) packet_in = 125; crc = (^packet_in)^crc; // dest_id port 1
       #(`CLK_1*2) packet_in = 4; crc = (^packet_in)^crc; // size
       #(`CLK_1*2) packet_in = 0; crc = (^packet_in)^crc; // data 1
       #(`CLK_1*2) packet_in = 1; crc = (^packet_in)^crc; // data 2
       #(`CLK_1*2) packet_in = 2; crc = (^packet_in)^crc; // data 3
       #(`CLK_1*2) packet_in = 3; crc = (^packet_in)^crc; // data 4
       #(`CLK_1*2) packet_in = crc; // crc
       
       
       #(`CLK_1*2) $display("=======================================Packet 5 received -> Port 1");
                    packet_in = 2; crc = ^packet_in; // source_id
       #(`CLK_1*2) packet_in = 170; crc = (^packet_in)^crc; // dest_id port 2
       #(`CLK_1*2) packet_in = 5; crc = (^packet_in)^crc; // size
       #(`CLK_1*2) packet_in = 0; crc = (^packet_in)^crc; // data 1
       #(`CLK_1*2) packet_in = 1; crc = (^packet_in)^crc; // data 2
       #(`CLK_1*2) packet_in = 2; crc = (^packet_in)^crc; // data 3
       #(`CLK_1*2) packet_in = 3; crc = (^packet_in)^crc; // data 4
       #(`CLK_1*2) packet_in = 4; crc = (^packet_in)^crc; // data 5
       #(`CLK_1*2) packet_in = crc; // crc
       
       #(`CLK_1*2) $display("=======================================Packet 6 received -> Port 2");
                    packet_in = 1; crc = ^packet_in; // source_id
       #(`CLK_1*2) packet_in = 250; crc = (^packet_in)^crc; // dest_id port 3
       #(`CLK_1*2) packet_in = 6; crc = (^packet_in)^crc; // size
       #(`CLK_1*2) packet_in = 0; crc = (^packet_in)^crc; // data 1
       #(`CLK_1*2) packet_in = 1; crc = (^packet_in)^crc; // data 2
       #(`CLK_1*2) packet_in = 2; crc = (^packet_in)^crc; // data 3
       #(`CLK_1*2) packet_in = 3; crc = (^packet_in)^crc; // data 4
       #(`CLK_1*2) packet_in = 4; crc = (^packet_in)^crc; // data 5
       #(`CLK_1*2) packet_in = 5; crc = (^packet_in)^crc; // data 5
       #(`CLK_1*2) packet_in = crc;// crc
       
       
       #(`CLK_1*2) $display("=======================================Packet 7 received -> Port 3");
       #(`CLK_1*2) packet_valid_i = 1; packet_in = 1; crc = ^packet_in; // source_id
       #(`CLK_1*2) packet_in = 25; crc = (^packet_in)^crc; // dest_id port 1
       #(`CLK_1*2) packet_in = 4; crc = (^packet_in)^crc; // size
       #(`CLK_1*2) packet_in = 0; crc = (^packet_in)^crc; // data 1
       #(`CLK_1*2) packet_in = 1; crc = (^packet_in)^crc; // data 2
       #(`CLK_1*2) packet_in = 2; crc = (^packet_in)^crc; // data 3
       #(`CLK_1*2) packet_in = 3; crc = (^packet_in)^crc; // data 4
       #(`CLK_1*2) packet_in = crc; // crc
       
       
       #(`CLK_1*2) $display("=======================================Packet 8 received -> Port 1");
                    packet_in = 2; crc = ^packet_in; // source_id
       #(`CLK_1*2) packet_in = 150; crc = (^packet_in)^crc; // dest_id port 2
       #(`CLK_1*2) packet_in = 5; crc = (^packet_in)^crc; // size
       #(`CLK_1*2) packet_in = 0; crc = (^packet_in)^crc; // data 1
       #(`CLK_1*2) packet_in = 1; crc = (^packet_in)^crc; // data 2
       #(`CLK_1*2) packet_in = 2; crc = (^packet_in)^crc; // data 3
       #(`CLK_1*2) packet_in = 3; crc = (^packet_in)^crc; // data 4
       #(`CLK_1*2) packet_in = 4; crc = (^packet_in)^crc; // data 5
       #(`CLK_1*2) packet_in = crc; // crc
       
       #(`CLK_1*2) $display("=======================================Packet 9 received -> Port 2");
                    packet_in = 1; crc = ^packet_in; // source_id
       #(`CLK_1*2) packet_in = 250; crc = (^packet_in)^crc; // dest_id port 3
       #(`CLK_1*2) packet_in = 6; crc = (^packet_in)^crc; // size
       #(`CLK_1*2) packet_in = 0; crc = (^packet_in)^crc; // data 1
       #(`CLK_1*2) packet_in = 1; crc = (^packet_in)^crc; // data 2
       #(`CLK_1*2) packet_in = 2; crc = (^packet_in)^crc; // data 3
       #(`CLK_1*2) packet_in = 3; crc = (^packet_in)^crc; // data 4
       #(`CLK_1*2) packet_in = 4; crc = (^packet_in)^crc; // data 5
       #(`CLK_1*2) packet_in = 5; crc = (^packet_in)^crc; // data 5
       #(`CLK_1*2) packet_in = crc;// crc
       
       #(`CLK_1*2) $display("=======================================Packet 10 received -> Port 3");
       #(`CLK_1*2) packet_valid_i = 1; packet_in = 1; crc = ^packet_in; // source_id
       #(`CLK_1*2) packet_in = 25; crc = (^packet_in)^crc; // dest_id port 1
       #(`CLK_1*2) packet_in = 4; crc = (^packet_in)^crc; // size
       #(`CLK_1*2) packet_in = 0; crc = (^packet_in)^crc; // data 1
       #(`CLK_1*2) packet_in = 1; crc = (^packet_in)^crc; // data 2
       #(`CLK_1*2) packet_in = 2; crc = (^packet_in)^crc; // data 3
       #(`CLK_1*2) packet_in = 3; crc = (^packet_in)^crc; // data 4
       #(`CLK_1*2) packet_in = crc; // crc
       
       
       #(`CLK_1*2) $display("=======================================Packet 11 received -> Port 1");
                    packet_in = 2; crc = ^packet_in; // source_id
       #(`CLK_1*2) packet_in = 150; crc = (^packet_in)^crc; // dest_id port 2
       #(`CLK_1*2) packet_in = 5; crc = (^packet_in)^crc; // size
       #(`CLK_1*2) packet_in = 0; crc = (^packet_in)^crc; // data 1
       #(`CLK_1*2) packet_in = 1; crc = (^packet_in)^crc; // data 2
       #(`CLK_1*2) packet_in = 2; crc = (^packet_in)^crc; // data 3
       #(`CLK_1*2) packet_in = 3; crc = (^packet_in)^crc; // data 4
       #(`CLK_1*2) packet_in = 4; crc = (^packet_in)^crc; // data 5
       #(`CLK_1*2) packet_in = crc; // crc

       #(`CLK_1*2) $display("=======================================Packet 12 received -> Port 2");
                    packet_in = 1; crc = ^packet_in; // source_id
       #(`CLK_1*2) packet_in = 250; crc = (^packet_in)^crc; // dest_id port 3
       #(`CLK_1*2) packet_in = 6; crc = (^packet_in)^crc; // size
       #(`CLK_1*2) packet_in = 0; crc = (^packet_in)^crc; // data 1
       #(`CLK_1*2) packet_in = 1; crc = (^packet_in)^crc; // data 2
       #(`CLK_1*2) packet_in = 2; crc = (^packet_in)^crc; // data 3
       #(`CLK_1*2) packet_in = 3; crc = (^packet_in)^crc; // data 4
       #(`CLK_1*2) packet_in = 4; crc = (^packet_in)^crc; // data 5
       #(`CLK_1*2) packet_in = 5; crc = (^packet_in)^crc; // data 5
       #(`CLK_1*2) packet_in = crc;// crc
       
       #(`CLK_1*2) $display("=======================================Packet 13 received -> Port 3");
       #(`CLK_1*2) packet_valid_i = 1; packet_in = 1; crc = ^packet_in; // source_id
       #(`CLK_1*2) packet_in = 25; crc = (^packet_in)^crc; // dest_id port 1
       #(`CLK_1*2) packet_in = 4; crc = (^packet_in)^crc; // size
       #(`CLK_1*2) packet_in = 0; crc = (^packet_in)^crc; // data 1
       #(`CLK_1*2) packet_in = 1; crc = (^packet_in)^crc; // data 2
       #(`CLK_1*2) packet_in = 2; crc = (^packet_in)^crc; // data 3
       #(`CLK_1*2) packet_in = 3; crc = (^packet_in)^crc; // data 4
       #(`CLK_1*2) packet_in = crc; // crc
       
       
       #(`CLK_1*2) $display("=======================================Packet 14 received -> Port 1");
                    packet_in = 2; crc = ^packet_in; // source_id
       #(`CLK_1*2) packet_in = 150; crc = (^packet_in)^crc; // dest_id port 2
       #(`CLK_1*2) packet_in = 5; crc = (^packet_in)^crc; // size
       #(`CLK_1*2) packet_in = 0; crc = (^packet_in)^crc; // data 1
       #(`CLK_1*2) packet_in = 1; crc = (^packet_in)^crc; // data 2
       #(`CLK_1*2) packet_in = 2; crc = (^packet_in)^crc; // data 3
       #(`CLK_1*2) packet_in = 3; crc = (^packet_in)^crc; // data 4
       #(`CLK_1*2) packet_in = 4; crc = (^packet_in)^crc; // data 5
       #(`CLK_1*2) packet_in = crc; // crc

       #(`CLK_1*2) $display("=======================================Packet 15 received -> Port 2");
                    packet_in = 1; crc = ^packet_in; // source_id
       #(`CLK_1*2) packet_in = 250; crc = (^packet_in)^crc; // dest_id port 3
       #(`CLK_1*2) packet_in = 6; crc = (^packet_in)^crc; // size
       #(`CLK_1*2) packet_in = 0; crc = (^packet_in)^crc; // data 1
       #(`CLK_1*2) packet_in = 1; crc = (^packet_in)^crc; // data 2
       #(`CLK_1*2) packet_in = 2; crc = (^packet_in)^crc; // data 3
       #(`CLK_1*2) packet_in = 3; crc = (^packet_in)^crc; // data 4
       #(`CLK_1*2) packet_in = 4; crc = (^packet_in)^crc; // data 5
       #(`CLK_1*2) packet_in = 5; crc = (^packet_in)^crc; // data 5
       #(`CLK_1*2) packet_in = crc;// crc
       
       #(`CLK_1*2) $display("=======================================Packet 16 received -> Port 3");
       #(`CLK_1*2) packet_valid_i = 1; packet_in = 1; crc = ^packet_in; // source_id
       #(`CLK_1*2) packet_in = 25; crc = (^packet_in)^crc; // dest_id port 1
       #(`CLK_1*2) packet_in = 4; crc = (^packet_in)^crc; // size
       #(`CLK_1*2) packet_in = 0; crc = (^packet_in)^crc; // data 1
       #(`CLK_1*2) packet_in = 1; crc = (^packet_in)^crc; // data 2
       #(`CLK_1*2) packet_in = 2; crc = (^packet_in)^crc; // data 3
       #(`CLK_1*2) packet_in = 3; crc = (^packet_in)^crc; // data 4
       #(`CLK_1*2) packet_in = crc; // crc
       
       
       #(`CLK_1*2) $display("=======================================Packet 17 received -> Port 1");
                    packet_in = 2; crc = ^packet_in; // source_id
       #(`CLK_1*2) packet_in = 150; crc = (^packet_in)^crc; // dest_id port 2
       #(`CLK_1*2) packet_in = 5; crc = (^packet_in)^crc; // size
       #(`CLK_1*2) packet_in = 0; crc = (^packet_in)^crc; // data 1
       #(`CLK_1*2) packet_in = 1; crc = (^packet_in)^crc; // data 2
       #(`CLK_1*2) packet_in = 2; crc = (^packet_in)^crc; // data 3
       #(`CLK_1*2) packet_in = 3; crc = (^packet_in)^crc; // data 4
       #(`CLK_1*2) packet_in = 4; crc = (^packet_in)^crc; // data 5
       #(`CLK_1*2) packet_in = crc; // crc

       #(`CLK_1*2) $display("=======================================Packet 18 received -> Port 2");
                    packet_in = 1; crc = ^packet_in; // source_id
       #(`CLK_1*2) packet_in = 250; crc = (^packet_in)^crc; // dest_id port 3
       #(`CLK_1*2) packet_in = 6; crc = (^packet_in)^crc; // size
       #(`CLK_1*2) packet_in = 0; crc = (^packet_in)^crc; // data 1
       #(`CLK_1*2) packet_in = 1; crc = (^packet_in)^crc; // data 2
       #(`CLK_1*2) packet_in = 2; crc = (^packet_in)^crc; // data 3
       #(`CLK_1*2) packet_in = 3; crc = (^packet_in)^crc; // data 4
       #(`CLK_1*2) packet_in = 4; crc = (^packet_in)^crc; // data 5
       #(`CLK_1*2) packet_in = 5; crc = (^packet_in)^crc; // data 5
       #(`CLK_1*2) packet_in = crc;// crc
       
       #(`CLK_1*2) $display("=======================================Packet 19 received -> Port 3");
       #(`CLK_1*2) packet_valid_i = 1; packet_in = 1; crc = ^packet_in; // source_id
       #(`CLK_1*2) packet_in = 25; crc = (^packet_in)^crc; // dest_id port 1
       #(`CLK_1*2) packet_in = 4; crc = (^packet_in)^crc; // size
       #(`CLK_1*2) packet_in = 0; crc = (^packet_in)^crc; // data 1
       #(`CLK_1*2) packet_in = 1; crc = (^packet_in)^crc; // data 2
       #(`CLK_1*2) packet_in = 2; crc = (^packet_in)^crc; // data 3
       #(`CLK_1*2) packet_in = 3; crc = (^packet_in)^crc; // data 4
       #(`CLK_1*2) packet_in = crc; // crc
       
       
       #(`CLK_1*2) $display("=======================================Packet 20 received -> Port 1");
                    packet_in = 2; crc = ^packet_in; // source_id
       #(`CLK_1*2) packet_in = 150; crc = (^packet_in)^crc; // dest_id port 2
       #(`CLK_1*2) packet_in = 5; crc = (^packet_in)^crc; // size
       #(`CLK_1*2) packet_in = 0; crc = (^packet_in)^crc; // data 1
       #(`CLK_1*2) packet_in = 1; crc = (^packet_in)^crc; // data 2
       #(`CLK_1*2) packet_in = 2; crc = (^packet_in)^crc; // data 3
       #(`CLK_1*2) packet_in = 3; crc = (^packet_in)^crc; // data 4
       #(`CLK_1*2) packet_in = 4; crc = (^packet_in)^crc; // data 5
       #(`CLK_1*2) packet_in = crc; // crc
       
       #(`CLK_1*2) $display("=======================================Packet 21 received -> Port 1");
                    packet_in = 2; crc = ^packet_in; // source_id
       #(`CLK_1*2) packet_in = 150; crc = (^packet_in)^crc; // dest_id port 2
       #(`CLK_1*2) packet_in = 5; crc = (^packet_in)^crc; // size
       #(`CLK_1*2) packet_in = 0; crc = (^packet_in)^crc; // data 1
       #(`CLK_1*2) packet_in = 1; crc = (^packet_in)^crc; // data 2
       #(`CLK_1*2) packet_in = 2; crc = (^packet_in)^crc; // data 3
       #(`CLK_1*2) packet_in = 3; crc = (^packet_in)^crc; // data 4
       #(`CLK_1*2) packet_in = 4; crc = (^packet_in)^crc; // data 5
       #(`CLK_1*2) packet_in = crc; // crc

       #(`CLK_1*2) $display("=======================================Packet 22 received -> Port 1");
                    packet_in = 2; crc = ^packet_in; // source_id
       #(`CLK_1*2) packet_in = 150; crc = (^packet_in)^crc; // dest_id port 2
       #(`CLK_1*2) packet_in = 5; crc = (^packet_in)^crc; // size
       #(`CLK_1*2) packet_in = 0; crc = (^packet_in)^crc; // data 1
       #(`CLK_1*2) packet_in = 1; crc = (^packet_in)^crc; // data 2
       #(`CLK_1*2) packet_in = 2; crc = (^packet_in)^crc; // data 3
       #(`CLK_1*2) packet_in = 3; crc = (^packet_in)^crc; // data 4
       #(`CLK_1*2) packet_in = 4; crc = (^packet_in)^crc; // data 5
       #(`CLK_1*2) packet_in = crc; // crc

       #(`CLK_1*2) packet_valid_i = 0;


     end
     begin: checking_thread
       for (j = 0; j < 143; j = j+1) begin
         // 1. memory dump
         #(`CLK_2) $display("FIFO1 T=%3d", $time); for (i = 0; i < 11; i = i+1) 
                       $display("[0][%d] = %b [1][%d] = %b [2][%d] = %b [3][%d] = %b", i, r.fifo1.fm.memory[0][i], i, r.fifo1.fm.memory[1][i], i, r.fifo1.fm.memory[2][i], i, r.fifo1.fm.memory[3][i]);
                   $display("FIFO 2"); for (i = 0; i < 11; i = i+1) 
                       $display("[0][%d] = %b [1][%d] = %b [2][%d] = %b [3][%d] = %b", i, r.fifo2.fm.memory[0][i], i, r.fifo2.fm.memory[1][i], i, r.fifo2.fm.memory[2][i], i, r.fifo2.fm.memory[3][i]);
                   $display("FIFO 3"); for (i = 0; i < 11; i = i+1) 
                       $display("[0][%d] = %b [1][%d] = %b [2][%d] = %b [3][%d] = %b", i, r.fifo3.fm.memory[0][i], i, r.fifo3.fm.memory[1][i], i, r.fifo3.fm.memory[2][i], i, r.fifo3.fm.memory[3][i]);
         
       end
     end
     begin: dve_thread
       $vcdpluson;
     end
     begin: ending_thread
       #(143*`CLK_2) disable clock_1_thread; disable clock_2_thread; disable stimulus_thread; disable checking_thread; disable dve_thread;
     end
   join
   $finish;
  end
  
  initial
    $monitor("T=%3d, clk1 = %d, clk2 = %d, rst = %d, pin = %d, pvi = %d, sps=%d, pvo1 = %d, pout1 = %d, pvo2 = %d, pout2 = %d, pvo3 = %d, pout3 = %d, f1.waddr = %d f1.raddr = %d, f1.wfull = %d, f2.waddr = %d f2.raddr = %d, f2.wfull = %d, f3.waddr = %d f3.raddr = %d, f3.wfull = %d, f3.cs = %d, f3.temp3 = %d, dest_p = %d", $time, clk1, clk2, rst, packet_in, packet_valid_i, stop_packet_send, packet_valid_o1, packet_out1, packet_valid_o2, packet_out2, packet_valid_o3, packet_out3, r.fifo1.fwl.waddr, r.fifo1.frl.raddr, r.fifo1.wfull, r.fifo2.fwl.waddr, r.fifo2.frl.raddr, r.fifo2.wfull, r.fifo3.fwl.waddr, r.fifo3.frl.raddr, r.fifo3.wfull, r.packet_receiver1.present_state, r.packet_receiver1.temp3, r.packet_receiver1.dest_p);

endmodule

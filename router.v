// top module for router
// Vikas Gundapuneedi

`include "packet_receiver.v"
`include "fifo.v"
`include "packet_sender.v"

module router #(DEPTH=4,WIDTH=11,UWIDTH=8,PTR_SZ=2,PTR_IN_SZ=4,TS1=0,TS2=1,TS3=2)

(input clk1,clk2,rst,packet_valid_i,
input [(UWIDTH-1):0] packet_in,
output stop_packet_send,
output packet_valid_o1,packet_valid_o2,packet_valid_o3,
output [(UWIDTH-1):0] packet_out1,packet_out2,packet_out3);

wire  wfull_port_1, wfull_port_2, wfull_port_3;
wire  winc_port_1, winc_port_2, winc_port_3;
wire [(PTR_IN_SZ-1):0] waddr_in_port_1, waddr_in_port_2,waddr_in_port_3;
wire [(UWIDTH-1):0] wdata_port_1,wdata_port_2,wdata_port_3;
wire rempty_port_1,rempty_port_2,rempty_port_3;
wire rinc_port_1,rinc_port_2,rinc_port_3;
wire [(PTR_IN_SZ-1):0] raddr_in_port_1, raddr_in_port_2,raddr_in_port_3;
wire [(UWIDTH-1):0] rdata_port_1,rdata_port_2,rdata_port_3;






packet_receiver #(.TS1(TS1),.TS2(TS2),.TS3(TS3),.PTR_IN_SZ(PTR_IN_SZ),.UWIDTH(UWIDTH)) packet_receiver1(.clk1(clk1),.rst(rst),.packet_valid_i(packet_valid_i),.pdata(packet_in),.wfull_port_1(wfull_port_1),.wfull_port_2(wfull_port_2),.wfull_port_3(wfull_port_3),.stop_packet_send(stop_packet_send),.waddr_in_port_1(waddr_in_port_1),.waddr_in_port_2(waddr_in_port_2),.waddr_in_port_3(waddr_in_port_3),.winc_port_1(winc_port_1),.winc_port_2(winc_port_2),.winc_port_3(winc_port_3),.wdata_port_1(wdata_port_1),.wdata_port_2(wdata_port_2),.wdata_port_3(wdata_port_3));

fifo #(.DEPTH(DEPTH),.WIDTH(WIDTH),.UWIDTH(UWIDTH),.PTR_SZ(PTR_SZ),.PTR_IN_SZ(PTR_IN_SZ)) fifo1(.clk1(clk1),.clk2(clk2),.rst(rst),.winc(winc_port_1),.rinc(rinc_port_1),.waddr_in(waddr_in_port_1),.raddr_in(raddr_in_port_1),.wdata(wdata_port_1),.rdata(rdata_port_1),.wfull(wfull_port_1),.rempty(rempty_port_1));

fifo #(.DEPTH(DEPTH),.WIDTH(WIDTH),.UWIDTH(UWIDTH),.PTR_SZ(PTR_SZ),.PTR_IN_SZ(PTR_IN_SZ)) fifo2(.clk1(clk1),.clk2(clk2),.rst(rst),.winc(winc_port_2),.rinc(rinc_port_2),.waddr_in(waddr_in_port_2),.raddr_in(raddr_in_port_2),.wdata(wdata_port_2),.rdata(rdata_port_2),.wfull(wfull_port_2),.rempty(rempty_port_2));

fifo #(.DEPTH(DEPTH),.WIDTH(WIDTH),.UWIDTH(UWIDTH),.PTR_SZ(PTR_SZ),.PTR_IN_SZ(PTR_IN_SZ)) fifo3(.clk1(clk1),.clk2(clk2),.rst(rst),.winc(winc_port_3),.rinc(rinc_port_3),.waddr_in(waddr_in_port_3),.raddr_in(raddr_in_port_3),.wdata(wdata_port_3),.rdata(rdata_port_3),.wfull(wfull_port_3),.rempty(rempty_port_3));


packet_sender #(.UWIDTH(UWIDTH),.PTR_IN_SZ(PTR_IN_SZ)) packet_sender1 (.clk(clk2),.rst(rst),.rempty(rempty_port_1),.rdata(rdata_port_1),.rinc(rinc_port_1),.packet_valid(packet_valid_o1),.raddr_in(raddr_in_port_1),.packet_out(packet_out1));

packet_sender #(.UWIDTH(UWIDTH),.PTR_IN_SZ(PTR_IN_SZ)) packet_sender2 (.clk(clk2),.rst(rst),.rempty(rempty_port_2),.rdata(rdata_port_2),.rinc(rinc_port_2),.packet_valid(packet_valid_o2),.raddr_in(raddr_in_port_2),.packet_out(packet_out2));

packet_sender #(.UWIDTH(UWIDTH),.PTR_IN_SZ(PTR_IN_SZ)) packet_sender3 (.clk(clk2),.rst(rst),.rempty(rempty_port_3),.rdata(rdata_port_3),.rinc(rinc_port_3),.packet_valid(packet_valid_o3),.raddr_in(raddr_in_port_3),.packet_out(packet_out3));


endmodule

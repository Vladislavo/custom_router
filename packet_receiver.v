//packet_receiver.v
//Author:Sushma Kakarla, Vladislav Rykov

module packet_receiver#(TS1=8'd0,TS2=8'd1,TS3=8'd2,PTR_IN_SZ = 4,UWIDTH = 8)(input clk1,rst,packet_valid_i,
				  input [(UWIDTH-1):0]pdata,
				  input wfull_port_1,wfull_port_2,wfull_port_3,
                  output reg stop_packet_send, 
				  output reg [(PTR_IN_SZ-1):0]waddr_in_port_1,waddr_in_port_2,waddr_in_port_3,    
                  output reg winc_port_1,winc_port_2,winc_port_3,	
                  output reg [7:0]wdata_port_1,wdata_port_2,wdata_port_3
                  );
 
 parameter  IDLE		=	4'b0000,
			SRC		    =	4'b0001,
			DST		    =	4'b0010,
			SIZE		=	4'b0011,
			DATA		=	4'b0100,
			CRC    	    =	4'b0101,
			sCRC	    =	4'b0110;
			
reg trusted;                                       //To send whole trusted packet into samr port
reg [1:0] dest_p;                                  //Destination port
reg [3:0] present_state, next_state;
reg [7:0] temp1, temp2, temp3;                            //temporary registers for storing input packet data byte 
reg pv_temp1, pv_temp2, pv_temp3;
reg [3:0]x;                                        //variable used for packet size
reg [2:0]k;                                        //variable used for count operation
reg winc_port_1_next, winc_port_2_next, winc_port_3_next;
//reg ocpd;
//-------------------------------------------------------------------------------------------------------------------------------------------
//temp1 logic
 always @(posedge clk1)
 	begin
 		temp1 <=pdata;                                      //temp1 carry present data entered in
 		temp2 <=temp1;                                      //temp2 holds byte stored in register to be sent after delay
 		temp3 <=temp2;                                      //temp2 holds byte stored in register to be sent after delay
                pv_temp1 <= packet_valid_i;
                pv_temp2 <= pv_temp1;
                pv_temp3 <= pv_temp2;
 	end

//--------------------------------------------------------------------------------------------------------------------------------------------
// rst logic for states
always@(posedge clk1 or negedge rst)
	begin
		if(!rst)
		present_state <=IDLE;  
		else
		present_state <=next_state;
	end
//--------------------------------------------------------------------------------------------------------------------------------------------
//reset all regesters
always@(negedge rst)
begin winc_port_1_next=0; winc_port_2_next=0; winc_port_3_next=0; waddr_in_port_1=0;waddr_in_port_2=0;waddr_in_port_3=0;
 trusted=0; dest_p=0; temp1=0; temp2=0; temp3=0; x=0; k=0; pv_temp1 = 0; pv_temp2 = 0; pv_temp3 = 0; stop_packet_send = 0; 
 winc_port_1 = 0; winc_port_2 = 0; winc_port_3 = 0; end //ocpd = 0; end
//--------------------------------------------------------------------------------------------------------------------------------------------
// stop packet send enable and disable block
always@(posedge clk1)
    begin 
        if(wfull_port_1 || wfull_port_2 || wfull_port_3)
             stop_packet_send <=1'b1;
        else stop_packet_send <=1'b0;
    end
//-------------------------------------------------------------------------------------------------------------------------------------------	
always@(present_state or posedge packet_valid_i or k or stop_packet_send)
	begin
     //wdata_port_1=0;wdata_port_2=0;wdata_port_3=0;
     winc_port_1_next=0;winc_port_2_next=0;winc_port_3_next=0; x=0;
		case(present_state)
		IDLE:                                               // decode address state.  
		begin                                               // SRC_ID -> temp1
			if(packet_valid_i==1'b1 && stop_packet_send==1'b0) begin
                waddr_in_port_1=4'b0;waddr_in_port_2=4'b0;waddr_in_port_3=4'b0;  //**********************************
			    next_state=SRC; end                               //load source id to test for trusted source
			else begin
				next_state=IDLE;end	                       // same state
		end
//------------------------------------------------------------------------------------------------------------------------------------------
		SRC: 			                                    // Loading Source id state. 
		begin          	                                            // SRC_ID -> temp2, DST_ID -> temp1
                  /*if (ocpd)
                    case (dest_p)
                      1: begin 
                        wdata_port_1 = temp3; 
                        waddr_in_port_1 = waddr_in_port_1+1;
                      end
                      2: begin
                        wdata_port_2 = temp3;
                        waddr_in_port_2 = waddr_in_port_2+1;
                      end
                      3: begin
                        wdata_port_3 = temp3;
                        waddr_in_port_3 = waddr_in_port_3+1;
                      end
                    endcase
                  */
            	  if (!stop_packet_send) begin  // necessary condition for packets coming with 1 clk period delay
                    trusted = temp2==TS1 || temp2==TS2 || temp2==TS3;
		    next_state = DST;
                  end else 
                    next_state = IDLE;
		end
//-----------------------------------------------------------------------------------------------------------------------------------------
		DST:                                                 // Loading Destination id state 
		begin                                                // SRC_ID -> temp3, DST_ID -> temp2, SIZE -> temp1 
              if (!stop_packet_send) begin // necessary condition of back-to-back packets
                if (trusted) 
                begin
		if((8'd0<=temp2) && (temp2<=8'd127))
                  begin wdata_port_1=temp3;
                  waddr_in_port_1=0;            //******************************************
                  dest_p=1; 
                  next_state=SIZE; end
	        else if((8'd128<=temp2) && (temp2<=8'd195)) 
                  begin wdata_port_2 =temp3;
                  waddr_in_port_2=0;//waddr_in_port_2+1;
                  dest_p=2;
		  next_state=SIZE; end        
                else if((8'd196<=temp2) && (temp2<=8'd255)) 
                  begin wdata_port_3=temp3;
                   waddr_in_port_3=0;//waddr_in_port_3+1;
                  dest_p=3;
		  next_state=SIZE; end
                end else
	 	  next_state=SIZE;
              end else 
                next_state = IDLE;
	 end
//-----------------------------------------------------------------------------------------------------------------------------------------
		SIZE:                                             //Loading Size state
		begin                                             // DST_ID -> temp3, SIZE -> temp2, DATA1 -> temp1
                //ocpd = 0;
                if (dest_p==1 && trusted==1)
                  begin wdata_port_1=temp3;                //Dest id byte is transmitted 
                  waddr_in_port_1=waddr_in_port_1+1;  //*************************************************************                       
                  k= temp2[2:0];                         //K variable is used to know data size and count decrement operation
			      x=k+4;                                //Size of packet is calculated for future use
                  next_state=DATA; end    
                else if (dest_p==2 && trusted==1)
                  begin wdata_port_2=temp3;                   //Dest id byte is transmitted 
                  waddr_in_port_2=waddr_in_port_2+1;
                  k=temp2[2:0];                         //K variable is used to know data size and count decrement operation
	 	          x=k+4;                                //Size of packet is calculated for future use			  	   
                  next_state=DATA; end  
		else if (dest_p==3 && trusted==1)
                  begin wdata_port_3=temp3;                   //Dest id byte is transmitted 
                  waddr_in_port_3=waddr_in_port_3+1;
                  k=temp2[2:0];                         //K variable is used to know data size and count decrement operation
			      x=k+4;                                //Size of packet is calculated for future use      
                  next_state=DATA; end  
                else   
                  begin k=temp2[2:0];                     
			      x=k+4;                             			  	   
                  next_state=DATA; end
                  
		end
//--------------------------------------------------------------------------------------------------------------------------------------------
		DATA:			                                  //Loading data state
		begin
		if (dest_p==1 && trusted==1)
                  begin wdata_port_1=temp3;                 //Size byte is transmitted to memory and later data bytes are transferred
                  waddr_in_port_1=waddr_in_port_1+1;    //************************************************************************
                  //k=k-1;                                    //K is decremented until all data enters into receiver
                  if(k==0) next_state=CRC;                  //If last data byte enters into receiver go to next state
                  else next_state=DATA; end
		else if(dest_p==2 && trusted==1)
                  begin wdata_port_2=temp3;                 //Size byte is transmitted to memory and later data bytes are transferred
                  waddr_in_port_2=waddr_in_port_2+1;
                  //k=k-1;                                    //K is decremented until all data enters into receiver
                  if(k==0) next_state=CRC;                  //If last data byte enters into receiver go to next state
                  else next_state=DATA; end
                else if (dest_p==3 && trusted==1)
                  begin wdata_port_3=temp3;                 //Size byte is transmitted to memory and later data bytes are transferred
                  waddr_in_port_3=waddr_in_port_3+1;
                  //k=k-1;                                    //K is decremented until all data enters into receiver
                  if(k==0) next_state=CRC;                  //If last data byte enters into receiver go to next state
                  else next_state=DATA; end
                else 
                  begin  //k=k-1;                        
                  if(k==0) next_state=CRC;            
                  else next_state=DATA; end
		end
//-------------------------------------------------------------------------------------------------------------------------------------------
		CRC:         	                                   // Loading CRC byte state
		begin                                              // CRC -> temp3,    ?   -> temp2, ? -> temp1
                                                                   // if (pv_temp2) SRC_ID -> temp2      | (!pv_temp2) ? -> temp2
                                                                   // if (pv_temp1) DST_ID -> temp1      | (pv_temp1) SRC_ID -> temp1
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

                next_state = IDLE;
                if (!stop_packet_send) begin
                  if (pv_temp2 && pv_temp1) begin // back-to-back packets
                    trusted = temp2==TS1 || temp2==TS2 || temp2==TS3;
                    next_state = DST;
                  end else if (pv_temp1) begin // incoming packet after 1 clk period 
                    //waddr_in_port_1=4'b0;waddr_in_port_2=4'b0;waddr_in_port_3=4'b0;  //**********************************
                    //ocpd = 1;
                    next_state = SRC;
                  end
                end
        end
//-------------------------------------------------------------------------------------------------------------------------------------------
		default:					                        //default state
				next_state=IDLE; 
 		endcase								              	// state machine completed
    end
  always @(posedge clk1) begin
    if (present_state == DATA) k <= k-1;
    winc_port_1 = winc_port_1_next;
    winc_port_2 = winc_port_2_next;
    winc_port_3 = winc_port_3_next;
  end
endmodule      

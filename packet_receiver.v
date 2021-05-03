//packet_receiver.v
//Author:Sushma Kakarla

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
reg [7:0] temp1, temp2;                            //temporary registers for storing input packet data byte 
reg [3:0]x;                                        //variable used for packet size
reg [2:0]k;                                        //variable used for count operation

//-------------------------------------------------------------------------------------------------------------------------------------------
//temp1 logic
 always @(posedge clk1)
 	begin
 		temp1 <=pdata;                                      //temp1 carry present data entered in
 		temp2 <=temp1;                                      //temp2 holds byte stored in register to be sent after delay
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
begin winc_port_1=0; winc_port_2=0; winc_port_3=0; waddr_in_port_1=0;waddr_in_port_2=0;waddr_in_port_3=0;
 trusted=0; dest_p=0; temp1=0; temp2=0; x=0; k=0;   end
//--------------------------------------------------------------------------------------------------------------------------------------------
// stop packet send enable and disable block
always@(posedge clk1 or negedge rst)
    begin 
        if((wfull_port_1==1'b1)|(wfull_port_2==1'b1)|(wfull_port_3==1'b1))
            stop_packet_send <=1'b1;
        else stop_packet_send <=1'b0;
    end
//-------------------------------------------------------------------------------------------------------------------------------------------	
always@(*)
	begin
     //wdata_port_1=0;wdata_port_2=0;wdata_port_3=0;
     winc_port_1=0;winc_port_2=0;winc_port_3=0; x=0;
		case(present_state)
		IDLE:                                               // decode address state 
		begin
			if(packet_valid_i==1'b1 && stop_packet_send==1'b0) begin
                waddr_in_port_1=4'b0;waddr_in_port_2=4'b0;waddr_in_port_3=4'b0;  //**********************************
			    next_state=SRC; end                               //load source id to test for trusted source
			else begin
                temp1=0;temp2=0;
				next_state=IDLE;end	                        // same state
		end
//------------------------------------------------------------------------------------------------------------------------------------------
		SRC: 			                                    // Loading Source id state
		begin	
            if((temp1==TS1) | (temp1==TS2) | (temp1==TS3))
            begin 
                trusted=1;
                next_state=DST; end
            else begin
                trusted=0; 
                next_state=DST; end

		end
//-----------------------------------------------------------------------------------------------------------------------------------------
		DST:                                                 // Loading Destination id state
		begin 
              if(trusted ==1) 
              begin
			    if((8'd0<=temp1) && (temp1<=8'd127))
                  begin wdata_port_1=temp2;
                  waddr_in_port_1=0;            //******************************************
                  dest_p=1; 
                  next_state=SIZE; end
	            else if((8'd128<=temp1) && (temp1<=8'd195)) 
                  begin wdata_port_2 =temp2;
                   waddr_in_port_2=0;//waddr_in_port_2+1;
                  dest_p=2;
				  next_state=SIZE; end        
                else if((8'd196<=temp1) && (temp1<=8'd255)) 
                  begin wdata_port_3=temp2;
                   waddr_in_port_3=0;//waddr_in_port_3+1;
                  dest_p=3;
				  next_state=SIZE; end
              end
			  else
                //  dest_p=0;
				  next_state=SIZE;
			end
//-----------------------------------------------------------------------------------------------------------------------------------------
		SIZE:                                             //Loading Size state
		begin 
                if (dest_p==1 && trusted==1)
                  begin wdata_port_1=temp2;                //Dest id byte is transmitted 
                  waddr_in_port_1=waddr_in_port_1+1;  //*************************************************************                       
                  k=temp1[2:0];                         //K variable is used to know data size and count decrement operation
			      x=k+4;                                //Size of packet is calculated for future use
                  next_state=DATA; end    
                else if (dest_p==2 && trusted==1)
                  begin wdata_port_2=temp2;                   //Dest id byte is transmitted 
                  waddr_in_port_2=waddr_in_port_2+1;
                  k=temp1[2:0];                         //K variable is used to know data size and count decrement operation
	 	          x=k+4;                                //Size of packet is calculated for future use			  	   
                  next_state=DATA; end  
			    else if (dest_p==3 && trusted==1)
                  begin wdata_port_3=temp2;                   //Dest id byte is transmitted 
                  waddr_in_port_3=waddr_in_port_3+1;
                  k=temp1[2:0];                         //K variable is used to know data size and count decrement operation
			      x=k+4;                                //Size of packet is calculated for future use      
                  next_state=DATA; end  
                else   
                  begin k=temp1[2:0];                     
			      x=k+4;                             			  	   
                  next_state=DATA; end  
		end
//--------------------------------------------------------------------------------------------------------------------------------------------
		DATA:			                                  //Loading data state
		begin
			    if (dest_p==1 && trusted==1)
                  begin wdata_port_1=temp2;                 //Size byte is transmitted to memory and later data bytes are transferred
                  waddr_in_port_1=waddr_in_port_1+1;    //************************************************************************
                  k=k-1;                                    //K is decremented until all data enters into receiver
                  if(k==0) next_state=CRC;                  //If last data byte enters into receiver go to next state
                  else next_state=DATA; end
			    else if(dest_p==2 && trusted==1)
                  begin wdata_port_2=temp2;                 //Size byte is transmitted to memory and later data bytes are transferred
                  waddr_in_port_2=waddr_in_port_2+1;
                  k=k-1;                                    //K is decremented until all data enters into receiver
                  if(k==0) next_state=CRC;                  //If last data byte enters into receiver go to next state
                  else next_state=DATA; end
                else if (dest_p==3 && trusted==1)
                  begin wdata_port_3=temp2;                 //Size byte is transmitted to memory and later data bytes are transferred
                  waddr_in_port_3=waddr_in_port_3+1;
                  k=k-1;                                    //K is decremented until all data enters into receiver
                  if(k==0) next_state=CRC;                  //If last data byte enters into receiver go to next state
                  else next_state=DATA; end
                else 
                  begin  k=k-1;                        
                  if(k==0) next_state=CRC;            
                  else next_state=DATA; end
		end
//-------------------------------------------------------------------------------------------------------------------------------------------
		CRC:         	                                   // Loading CRC byte state
		begin
				if (dest_p==1 && trusted==1)
                  begin wdata_port_1=temp2;                 //Last data byte is transferred to memory 
                  waddr_in_port_1=waddr_in_port_1+1;  //***************************************************************************
				  next_state=sCRC; end
                else if (dest_p==2 && trusted==1)
                  begin wdata_port_2=temp2;                 //Last data byte is transferred to memory
                  waddr_in_port_2=waddr_in_port_2+1; 
				  next_state=sCRC; end
                else if (dest_p==3 && trusted==1)
                  begin wdata_port_3=temp2;                 //Last data byte is transferred to memory 
                  waddr_in_port_3=waddr_in_port_3+1;
				  next_state=sCRC; end
                else next_state=sCRC;                 
        end
//-------------------------------------------------------------------------------------------------------------------------------------------
		sCRC:                                             // transfer CRC state
		begin     
                    if(dest_p==1) begin
                    wdata_port_1=temp2;
                    waddr_in_port_1=waddr_in_port_1+1;
                    winc_port_1=1;
                    end
                    else if(dest_p==2) begin
                      wdata_port_2=temp2;
                      waddr_in_port_2=waddr_in_port_2+1;
                      winc_port_2=1;
                    end
                    else if(dest_p==3) begin 
                      wdata_port_3=temp2;
                      waddr_in_port_3=waddr_in_port_3+1;
                      winc_port_3=1;
                    end        

            if(packet_valid_i==1'b1 && stop_packet_send==1'b0) 
                        begin
                        if((temp1==TS1) | (temp1==TS2) | (temp1==TS3))
                        begin 
                        trusted=1;
                        next_state=DST; end
                        else begin
                        trusted=0; 
                        next_state=DST; end
                        end 
                      else next_state=IDLE;
		end
//--------------------------------------------------------------------------------------------------------------------------------------------
		default:					                        //default state
				next_state=IDLE; 
 		endcase								              	// state machine completed
    end
endmodule      

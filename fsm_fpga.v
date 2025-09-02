// fix reset logic

`timescale 1ns/1ps
module fsm_fpga(
    input clk,
    input rst,
    input Rb,       
    output reg win, lose        
);

reg [2:0] a, b;   
reg [3:0]sum,store_pt;

reg [7:0] lfsr;

always @(posedge clk) begin
    if (rst)
        lfsr <= 8'hA1; 
    else
        lfsr <= {lfsr[6:0], lfsr[7] ^ lfsr[5] ^ lfsr[4] ^ lfsr[3]};
end

function [5:0] roll;
    input [7:0] lfsr_val;
    reg [2:0] d1, d2;
begin
    d1 = (lfsr_val[2:0] % 6) + 1;            
    d2 = ((lfsr_val[5:3]) % 6) + 1;          
    roll = {d1, d2};                         
end
endfunction

parameter s0=3'b000, s1=3'b001, s2=3'b010, s3=3'b011, s4=3'b100, s5=3'b101;
reg [2:0] ps, ns;

always@(posedge clk)
begin
    if(rst) ps<=0;
    else ps<=ns;
end

always@(*)
begin
case(ps)
s0: /////////s0////////
    begin
    if(Rb==0)
    begin
        ns<=s0;
    end
    else if(Rb==1)
    begin 
        ns<=s1;
    end
    end

s1: /////////s1////////
    begin
    if(Rb==1)
    begin
        {a, b} <= roll(lfsr);   // unpack dice values
        sum = a + b;
        ns<=s1;
    end
    else if((Rb==0) && (sum==7 || sum==11))
    begin
        ns<=s2;
    end
    else if((Rb==0) && (sum!=7 && sum!=11) && (sum==2 || sum==3 || sum==12))
    begin
        ns<=s3;
    end
    else if((Rb==0) && (sum!=7 && sum!=11) && (sum!=2 && sum!=3 && sum!=12))
    begin
        store_pt=sum;
        ns<=s4;
    end  
end

s2: /////////s2////////
begin
if(rst) ns<=s0;
else ns<=s2;
end

s3: /////////s3////////
begin
if(rst) ns<=s0;
else ns<=s3;
end

s4: /////////s4////////
begin
    if(Rb==0)
    begin
        ns<=s4;
    end
    else if(Rb==1)
    begin 
        ns<=s5;
    end
    end

s5: /////////s5////////
begin
    if(Rb==1)
        begin
            {a, b} <= roll(lfsr);
            sum = a + b;
            ns<=s5;
        end
    else if((Rb==0) && (sum==store_pt))
        begin
            ns<=s2;
        end
    else if((Rb==0) && (sum!=store_pt) && (sum==7))
        begin
            ns<=s3;
        end
    else if((Rb==0) && (sum!=store_pt) && (sum!=7))
        begin
            ns<=s4;
        end
    
end

default: ns<=s0;
endcase
end

always @(*) begin
        win = (ps==s2);  
        lose = (ps==s3);
end

endmodule
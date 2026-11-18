`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 11/17/2026 06:18:35 PM
// Design Name: 
// Module Name: seven_segment_signed
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////
`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 09/07/2026 11:16:55 PM
// Design Name: 
// Module Name: Four_Digit_Seven_Segment_Driver_Optimized
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////





module seven_segment_signed(
    input clk,
    input [7:0] num, 
    output reg [0:3] anode, 
    output reg [6:0] LED_out
    );
    
    
    

    
     reg [3:0] led_bcd; 
     reg [19:0] refresh_counter=0; 
     wire [1:0] activating_counter; 
     
     
     wire positive;
     wire [7:0] x;
     wire [7:0] v;
     wire [2:0] thousands_bcd;
     wire [3:0] hundreds_bcd;
     wire [3:0] tens_bcd;
     wire [3:0] ones_bcd;
    
    
    
    assign positive = (num[7])? 1'b0: 1'b1;
    
    assign v=num;
    assign x= num[7]? (~v)+1: v;
    
    BCD bcd1(x , thousands_bcd, hundreds_bcd, tens_bcd, ones_bcd);
 
 always @ (posedge clk)
     begin 
         refresh_counter<= refresh_counter+1;
     end 
     
 assign activating_counter = refresh_counter[19:18];
 
 always@ (*) 
 begin 
     case(activating_counter)
     2'b00: begin 
     anode= 4'b0111;
     if(positive)
        led_bcd= 4'b0000;
     else
        led_bcd = 4'b1010;
     end 
     2'b01: begin
     anode= 4'b1011;
      led_bcd= hundreds_bcd;
    end 
    2'b10: begin
     anode= 4'b1101;
      led_bcd= tens_bcd;
    end 
    2'b11: begin
     anode= 4'b1110;
      led_bcd= ones_bcd;
    end 
endcase 
end 

always @(*)
begin
case(led_bcd)
4'b0000: LED_out = 7'b0000001; // "0"
4'b0001: LED_out = 7'b1001111; // "1"
4'b0010: LED_out = 7'b0010010; // "2"
4'b0011: LED_out = 7'b0000110; // "3"
4'b0100: LED_out = 7'b1001100; // "4"
4'b0101: LED_out = 7'b0100100; // "5"
4'b0110: LED_out = 7'b0100000; // "6"
4'b0111: LED_out = 7'b0001111; // "7"
4'b1000: LED_out = 7'b0000000; // "8"
4'b1001: LED_out = 7'b0000100; // "9"
4'b1010: LED_out = 7'b1111110; // minus sign
default: LED_out = 7'b0000001; // "0"
endcase
end

endmodule

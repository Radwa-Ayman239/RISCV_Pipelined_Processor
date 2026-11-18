`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 11/17/2026 02:15:56 PM
// Design Name: 
// Module Name: RISCV_pipeline_TopModule
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


module RISCV_pipeline_TopModule(
    input rclk,
    input reset,
    input [1:0] ledSel,
    input [3:0] ssdSel,
    input ssdClk,

    output [15:0] leds,
    output [0:3] anode,
    output [6:0] LED_out
);

wire [12:0] ssdData;

RISCV_pipeline cpu (
    .clk(rclk),
    .rst(reset),
    .ledSel(ledSel),
    .ssdSel(ssdSel),
    .leds(leds),
    .ssdData(ssdData)
);


seven_segment_signed du (   // we need to add the signed
    .clk(ssdClk),
    .num(ssdData),
    .anode(anode),
    .LED_out(LED_out)
);

endmodule

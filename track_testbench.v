`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2022/01/06 19:56:07
// Design Name: 
// Module Name: track_testbench
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


module track_testbench;
reg clk_100=0;
wire clk_65;
wire clk_12;
wire locked;
wire [15:0]debugled;

always #1 clk_100<=~clk_100;
    wire [639:0] track0;
    wire [639:0] track1;
    wire [639:0] track2;
    wire [639:0] track3;
    wire [639:0] track4;
    wire [639:0] track5;
    wire [639:0] track6;


clk_wiz_0 uuuuut(
    .reset(1'b0),
    .clk_in1(clk_100),
    .clk_out1(clk_65),
    .clk_out2(clk_12),
    .locked(locked)
);

track_control uuuu(
    .clk(clk_65),
    .rst(locked),
    .track0(track0),
    .track1(track1),
    .track2(track2),
    .track3(track3),
    .track4(track4),
    .track5(track5),
    .track6(track6),
    .debugled(debugled)
);

endmodule

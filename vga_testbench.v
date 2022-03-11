`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2022/01/05 22:14:50
// Design Name: 
// Module Name: vga_testbench
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


module vga_testbench;
    reg   clk_100;               //100Mhz
    reg   rst;                    //复位
    wire [3:0]    color_r;    //R
    wire [3:0]    color_g;    //G
    wire [3:0]    color_b;    //B
    wire [11:0] x,y;
    wire          hs;         //行同�??
    wire          vs;          //场同�??
    initial begin
        clk_100<=0;
        rst<=1;
    end
    
    always #1 clk_100 <= ~clk_100;
    //时钟
    wire clk_65,clk_12,locked;
    //分频�??
    clk_wiz_0 uut(
        .reset(~rst),
        .locked(locked),
        .clk_in1(clk_100),
        .clk_out1(clk_65),
        .clk_out2(clk_12)
    );

    //VGA
    vga uut_vga(
        .clk(clk_65),
        .rst(locked),
        .color_r(color_r),
        .color_g(color_g),
        .color_b(color_b),
        .hs(hs),
        .vs(vs)
    );
endmodule

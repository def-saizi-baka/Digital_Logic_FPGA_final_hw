`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2022/01/05 21:36:27
// Design Name: 
// Module Name: VGA_TOP
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


module GAME_TOP(
    input   clk_100,               //100Mhz
    //键盘
    input   key_clk,                //键盘时钟
    input   key_data,              //键盘输入数据
    //复位控制
    input   rst,                    //复位
    input   rst_track,              //轨道复位
    //VGA
    input [3:0] music_id,      //第几首歌
    output [3:0]    color_r,    //R
    output [3:0]    color_g,    //G
    output [3:0]    color_b,    //B
    output              hs,         //行同??
    output              vs,         //场同??
    //七段数码管
    output [7:0] shift,
    output [6:0] oData,
    //MP3
    input        SO,             //传出
    input        DREQ,           //数据请求，高电平时可传输数据
    output      XCS,            //片???SCI 传输读???写指令
    output      XDCS,           //片???SDI 传输数据
    output      SCK,            //时钟
    output      SI,             //传入mp3
    output  XRESET,         //硬件复位，低电平有效
    output [15:0]  debugled
    );
    //时钟
    wire clk_65,clk_12,clk_1000,clk_2,locked;
    //键盘输入
    wire [8:0] keys;
    wire key_state;
    //得分
    wire [31:0] score;

    //分频1
    clk_wiz_0 uut(
        .reset(~rst),
        .locked(locked),
        .clk_in1(clk_100),
        .clk_out1(clk_65),
        .clk_out2(clk_12)
    );
    //分频器2
    Divider uut_divider(
        .clk12Mhz(clk_12),
        .clk1000hz(clk_1000),
        .clk2Mhz(clk_2)
    );

    //VGA
    vga uut_vga(
        .clk(clk_65),
        .rst(locked),
        .rst_track(rst_track),
        .music_id(music_id),
        .keys(keys),
        .key_state(key_state),
        .color_r(color_r),
        .color_g(color_g),
        .color_b(color_b),
        .hs(hs),
        .vs(vs),
        .score(score),
        .debugled(debugled)
    );

    //MP3
    mp3board uut_mp3(
        .clk(clk_2),
        .rst(rst),
        .play(rst_track),
        .SO(SO),
        .DREQ(DREQ),
        .XCS(XCS),
        .XDCS(XDCS),
        .SCK(SCK),
        .SI(SI),
        .XRESET(XRESET),
        .music_id(music_id)
    );
    
    //键盘
    keyboard uut_keyboard(
        .clk_in(clk_100),
        .rst(rst),
        .key_clk(key_clk),
        .key_data(key_data),
        .key_state(key_state),
        .key_ascii(keys)
    );

    //数码管显示分数
    display_score uut_score(
        .clk_1000hz(clk_1000),
        .score(score),
        .shift(shift),//第几个数码管(片选)
        .oData(oData)
    );

endmodule

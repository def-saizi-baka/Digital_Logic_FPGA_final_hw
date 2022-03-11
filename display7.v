`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2022/01/07 19:42:00
// Design Name: 
// Module Name: display7
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


//BCD转换
module Bin2BCD(
    input   [31:0]      number,     //数字
    output [3:0] bcd0,
    output [3:0] bcd1,
    output [3:0] bcd2,
    output [3:0] bcd3,
    output [3:0] bcd4,
    output [3:0] bcd5,
    output [3:0] bcd6,
    output [3:0] bcd7
    );

    reg [31:0]  bin;
    reg [31:0]  result;
    reg [31:0]  bcd;
    //转换为BCD码
    always @(number) begin
        bin = number[31:0];
        result = 32'd0;
        repeat (31)             
        begin
            result[0] = bin[31];
            if (result[3:0] > 4)
                result[3:0] = result[3:0] + 4'd3;
            else
                result[3:0] = result[3:0];
            if (result[7:4] > 4)
                result[7:4] = result[7:4] + 4'd3;
            else
                result[7:4] = result[7:4];
            if (result[11:8] > 4)
                result[11:8] = result[11:8] + 4'd3;
            else
                result[11:8] = result[11:8];
            if (result[15:12] > 4)
                result[15:12] = result[15:12] + 4'd3;
            else
                result[15:12] = result[15:12];
            if (result[19:16] > 4)
                result[19:16] = result[19:16] + 4'd3;
            else
                result[19:16] = result[19:16];
                
            if (result[23:20] > 4)
                result[23:20] = result[23:20] + 4'd3;
            else
                result[23:20] = result[23:20];

            if (result[27:24] > 4)
                result[27:24] = result[27:24] + 4'd3;
            else
                result[27:24] = result[27:24];
            if (result[31:28] > 4)
                result[31:28] = result[31:28] + 4'd3;
            else
                result[31:28] = result[31:28];
            result = result << 1;
            bin = bin << 1;
        end
        result[0] = bin[31];
        bcd = result;
    end

    assign bcd0 = bcd[3:0];
    assign bcd1 = bcd[7:4];
    assign bcd2 = bcd[11:8];
    assign bcd3 = bcd[15:12];
    assign bcd4 = bcd[19:16];
    assign bcd5 = bcd[23:20];
    assign bcd6 = bcd[27:24];
    assign bcd7 = bcd[31:28];
endmodule

module display_score(
    input clk_1000hz,
    input [31:0] score,
    output reg [7:0] shift,//第几个数码管(片选)
    output reg [6:0] oData
);
wire [3:0] Data[7:0];
reg [3:0] cnt=0;//计数器
//转换为BCD
Bin2BCD uut_bin2bcd(
    .number(score),
    .bcd0(Data[0]),
    .bcd1(Data[1]),
    .bcd2(Data[2]),
    .bcd3(Data[3]),
    .bcd4(Data[4]),
    .bcd5(Data[5]),
    .bcd6(Data[6]),
    .bcd7(Data[7])
);
//片选输出
always@(posedge clk_1000hz)begin
    if(cnt == 4'd8)
        cnt <= 0;
    else
        cnt <= cnt + 1;
    shift <= 8'b1111_1111;
    shift[cnt]<=0;//选择一个数码管进行输出
    case (Data[cnt])
        4'b0000: oData <= 7'b1000000;
        4'b0001: oData <= 7'b1111001;
        4'b0010: oData <= 7'b0100100;
        4'b0011: oData <= 7'b0110000;
        4'b0100: oData <= 7'b0011001;
        4'b0101: oData <= 7'b0010010;
        4'b0110: oData <= 7'b0000010;
        4'b0111: oData <= 7'b1111000;
        4'b1000: oData <= 7'b0000000;
        4'b1001: oData <= 7'b0010000;
        default: oData <= 7'b1111111;
    endcase
end
endmodule

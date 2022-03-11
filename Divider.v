`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2022/01/07 20:49:22
// Design Name: 
// Module Name: Divider
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


// ·ÖÆµÆ÷
module Divider(
    input clk12Mhz,
    output reg clk2Mhz = 0,
    output reg clk1000hz = 0
    );
    integer cnt1 = 32'd0;
    integer cnt2 = 32'd0;
    always @(posedge clk12Mhz) begin
        if (cnt1 < 6 / 2 - 1)
            cnt1 <= cnt1 + 1'b1;
        else begin
            cnt1 <= 32'd0;
            clk2Mhz <= ~clk2Mhz;
        end

        if (cnt2 < 12288 / 2 - 1)
            cnt2 <= cnt2 + 1'b1;
        else begin
            cnt2 <= 32'd0;
            clk1000hz <= ~clk1000hz;
        end
    end
endmodule

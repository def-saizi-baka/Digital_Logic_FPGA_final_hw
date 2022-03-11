`timescale 1ns / 1ns
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2021/12/20 20:11:43
// Design Name: 
// Module Name: vga
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



module track_control(
    input clk,      //65Mhz
    input rst,         //??¦Ë,??????§¹
    input key_state,   //?????????
    input [7:0] keys,  //????????ASCII??
    input [3:0] music_id,//???????
    output reg [639:0] track0,
    output reg [639:0] track1,
    output reg [639:0] track2,
    output reg [639:0] track3,
    output reg [639:0] track4,
    output reg [639:0] track5,
    output reg [639:0] track6,
    output reg [3:0] msg,
    output [31:0] score,
    output [15:0]  debugled
);
reg [11:0] addra=12'd0;
//???????????
wire [6:0] douta;
wire [6:0] douta0;
wire [6:0] douta1;
wire [6:0] douta2;
wire [6:0] douta3;
wire [6:0] douta4;
//??????
reg [31:0] cntDouta=0;//?????????????
reg [31:0] cntMove=0;//?§Ø????????
reg [31:0] cntMsg=0;//???????
//????
reg [31:0] score0=0;
reg [31:0] score1=0;
reg [31:0] score2=0;
reg [31:0] score3=0;
reg [31:0] score4=0;
reg [31:0] score5=0;
reg [31:0] score6=0;
assign score = score0+score1+score2+score3+score4+score5+score6;
//??????????
reg [3:0] pre_id=0;

reg hold=0;//?§Ø?????????
reg [31:0] hold_cnt=0;//?§Ø?????????
reg [6:0] track_data=0;//????????
//??????
reg [31:0] speedRead = 140;  //????????
reg [31:0] speedDown = 83000;    //???????
//?????????
always@(music_id) begin
    case (music_id)
        4'd0 : begin
            speedRead<=140;
            speedDown<=83000;
        end
        4'd1 : begin
            speedRead<=140;
            speedDown<=83000;
        end
        4'd2 : begin
            speedRead<=140;
            speedDown<=83000;
        end
        4'd3 : begin
            speedRead<=110;
            speedDown<=42000;
        end
        4'd4 : begin
            speedRead<=140;
            speedDown<=83000;
        end
    default: begin
            speedRead<=140;
            speedDown<=83000;
    end
    endcase
end

always @(posedge clk) begin
    if(!rst || pre_id!=music_id) begin
        pre_id <= music_id;
        msg <= 4'd7;
        score0 <= 32'd0;score1 <= 32'd0;score2 <= 32'd0;score3 <= 32'd0;
        score4 <= 32'd0;score5 <= 32'd0;score6 <= 32'd0;
        track0 <= 640'd0; track1 <= 640'd0; track2 <= 640'd0; track3 <= 640'd0;
        track4 <= 640'd0; track5 <= 640'd0; track6 <= 640'd0;
        addra <= 12'd0;
        cntDouta<=0;
        cntMove<=0;
        cntMsg<=0;
    end
    else begin
        //??????
        if(cntDouta == speedRead) begin
            addra <= addra+1;
            cntDouta<=32'd0;
            track0[63:0]<=(douta[0]) ? 64'hffffffff_ffffffff:64'd0;
            track1[63:0]<=(douta[1]) ? 64'hffffffff_ffffffff:64'd0;
            track2[63:0]<=(douta[2]) ? 64'hffffffff_ffffffff:64'd0;
            track3[63:0]<=(douta[3]) ? 64'hffffffff_ffffffff:64'd0;
            track4[63:0]<=(douta[4]) ? 64'hffffffff_ffffffff:64'd0;
            track5[63:0]<=(douta[5]) ? 64'hffffffff_ffffffff:64'd0;
            track6[63:0]<=(douta[6]) ? 64'hffffffff_ffffffff:64'd0;
        end
        else if(cntMove==speedDown) begin
            cntMove <= 32'd0;
            cntDouta <= cntDouta+1;
            //miss
            if((track0[639]&&!track0[638])||(track1[639]&&!track1[638])||(track2[639]&&!track2[638])||
                (track3[639]&&!track3[638])||(track4[639]&&!track4[638])||(track5[639]&&!track5[638])||
                (track6[639]&&!track6[638])) begin
                msg <= 4'd0;cntMsg<=0;
            end

            //????????????
            track0 <= track0 << 1;
            track1 <= track1 << 1;
            track2 <= track2 << 1;
            track3 <= track3 << 1;
            track4 <= track4 << 1;
            track5 <= track5 << 1;
            track6 <= track6 << 1;
        end
            //????§Þ???????
        else if(key_state) begin
            cntMove <= cntMove+1;
            hold_cnt<=hold_cnt+1;
            if(hold_cnt >= 2000000) hold <= 1;
            //????,???????????§Ø?
            if(hold==0) begin
                if(keys==8'h5a&&(track0[639]||track0[609]||track0[629])) begin
                    if(track0[629] && track0[639]) begin //pure
                        score0 <= score0 + 100; 
                        msg<=4'd3;
                    end
                    else if((track0[609]&&track0[629])||track0[639]) begin //far
                        score0 <= score0 + 50; 
                        msg<=4'd2;
                    end
                    else if(track0[609]) begin  //bad
                        score0 <= score0 + 20; 
                        msg<=4'd1;
                    end
                    track0[639:546]<=94'd0;cntMsg<=0; //??????????
                end
                else if(keys==8'h58&&(track1[639]||track1[609]||track1[629]))begin
                    if(track1[629] && track1[639]) begin //pure
                        score1 <= score1 + 100; 
                        msg<=4'd3;
                    end
                    else if((track1[609]&&track1[629])||track1[639]) begin //far
                        score1 <= score1 + 50; 
                        msg<=4'd2;
                    end
                    else if(track1[609]) begin  //bad
                        score1 <= score1 + 20; 
                        msg<=4'd1;
                    end
                    track1[639:546]<=94'd0;cntMsg<=0;
                end
                else if(keys==8'h43&&(track2[639]||track2[609]||track2[629]))begin
                    if(track2[629] && track2[639]) begin //pure
                        score2 <= score2 + 100; 
                        msg<=4'd3;
                    end
                    else if((track2[609]&&track2[629])||track2[639]) begin //far
                        score2 <= score2 + 50; 
                        msg<=4'd2;
                    end
                    else if(track2[609]) begin  //bad
                        score2 <= score2 + 20; 
                        msg<=4'd1;
                    end
                    track2[639:546]<=94'd0;cntMsg<=0;
                end
                else if(keys==8'h56&&(track3[639]||track3[609]||track3[629]))begin
                    if(track3[629] && track3[639]) begin //pure
                        score3 <= score3 + 100; 
                        msg<=4'd3;
                    end
                    else if((track3[609]&&track3[629])||track3[639]) begin //far
                        score3 <= score3 + 50; 
                        msg<=4'd2;
                    end
                    else if(track3[609]) begin  //bad
                        score3 <= score3 + 20; 
                        msg<=4'd1;
                    end
                    track3[639:546]<=94'd0;cntMsg<=0;
                end
                else if(keys==8'h42&&(track4[639]||track4[609]||track4[629]))begin
                    if(track4[629] && track4[639]) begin //pure
                        score4 <= score4 + 100; 
                        msg<=4'd3;
                    end
                    else if((track4[609]&&track4[629])||track4[639]) begin //far
                        score4 <= score4 + 50; 
                        msg<=4'd2;
                    end
                    else if(track4[609]) begin  //bad
                        score4 <= score4 + 20; 
                        msg<=4'd1;
                    end
                    track4[639:546]<=94'd0;cntMsg<=0;
                end
                else if(keys==8'h4e&&(track5[639]||track5[609]||track5[629]))begin
                    if(track5[629] && track5[639]) begin //pure
                        score5 <= score5 + 100; 
                        msg<=4'd3;
                    end
                    else if((track5[609]&&track5[629])||track5[639]) begin //far
                        score5 <= score5 + 50; 
                        msg<=4'd2;
                    end
                    else if(track5[609]) begin  //bad
                        score5 <= score5 + 20; 
                        msg<=4'd1;
                    end
                    track5[639:546]<=94'd0;cntMsg<=0;
                end
                else if(keys==8'h4d&&(track6[639]||track6[609]||track6[629]))begin
                    if(track6[629] && track6[639]) begin //pure
                        score6 <= score6 + 100; 
                        msg<=4'd3;
                    end
                    else if((track6[609]&&track6[629])||track6[639]) begin //far
                        score6 <= score6 + 50; 
                        msg<=4'd2;
                    end
                    else if(track6[609]) begin  //bad
                        score6 <= score6 + 20; 
                        msg<=4'd1;
                    end
                    track6[639:546]<=94'd0;cntMsg<=0;
                end
            end
        end
        else begin
            hold<=0;
            hold_cnt<=0;
            cntMove <= cntMove+1;
        end

        if(cntMsg>=50000000) begin
            cntMsg<=0;
            msg<=4'd7;//????
            end
        else 
            cntMsg<=cntMsg+1;
    end

end

assign debugled[11:0] = score[11:0];
assign debugled[15:12] = msg[3:0];
assign douta = track_data;

always @(posedge clk) begin
    case (music_id)
        4'd0 : track_data<=douta0;
        4'd1 : track_data<=douta1;
        4'd2 : track_data<=douta2;
        4'd3 : track_data<=douta3;
        4'd4 : track_data<=douta4;
    default: track_data<=0;
    endcase

end
blk_mem_gen_track track_mem0(
    .clka(clk),
    .addra(addra),
    .douta(douta0)
);

blk_mem_gen_track1 track_mem1(
    .clka(clk),
    .addra(addra),
    .douta(douta1)
);

blk_mem_gen_track2 track_mem2(
    .clka(clk),
    .addra(addra),
    .douta(douta2)
);

blk_mem_gen_track3 track_mem3(
    .clka(clk),
    .addra(addra),
    .douta(douta3)
);

blk_mem_gen_track4 track_mem4(
    .clka(clk),
    .addra(addra),
    .douta(douta4)
);

endmodule
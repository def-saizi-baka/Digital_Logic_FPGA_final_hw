`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2022/01/08 00:55:15
// Design Name: 
// Module Name: MP3
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

//mp3
module mp3board(
    input clk,                  //12.288/6MHZ时钟

    input       rst,
    input       play,           //开始播放始播放请求

    input       SO,             //传出
    input       DREQ,           //数据请求，高电平时可传输数据
    input       [3:0]music_id,       //第几首歌
    output reg  XCS,            //SCI 传输读写指令
    output reg  XDCS,           //SDI 传输数据
    output      SCK,            //时钟
    output reg  SI,             //传入mp3
    output reg  XRESET         //硬件复位，低电平有效
    );
    parameter   H_RESET     = 4'd0,         //硬复位
                S_RESET     = 4'd1,         //软复位
                SET_CLOCKF  = 4'd2,         //设置时钟寄存器
                SET_BASS    = 4'd3,         //设置音调寄存器
                SET_VOL     = 4'd4,         //设置音量
                WAITE       = 4'd5,         //等待
                PLAY        = 4'd6,         //播放
                END         = 6'd7;         //结束
    

    reg [3:0]       state       = WAITE;            //状态
    reg [31:0]      cntdown     = 32'd0;            //延时
    reg [31:0]      cmd       = 32'd0;            //指令与地 
    reg [7:0]       cntData   = 8'd32;            //SCI指令地址位数计数

    reg [31:0]      music_data     = 32'd0;           //音乐数据
    reg [31:0]      cntSended     = 32'd32;           //SDI当前4字节已传送BIT

    reg [16:0]      addra       = 16'd0;            //ROM中的地址
    wire [31:0]     data0;                          //ROM传出
    wire [31:0]     data1;  
    wire [31:0]     data2;  
    wire [31:0]     data3;  
    wire [31:0]     data4;  
    reg             ena         = 0;
    reg             [3:0]pre_id = 0;
    
    assign SCK = (clk & ena);
    //速度控制
    reg [31:0] mp3Speed=1700000;//延迟
    always @(music_id) begin
        case (music_id)
            4'd0 : begin
                mp3Speed <= 1700000;
            end
            4'd1 : begin
                mp3Speed <= 1700000;
            end
            4'd2 : begin
                mp3Speed <= 1700000;
            end
            4'd3 : begin
                mp3Speed <= 600000;
            end
            4'd4 : begin
                mp3Speed <= 1700000;
            end
        default: begin
                mp3Speed <= 1700000;
        end
        endcase
    end

    always @(negedge clk) begin
        if(!rst || pre_id!=music_id) begin
            pre_id <= music_id;
            XDCS <= 1'b1;
            ena <= 0;
            SI <= 1'b0;
            XCS <= 1'b1;
            state <= WAITE;
            XRESET <= 1'b1;
            addra <= 17'd0;
            cntSended <= 32'd32;
            music_data <= 32'd0;
        end
        else begin
            case (state)
                /*----------------等待---------------*/
                WAITE:begin
                if(cntdown > 0)
                    cntdown <= cntdown - 1'b1;
                //转到硬复位
                else begin
                    cntdown <= 32'd1000;
                    state <= H_RESET;
                end
                end
                /*-----------------硬复------------------*/
                H_RESET:begin
                if(cntdown > 0)
                    cntdown <= cntdown - 1'b1;
                else begin
                    XCS <= 1'b1;
                    XRESET <= 1'b0;
                    cntdown <= 32'd16700;               //复位后延时一段时

                    state <= S_RESET;                   //转移到软复位
                    cmd <= 32'h02_00_08_04;            //软复位指
                    cntData <= 8'd32;                 //指令、地、数据长度
                end
                end
                /*------------------软复-----------------*/
                S_RESET:begin
                if(cntdown > 0) begin
                    XRESET <= (cntdown < 32'd16650);
                    cntdown <= cntdown - 1'b1;
                end
                else if(cntData == 0) begin           //软复位结
                    cntdown <= 32'd16600;

                    state <= SET_VOL;                   //转移到设置VOL
                    cmd <= 32'h02_0b_00_00;
                    cntData <= 8'd32;

                    XCS <= 1'b1;                        //拉高XCS
                    ena <= 1'b0;                        //关闭输入时钟
                    SI <= 1'b0;
                end
                else if(DREQ) begin                     //当DREQ有效时开始软复位
                    XCS <= 1'b0;
                    ena <= 1'b1;
                    SI <= cmd[cntData - 1];
                    cntData <= cntData - 1'b1;
                end
                else begin
                    XCS <= 1'b1;                        //DREQ无效时继续等
                    ena <= 1'b0;
                    SI <= 1'b0;
                end 
                end            

                /*----------播放音乐----------*/
                PLAY:begin
                if(cntdown > 0)
                    cntdown <= cntdown - 1'b1;
                else if(play)begin
                    XDCS <= 1'b0;
                    ena <= 1'b1;
                    if(cntSended == 0) begin              //传输4字节
                        XDCS <= 1'b1;                   //拉高XDCS
                        ena <= 1'b0;
                        SI <= 1'b0;
                        cntSended <= 32'd32;
                        case (music_id)
                            4'b0:music_data <= data0;
                            4'd1:music_data <= data1;
                            4'd2:music_data <= data2;
                            4'd3:music_data <= data3;
                            4'd4:music_data <= data4;
                        default :;
                        endcase
                        addra <= addra + 1'b1;
                    end
                    else begin
                        //当DREQ有效 或当前字节尚未发送完 则继续传
                        if(DREQ || (cntSended != 32 && cntSended != 24 && cntSended != 16 && cntSended != 8)) begin
                            SI <= music_data[cntSended - 1];
                            cntSended <= cntSended - 1'b1; 
                            ena <= 1;
                            XDCS <= 1'b0;
                        end
                        else begin      //DREQ拉低，停止传
                            ena <= 1'b0;
                            XDCS <= 1'b1;
                            SI <= 1'b0;
                        end
                    end
                end
                else;                                           
                end
                /*---------------------寄存器配------------------*/
                default:
                if(cntdown > 0)
                    cntdown <= cntdown - 1'b1;
                else if(cntData == 0) begin           //结束次SCI写入
                    if(state == SET_CLOCKF) begin
                        cntdown <= mp3Speed;//32'd1700000;
                        state <= PLAY;
                    end
                    else if(state == SET_BASS) begin
                        cntdown <= 32'd2100;
                        cmd <= 32'h02_03_70_00;
                        state <= SET_CLOCKF;
                    end
                    else begin //SET_VAL
                        cntdown <= 32'd2100;
                        cmd <= 32'h02_02_00_00;
                        state <= SET_BASS;
                    end
                    cntData <= 8'd32;
                    XCS <= 1'b1;
                    ena <= 1'b0;
                    SI <= 1'b0;
                end
                else if(DREQ) begin                     //写入SCI指令、地、数
                    XCS <= 1'b0;
                    ena <= 1'b1;
                    SI <= cmd[cntData - 1];
                    cntData <= cntData - 1'b1;
                end
                else begin                              //DREQ拉低，等
                    XCS <= 1'b1;
                    ena <= 1'b0;
                    SI <= 1'b0;
                end
            endcase
        end
    end

    blk_mem_gen_0 id_0_wings_of_piano (
    .clka(clk),             // 时钟
    .addra(addra),          // 地址
    .douta(data0)           // 数据输出
    );

    blk_mem_gen_1 id_1_paper_plane (
    .clka(clk),             // 时钟
    .addra(addra),          // 地址
    .douta(data1)           // 数据输出
    );

    blk_mem_gen_2 id_2_pure (
    .clka(clk),             // 时钟
    .addra(addra),          // 地址
    .douta(data2)           // 数据输出
    );

    blk_mem_gen_3 id_3_lady (
    .clka(clk),             // 时钟
    .addra(addra),          // 地址
    .douta(data3)           // 数据输出
    );

    blk_mem_gen_4 id_4_Beyond (
    .clka(clk),             // 时钟
    .addra(addra),          // 地址
    .douta(data4)           // 数据输出
    );
    
endmodule

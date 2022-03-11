`timescale 1ns / 1ps



module keyboard//将键盘键码转化为ASCII码
(
input					clk_in,				//系统时钟
input					rst,			//系统复位，低有效
input					key_clk,			//PS2键盘时钟输入
input					key_data,			//PS2键盘数据输入
output	reg				key_state,			//键盘的按下状态，按下置1，松开置0
output	reg		[7:0]	key_ascii			//按键键值对应的ASCII编码
);

reg		key_clk_r0 = 1'b1,key_clk_r1 = 1'b1; 
reg		key_data_r0 = 1'b1,key_data_r1 = 1'b1;
//对键盘时钟数据信号进行延时锁存
always @ (posedge clk_in or negedge rst) begin
	if(!rst) begin
		key_clk_r0 <= 1'b1;
		key_clk_r1 <= 1'b1;
		key_data_r0 <= 1'b1;
		key_data_r1 <= 1'b1;
	end else begin
		key_clk_r0 <= key_clk;
		key_clk_r1 <= key_clk_r0;
		key_data_r0 <= key_data;
		key_data_r1 <= key_data_r0;
	end
end
 
//键盘时钟信号下降沿检测
wire	key_clk_neg = key_clk_r1 & (~key_clk_r0); 
 
reg				[3:0]	cnt; 
reg				[7:0]	temp_data;
//根据键盘的时钟信号的下降沿读取数据
always @ (posedge clk_in or negedge rst) begin
	if(!rst) begin
		cnt <= 4'd0;
		temp_data <= 8'd0;
	end else if(key_clk_neg) begin 
		if(cnt >= 4'd10) cnt <= 4'd0;
		else cnt <= cnt + 1'b1;
		case (cnt)
			4'd0: ;	//起始位
			4'd1: temp_data[0] <= key_data_r1;  //数据位bit0
			4'd2: temp_data[1] <= key_data_r1;  //数据位bit1
			4'd3: temp_data[2] <= key_data_r1;  //数据位bit2
			4'd4: temp_data[3] <= key_data_r1;  //数据位bit3
			4'd5: temp_data[4] <= key_data_r1;  //数据位bit4
			4'd6: temp_data[5] <= key_data_r1;  //数据位bit5
			4'd7: temp_data[6] <= key_data_r1;  //数据位bit6
			4'd8: temp_data[7] <= key_data_r1;  //数据位bit7
			4'd9: ;	//校验位
			4'd10:;	//结束位
			default: ;
		endcase
	end
end
 
reg						key_break = 1'b0;   
reg				[7:0]	key_byte = 1'b0;
//根据通码和断码判定按键的当前是按下还是松开
always @ (posedge clk_in or negedge rst) begin 
	if(!rst) begin
		key_break <= 1'b0;
		key_state <= 1'b0;
		key_byte <= 1'b0;
	end else if(cnt==4'd10 && key_clk_neg) begin 
		if(temp_data == 8'hf0) key_break <= 1'b1;	//收到断码（8'hf0）表示按键松开，下一个数据为断码，设置断码标示为1
		else if(!key_break) begin 	//当断码标示为0时，表示当前数据为按下数据，输出键值并设置按下标示为1
			key_state <= 1'b1;
			key_byte <= temp_data; 
		end else begin	//当断码标示为1时，标示当前数据为松开数据，断码标示和按下标示都清0
			key_state <= 1'b0;
			key_break <= 1'b0;
			key_byte<=0;
		end
	end
end
 
//将键盘返回的有效键值转换为按键字母对应的ASCII码
always @ (key_byte) begin
	case (key_byte)    //translate key_byte to key_ascii
		8'h75: key_ascii <= 8'd1;//上箭头
		8'h72: key_ascii <= 8'd2;//下箭头
		8'h6b: key_ascii <= 8'd3;//左箭头
		8'h74: key_ascii <= 8'd4;//右箭头
		8'h5a: key_ascii <= 8'd13;   //回车
		8'h1a: key_ascii <= 8'h5a;   //Z
		8'h22: key_ascii <= 8'h58;   //X
		8'h21: key_ascii <= 8'h43;   //C
		8'h2a: key_ascii <= 8'h56;   //V
		8'h32: key_ascii <= 8'h42;   //B
		8'h31: key_ascii <= 8'h4e;   //N
		8'h3a: key_ascii <= 8'h4d;   //M
		default: key_ascii=0;		//nothing
	endcase
end
 
endmodule
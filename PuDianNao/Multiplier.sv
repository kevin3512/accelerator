module Multiplier#(parameter WIDTH = 32)(
    input[WIDTH-1:0]        hot_in[15:0],        
    input[WIDTH-1:0]        cold_in[15:0],
    input[WIDTH-1:0]        pre_data[15:0],    //从Adder层过来的数据
    input[7:0]              shift_right,     //数据右移
    input                   sel_in,         //选择直接从hotBuff或者coldBuff过来的(选1)，还是上一层过来的数据(选0)
    output[WIDTH-1:0]       out[15:0]
);

wire[WIDTH-1:0]     mul1[15:0];
wire[WIDTH-1:0]     mul2[15:0];
reg[WIDTH-1:0]      out[15:0];
wire[WIDTH-1:0]     cal_out[15:0];

sel_2 sel_ins0_0(.in1(hot_in[0]), .in2(pre_data[0]), .sel(sel_in), .out(mul1[0]));
sel_2 sel_ins0_1(.in1(hot_in[1]), .in2(pre_data[1]), .sel(sel_in), .out(mul1[1]));
sel_2 sel_ins0_2(.in1(hot_in[2]), .in2(pre_data[2]), .sel(sel_in), .out(mul1[2]));
sel_2 sel_ins0_3(.in1(hot_in[3]), .in2(pre_data[3]), .sel(sel_in), .out(mul1[3]));
sel_2 sel_ins0_4(.in1(hot_in[4]), .in2(pre_data[4]), .sel(sel_in), .out(mul1[4]));
sel_2 sel_ins0_5(.in1(hot_in[5]), .in2(pre_data[5]), .sel(sel_in), .out(mul1[5]));
sel_2 sel_ins0_6(.in1(hot_in[6]), .in2(pre_data[6]), .sel(sel_in), .out(mul1[6]));
sel_2 sel_ins0_7(.in1(hot_in[7]), .in2(pre_data[7]), .sel(sel_in), .out(mul1[7]));
sel_2 sel_ins0_8(.in1(hot_in[8]), .in2(pre_data[8]), .sel(sel_in), .out(mul1[8]));
sel_2 sel_ins0_9(.in1(hot_in[9]), .in2(pre_data[9]), .sel(sel_in), .out(mul1[9]));
sel_2 sel_ins0_10(.in1(hot_in[10]), .in2(pre_data[10]), .sel(sel_in), .out(mul1[10]));
sel_2 sel_ins0_11(.in1(hot_in[11]), .in2(pre_data[11]), .sel(sel_in), .out(mul1[11]));
sel_2 sel_ins0_12(.in1(hot_in[12]), .in2(pre_data[12]), .sel(sel_in), .out(mul1[12]));
sel_2 sel_ins0_13(.in1(hot_in[13]), .in2(pre_data[13]), .sel(sel_in), .out(mul1[13]));
sel_2 sel_ins0_14(.in1(hot_in[14]), .in2(pre_data[14]), .sel(sel_in), .out(mul1[14]));
sel_2 sel_ins0_15(.in1(hot_in[15]), .in2(pre_data[15]), .sel(sel_in), .out(mul1[15]));

sel_2 sel_ins1_0(.in1(cold_in[0]), .in2(pre_data[0]), .sel(sel_in), .out(mul2[0]));
sel_2 sel_ins1_1(.in1(cold_in[1]), .in2(pre_data[1]), .sel(sel_in), .out(mul2[1]));
sel_2 sel_ins1_2(.in1(cold_in[2]), .in2(pre_data[2]), .sel(sel_in), .out(mul2[2]));
sel_2 sel_ins1_3(.in1(cold_in[3]), .in2(pre_data[3]), .sel(sel_in), .out(mul2[3]));
sel_2 sel_ins1_4(.in1(cold_in[4]), .in2(pre_data[4]), .sel(sel_in), .out(mul2[4]));
sel_2 sel_ins1_5(.in1(cold_in[5]), .in2(pre_data[5]), .sel(sel_in), .out(mul2[5]));
sel_2 sel_ins1_6(.in1(cold_in[6]), .in2(pre_data[6]), .sel(sel_in), .out(mul2[6]));
sel_2 sel_ins1_7(.in1(cold_in[7]), .in2(pre_data[7]), .sel(sel_in), .out(mul2[7]));
sel_2 sel_ins1_8(.in1(cold_in[8]), .in2(pre_data[8]), .sel(sel_in), .out(mul2[8]));
sel_2 sel_ins1_9(.in1(cold_in[9]), .in2(pre_data[9]), .sel(sel_in), .out(mul2[9]));
sel_2 sel_ins1_10(.in1(cold_in[10]), .in2(pre_data[10]), .sel(sel_in), .out(mul2[10]));
sel_2 sel_ins1_11(.in1(cold_in[11]), .in2(pre_data[11]), .sel(sel_in), .out(mul2[11]));
sel_2 sel_ins1_12(.in1(cold_in[12]), .in2(pre_data[12]), .sel(sel_in), .out(mul2[12]));
sel_2 sel_ins1_13(.in1(cold_in[13]), .in2(pre_data[13]), .sel(sel_in), .out(mul2[13]));
sel_2 sel_ins1_14(.in1(cold_in[14]), .in2(pre_data[14]), .sel(sel_in), .out(mul2[14]));
sel_2 sel_ins1_15(.in1(cold_in[15]), .in2(pre_data[15]), .sel(sel_in), .out(mul2[15]));

mul_2 mul_ins0(.in1(mul1[0]), .in2(mul2[0]), .out(cal_out[0]));
mul_2 mul_ins1(.in1(mul1[1]), .in2(mul2[1]), .out(cal_out[1]));
mul_2 mul_ins2(.in1(mul1[2]), .in2(mul2[2]), .out(cal_out[2]));
mul_2 mul_ins3(.in1(mul1[3]), .in2(mul2[3]), .out(cal_out[3]));
mul_2 mul_ins4(.in1(mul1[4]), .in2(mul2[4]), .out(cal_out[4]));
mul_2 mul_ins5(.in1(mul1[5]), .in2(mul2[5]), .out(cal_out[5]));
mul_2 mul_ins6(.in1(mul1[6]), .in2(mul2[6]), .out(cal_out[6]));
mul_2 mul_ins7(.in1(mul1[7]), .in2(mul2[7]), .out(cal_out[7]));
mul_2 mul_ins8(.in1(mul1[8]), .in2(mul2[8]), .out(cal_out[8]));
mul_2 mul_ins9(.in1(mul1[9]), .in2(mul2[9]), .out(cal_out[9]));
mul_2 mul_ins10(.in1(mul1[10]), .in2(mul2[10]), .out(cal_out[10]));
mul_2 mul_ins11(.in1(mul1[11]), .in2(mul2[11]), .out(cal_out[11]));
mul_2 mul_ins12(.in1(mul1[12]), .in2(mul2[12]), .out(cal_out[12]));
mul_2 mul_ins13(.in1(mul1[13]), .in2(mul2[13]), .out(cal_out[13]));
mul_2 mul_ins14(.in1(mul1[14]), .in2(mul2[14]), .out(cal_out[14]));
mul_2 mul_ins15(.in1(mul1[15]), .in2(mul2[15]), .out(cal_out[15]));

always @ (cal_out) begin
    for(integer i = 0; i < 16; i = i + 1)begin
        if(shift_right > 0)begin
            if (cal_out[i][31] == 1) begin // 如果最高位为1，表示为负数
                out[i] = {{16{cal_out[i][31]}}, cal_out[i][31:16]}; // 使用符号扩展
            end
            else begin
                out[i] = cal_out[i] >> shift_right; // 正数直接进行位移操作
            end
        end else begin
            out[i] = cal_out[i];
        end
    end

    
end

endmodule
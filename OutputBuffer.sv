// 输出缓存数据，由4块MLB组成，进行位宽扩展 , 支持4位输入宽度和64位输入宽度
module OutputBuffer(
    input               clk,
    input               rst,
    input               is_scalar,         //是否输入scalar
    input[31:0]         in[63:0],          //输入保存到4组MLB，每组MLB输入16位数，也就是一个PE的数据
    input[31:0]         in_scalar[3:0],    //输入保存到4组MLB，每组MLB输入1位数，累积到16个数的时候自动输入
    input               output_read_en,    //读使能
    input               output_write_en,   //写使能
    input[4:0]          pe_idx,            //第几个PE，范围0~32 (4块sub_tile, 32块unit_tile)
    input[3:0]          data_idx,          //PE数据中的第几个，范围0~15
    input[1:0]          sub_tile_idx,      //tile中sub tile 分块的下标 ， 数值上表示第几次给PE array阵列赋值
    input[2:0]          unit_tile_idx,     //subtile种unit tile 分块的下标，数值上和PE array的column_index相同
    output[31:0]        out[63:0]
);

reg[31:0]           reg_in[63:0];
reg[31:0]           reg_sub_tile_idx;
reg[31:0]           reg_unit_tile_idx;


always @(*) begin : count_to_save_data
    if(is_scalar)begin  //输入4个数的情况，每个MLB输入一个数
        reg_sub_tile_idx = pe_idx / 8;
        reg_unit_tile_idx = pe_idx % 8;
        if(data_idx <= 15)begin  //累加
            reg_in[data_idx] = in_scalar[0];
            reg_in[16+data_idx] = in_scalar[1];
            reg_in[32+data_idx] = in_scalar[2];
            reg_in[48+data_idx] = in_scalar[3];
        end 
    end else begin  //输入64个数的情况，每个MLB输入16个数
        reg_in = in;
        reg_sub_tile_idx = sub_tile_idx;
        reg_unit_tile_idx = unit_tile_idx;
    end
end

MLB mlb_in0(
    .clk(clk), .rst(rst), 
    .in0(reg_in[0]), .in1(reg_in[1]), .in2(reg_in[2]), .in3(reg_in[3]), .in4(reg_in[4]), .in5(reg_in[5]), .in6(reg_in[6]), .in7(reg_in[7]), .in8(reg_in[8]), .in9(reg_in[9]), .in10(reg_in[10]), .in11(reg_in[11]), .in12(reg_in[12]), .in13(reg_in[13]), .in14(reg_in[14]), .in15(reg_in[15]), 
    .read_en(output_read_en), .write_en(output_write_en), .sub_tile_idx(reg_sub_tile_idx), .unit_tile_idx(reg_unit_tile_idx), 
    .out0(out[0]), .out1(out[1]), .out2(out[2]), .out3(out[3]), .out4(out[4]), .out5(out[5]), .out6(out[6]), .out7(out[7]), .out8(out[8]), .out9(out[9]), .out10(out[10]), .out11(out[11]), .out12(out[12]), .out13(out[13]), .out14(out[14]), .out15(out[15])
);

MLB mlb_in1(
    .clk(clk), .rst(rst), 
    .in0(reg_in[16]), .in1(reg_in[17]), .in2(reg_in[18]), .in3(reg_in[19]), .in4(reg_in[20]), .in5(reg_in[21]), .in6(reg_in[22]), .in7(reg_in[23]), .in8(reg_in[24]), .in9(reg_in[25]), .in10(reg_in[26]), .in11(reg_in[27]), .in12(reg_in[28]), .in13(reg_in[29]), .in14(reg_in[30]), .in15(reg_in[31]), 
    .read_en(output_read_en), .write_en(output_write_en), .sub_tile_idx(reg_sub_tile_idx), .unit_tile_idx(reg_unit_tile_idx), 
    .out0(out[16]), .out1(out[17]), .out2(out[18]), .out3(out[19]), .out4(out[20]), .out5(out[21]), .out6(out[22]), .out7(out[23]), .out8(out[24]), .out9(out[25]), .out10(out[26]), .out11(out[27]), .out12(out[28]), .out13(out[29]), .out14(out[30]), .out15(out[31])
);

MLB mlb_in2(
    .clk(clk), .rst(rst), 
    .in0(reg_in[32]), .in1(reg_in[33]), .in2(reg_in[34]), .in3(reg_in[35]), .in4(reg_in[36]), .in5(reg_in[37]), .in6(reg_in[38]), .in7(reg_in[39]), .in8(reg_in[40]), .in9(reg_in[41]), .in10(reg_in[42]), .in11(reg_in[43]), .in12(reg_in[44]), .in13(reg_in[45]), .in14(reg_in[46]), .in15(reg_in[47]), 
    .read_en(output_read_en), .write_en(output_write_en), .sub_tile_idx(reg_sub_tile_idx), .unit_tile_idx(reg_unit_tile_idx), 
    .out0(out[32]), .out1(out[33]), .out2(out[34]), .out3(out[35]), .out4(out[36]), .out5(out[37]), .out6(out[38]), .out7(out[39]), .out8(out[40]), .out9(out[41]), .out10(out[42]), .out11(out[43]), .out12(out[44]), .out13(out[45]), .out14(out[46]), .out15(out[47])
);

MLB mlb_in3(
    .clk(clk), .rst(rst), 
    .in0(reg_in[48]), .in1(reg_in[49]), .in2(reg_in[50]), .in3(reg_in[51]), .in4(reg_in[52]), .in5(reg_in[53]), .in6(reg_in[54]), .in7(reg_in[55]), .in8(reg_in[56]), .in9(reg_in[57]), .in10(reg_in[58]), .in11(reg_in[59]), .in12(reg_in[60]), .in13(reg_in[61]), .in14(reg_in[62]), .in15(reg_in[63]), 
    .read_en(output_read_en), .write_en(output_write_en), .sub_tile_idx(reg_sub_tile_idx), .unit_tile_idx(reg_unit_tile_idx), 
    .out0(out[48]), .out1(out[49]), .out2(out[50]), .out3(out[51]), .out4(out[52]), .out5(out[53]), .out6(out[54]), .out7(out[55]), .out8(out[56]), .out9(out[57]), .out10(out[58]), .out11(out[59]), .out12(out[60]), .out13(out[61]), .out14(out[62]), .out15(out[63])
);

endmodule
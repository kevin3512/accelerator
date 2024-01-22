// 输出缓存数据，由4块MLB组成，进行位宽扩展 , 支持4位输入宽度和64位输入宽度
module OutputBuffer(
    input               clk,
    input               rst,
    input               is_scalar,         //是否输入scalar
    input[31:0]         in[63:0],          //输入保存到4组MLB，每组MLB输入16位数，也就是一个PE的数据
    input[31:0]         in_scalar[3:0],    //输入保存到4组MLB，每组MLB输入1位数，累积到16个数的时候自动输入
    input               save_direct,       //直接保存
    input               output_read_en,    //读使能
    input               output_write_en,   //写使能
    input[4:0]          pe_idx,            //第几个PE，范围0~32 (4块sub_tile, 32块unit_tile)
    input[3:0]          data_idx,          //PE数据中的第几个，范围0~15
    input[1:0]          sub_tile_idx,      //tile中sub tile 分块的下标 ， 数值上表示第几次给PE array阵列赋值
    input[2:0]          unit_tile_idx,     //subtile种unit tile 分块的下标，数值上和PE array的column_index相同
    output[31:0]        out[63:0]
);

reg[31:0]           reg_in[3:0][15:0];
reg[31:0]           reg_sub_tile_idx;
reg[31:0]           reg_unit_tile_idx;


always @(posedge clk or negedge rst) begin : count_to_save_data
    if(!rst)begin

    end else begin
        if(is_scalar)begin  //输入4个数的情况，每个MLB输入一个数
            reg_sub_tile_idx = pe_idx / 8;
            reg_unit_tile_idx = pe_idx % 8;
            if(output_write_en)begin
                reg_in[0][data_idx] = in_scalar[0];
                reg_in[1][data_idx] = in_scalar[1];
                reg_in[2][data_idx] = in_scalar[2];
                reg_in[3][data_idx] = in_scalar[3];
            end
        end else begin  //输入64个数的情况，每个MLB输入16个数
            reg_in[0][15:0] = in[15:0];
            reg_in[1][15:0] = in[31:16];
            reg_in[2][15:0] = in[47:32];
            reg_in[3][15:0] = in[63:48];
            reg_sub_tile_idx = sub_tile_idx;
            reg_unit_tile_idx = unit_tile_idx;
        end
    end
end

MLB mlb_in0(
    .clk(clk), .rst(rst), 
    .in0(reg_in[0][0]), .in1(reg_in[0][1]), .in2(reg_in[0][2]), .in3(reg_in[0][3]), .in4(reg_in[0][4]), .in5(reg_in[0][5]), .in6(reg_in[0][6]), .in7(reg_in[0][7]), .in8(reg_in[0][8]), .in9(reg_in[0][9]), .in10(reg_in[0][10]), .in11(reg_in[0][11]), .in12(reg_in[0][12]), .in13(reg_in[0][13]), .in14(reg_in[0][14]), .in15(reg_in[0][15]), 
    .read_en(output_read_en), .write_en(output_write_en), .sub_tile_idx(reg_sub_tile_idx), .unit_tile_idx(reg_unit_tile_idx), 
    .out0(out[0]), .out1(out[1]), .out2(out[2]), .out3(out[3]), .out4(out[4]), .out5(out[5]), .out6(out[6]), .out7(out[7]), .out8(out[8]), .out9(out[9]), .out10(out[10]), .out11(out[11]), .out12(out[12]), .out13(out[13]), .out14(out[14]), .out15(out[15])
);

MLB mlb_in1(
    .clk(clk), .rst(rst), 
    .in0(reg_in[1][0]), .in1(reg_in[1][1]), .in2(reg_in[1][2]), .in3(reg_in[1][3]), .in4(reg_in[1][4]), .in5(reg_in[1][5]), .in6(reg_in[1][6]), .in7(reg_in[1][7]), .in8(reg_in[1][8]), .in9(reg_in[1][9]), .in10(reg_in[1][10]), .in11(reg_in[1][11]), .in12(reg_in[1][12]), .in13(reg_in[1][13]), .in14(reg_in[1][14]), .in15(reg_in[1][15]), 
    .read_en(output_read_en), .write_en(output_write_en), .sub_tile_idx(reg_sub_tile_idx), .unit_tile_idx(reg_unit_tile_idx), 
    .out0(out[16]), .out1(out[17]), .out2(out[18]), .out3(out[19]), .out4(out[20]), .out5(out[21]), .out6(out[22]), .out7(out[23]), .out8(out[24]), .out9(out[25]), .out10(out[26]), .out11(out[27]), .out12(out[28]), .out13(out[29]), .out14(out[30]), .out15(out[31])
);

MLB mlb_in2(
    .clk(clk), .rst(rst), 
    .in0(reg_in[2][0]), .in1(reg_in[2][1]), .in2(reg_in[2][2]), .in3(reg_in[2][3]), .in4(reg_in[2][4]), .in5(reg_in[2][5]), .in6(reg_in[2][6]), .in7(reg_in[2][7]), .in8(reg_in[2][8]), .in9(reg_in[2][9]), .in10(reg_in[2][10]), .in11(reg_in[2][11]), .in12(reg_in[2][12]), .in13(reg_in[2][13]), .in14(reg_in[2][14]), .in15(reg_in[2][15]), 
    .read_en(output_read_en), .write_en(output_write_en), .sub_tile_idx(reg_sub_tile_idx), .unit_tile_idx(reg_unit_tile_idx), 
    .out0(out[32]), .out1(out[33]), .out2(out[34]), .out3(out[35]), .out4(out[36]), .out5(out[37]), .out6(out[38]), .out7(out[39]), .out8(out[40]), .out9(out[41]), .out10(out[42]), .out11(out[43]), .out12(out[44]), .out13(out[45]), .out14(out[46]), .out15(out[47])
);

MLB mlb_in3(
    .clk(clk), .rst(rst), 
    .in0(reg_in[3][0]), .in1(reg_in[3][1]), .in2(reg_in[3][2]), .in3(reg_in[3][3]), .in4(reg_in[3][4]), .in5(reg_in[3][5]), .in6(reg_in[3][6]), .in7(reg_in[3][7]), .in8(reg_in[3][8]), .in9(reg_in[3][9]), .in10(reg_in[3][10]), .in11(reg_in[3][11]), .in12(reg_in[3][12]), .in13(reg_in[3][13]), .in14(reg_in[3][14]), .in15(reg_in[3][15]), 
    .read_en(output_read_en), .write_en(output_write_en), .sub_tile_idx(reg_sub_tile_idx), .unit_tile_idx(reg_unit_tile_idx), 
    .out0(out[48]), .out1(out[49]), .out2(out[50]), .out3(out[51]), .out4(out[52]), .out5(out[53]), .out6(out[54]), .out7(out[55]), .out8(out[56]), .out9(out[57]), .out10(out[58]), .out11(out[59]), .out12(out[60]), .out13(out[61]), .out14(out[62]), .out15(out[63])
);

endmodule
// 参数缓存数据，由4块MLB组成，进行位宽扩展
module ParameterBuffer(
    input               clk,
    input               rst,
    input[31:0]         in[63:0],
    input               par_read_en,    //读使能
    input               par_write_en,   //写使能
    input[1:0]          sub_tile_idx,      //tile中sub tile 分块的下标 ， 数值上表示第几次给PE array阵列赋值
    input[2:0]          unit_tile_idx,     //subtile种unit tile 分块的下标，数值上和PE array的column_index相同
    output[31:0]        out[63:0]
);

MLB mlb_in0(
    .clk(clk), .rst(rst), 
    .in0(in[0]), .in1(in[1]), .in2(in[2]), .in3(in[3]), .in4(in[4]), .in5(in[5]), .in6(in[6]), .in7(in[7]), .in8(in[8]), .in9(in[9]), .in10(in[10]), .in11(in[11]), .in12(in[12]), .in13(in[13]), .in14(in[14]), .in15(in[15]), 
    .read_en(par_read_en), .write_en(par_write_en), .sub_tile_idx(sub_tile_idx), .unit_tile_idx(unit_tile_idx), 
    .out0(out[0]), .out1(out[1]), .out2(out[2]), .out3(out[3]), .out4(out[4]), .out5(out[5]), .out6(out[6]), .out7(out[7]), .out8(out[8]), .out9(out[9]), .out10(out[10]), .out11(out[11]), .out12(out[12]), .out13(out[13]), .out14(out[14]), .out15(out[15])
);

MLB mlb_in1(
    .clk(clk), .rst(rst), 
    .in0(in[16]), .in1(in[17]), .in2(in[18]), .in3(in[19]), .in4(in[20]), .in5(in[21]), .in6(in[22]), .in7(in[23]), .in8(in[24]), .in9(in[25]), .in10(in[26]), .in11(in[27]), .in12(in[28]), .in13(in[29]), .in14(in[30]), .in15(in[31]), 
    .read_en(par_read_en), .write_en(par_write_en), .sub_tile_idx(sub_tile_idx), .unit_tile_idx(unit_tile_idx), 
    .out0(out[16]), .out1(out[17]), .out2(out[18]), .out3(out[19]), .out4(out[20]), .out5(out[21]), .out6(out[22]), .out7(out[23]), .out8(out[24]), .out9(out[25]), .out10(out[26]), .out11(out[27]), .out12(out[28]), .out13(out[29]), .out14(out[30]), .out15(out[31])
);

MLB mlb_in2(
    .clk(clk), .rst(rst), 
    .in0(in[32]), .in1(in[33]), .in2(in[34]), .in3(in[35]), .in4(in[36]), .in5(in[37]), .in6(in[38]), .in7(in[39]), .in8(in[40]), .in9(in[41]), .in10(in[42]), .in11(in[43]), .in12(in[44]), .in13(in[45]), .in14(in[46]), .in15(in[47]), 
    .read_en(par_read_en), .write_en(par_write_en), .sub_tile_idx(sub_tile_idx), .unit_tile_idx(unit_tile_idx), 
    .out0(out[32]), .out1(out[33]), .out2(out[34]), .out3(out[35]), .out4(out[36]), .out5(out[37]), .out6(out[38]), .out7(out[39]), .out8(out[40]), .out9(out[41]), .out10(out[42]), .out11(out[43]), .out12(out[44]), .out13(out[45]), .out14(out[46]), .out15(out[47])
);

MLB mlb_in3(
    .clk(clk), .rst(rst), 
    .in0(in[48]), .in1(in[49]), .in2(in[50]), .in3(in[51]), .in4(in[52]), .in5(in[53]), .in6(in[54]), .in7(in[55]), .in8(in[56]), .in9(in[57]), .in10(in[58]), .in11(in[59]), .in12(in[60]), .in13(in[61]), .in14(in[62]), .in15(in[63]), 
    .read_en(par_read_en), .write_en(par_write_en), .sub_tile_idx(sub_tile_idx), .unit_tile_idx(unit_tile_idx), 
    .out0(out[48]), .out1(out[49]), .out2(out[50]), .out3(out[51]), .out4(out[52]), .out5(out[53]), .out6(out[54]), .out7(out[55]), .out8(out[56]), .out9(out[57]), .out10(out[58]), .out11(out[59]), .out12(out[60]), .out13(out[61]), .out14(out[62]), .out15(out[63])
);

endmodule
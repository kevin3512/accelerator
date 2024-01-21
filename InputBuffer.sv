// 输入缓存数据，由4块MLB组成，进行位宽扩展
module InputBuffer(
    input               clk,
    input               rst,
    input[31:0]         in[63:0],
    input[31:0]         select_in[15:0],        //选择输入到哪个MLB
    input               input_read_en,    //读使能
    input               input_write_en,   //写使能
    input[1:0]          select_mlb,       //选择那个MLB的输出
    input[1:0]          sub_tile_idx,      //tile中sub tile 分块的下标 ， 数值上表示第几次给PE array阵列赋值
    input[2:0]          unit_tile_idx,     //subtile种unit tile 分块的下标，数值上和PE array的column_index相同
    output reg[31:0]    out[63:0],         //输出4个MLB的输出
    output reg[31:0]    select_out[15:0]   //输出选中MLB的输出
);

reg[31:0]               reg_in[63:0];
wire[31:0]              wire_out[63:0];

always @(posedge clk or negedge rst)begin
    if(!rst)begin

    end else begin
        case(select_mlb)
            2'b00:
                begin
                    select_out[15:0] = wire_out[15:0];
                    reg_in[15:0] = select_in[15:0];
                end
            2'b01:
                begin
                    select_out[15:0] = wire_out[31:16];
                    reg_in[31:16] = select_in[15:0];
                end
            2'b10:
                begin
                    select_out[15:0] = wire_out[47:32];
                    reg_in[47:32] = select_in[15:0];
                end
            2'b11:
                begin
                    select_out[15:0] = wire_out[63:48];
                    reg_in[63:48] = select_in[15:0];
                end
            default:
                begin
                    reg_in[63:0] = in[63:0];   //不设置select_mlb时，默认使用in
                    out[63:0] = wire_out[63:0];
                end
        endcase
    end
end

MLB mlb_in0(
    .clk(clk), .rst(rst), 
    .in0(reg_in[0]), .in1(reg_in[1]), .in2(reg_in[2]), .in3(reg_in[3]), .in4(reg_in[4]), .in5(reg_in[5]), .in6(reg_in[6]), .in7(reg_in[7]), .in8(reg_in[8]), .in9(reg_in[9]), .in10(reg_in[10]), .in11(reg_in[11]), .in12(reg_in[12]), .in13(reg_in[13]), .in14(reg_in[14]), .in15(reg_in[15]), 
    .read_en(input_read_en), .write_en(input_write_en), .sub_tile_idx(sub_tile_idx), .unit_tile_idx(unit_tile_idx), 
    .out0(wire_out[0]), .out1(wire_out[1]), .out2(wire_out[2]), .out3(wire_out[3]), .out4(wire_out[4]), .out5(wire_out[5]), .out6(wire_out[6]), .out7(wire_out[7]), .out8(wire_out[8]), .out9(wire_out[9]), .out10(wire_out[10]), .out11(wire_out[11]), .out12(wire_out[12]), .out13(wire_out[13]), .out14(wire_out[14]), .out15(wire_out[15])
);

MLB mlb_in1(
    .clk(clk), .rst(rst), 
    .in0(reg_in[16]), .in1(reg_in[17]), .in2(reg_in[18]), .in3(reg_in[19]), .in4(reg_in[20]), .in5(reg_in[21]), .in6(reg_in[22]), .in7(reg_in[23]), .in8(reg_in[24]), .in9(reg_in[25]), .in10(reg_in[26]), .in11(reg_in[27]), .in12(reg_in[28]), .in13(reg_in[29]), .in14(reg_in[30]), .in15(reg_in[31]), 
    .read_en(input_read_en), .write_en(input_write_en), .sub_tile_idx(sub_tile_idx), .unit_tile_idx(unit_tile_idx), 
    .out0(wire_out[16]), .out1(wire_out[17]), .out2(wire_out[18]), .out3(wire_out[19]), .out4(wire_out[20]), .out5(wire_out[21]), .out6(wire_out[22]), .out7(wire_out[23]), .out8(wire_out[24]), .out9(wire_out[25]), .out10(wire_out[26]), .out11(wire_out[27]), .out12(wire_out[28]), .out13(wire_out[29]), .out14(wire_out[30]), .out15(wire_out[31])
);

MLB mlb_in2(
    .clk(clk), .rst(rst), 
    .in0(reg_in[32]), .in1(reg_in[33]), .in2(reg_in[34]), .in3(reg_in[35]), .in4(reg_in[36]), .in5(reg_in[37]), .in6(reg_in[38]), .in7(reg_in[39]), .in8(reg_in[40]), .in9(reg_in[41]), .in10(reg_in[42]), .in11(reg_in[43]), .in12(reg_in[44]), .in13(reg_in[45]), .in14(reg_in[46]), .in15(reg_in[47]), 
    .read_en(input_read_en), .write_en(input_write_en), .sub_tile_idx(sub_tile_idx), .unit_tile_idx(unit_tile_idx), 
    .out0(wire_out[32]), .out1(wire_out[33]), .out2(wire_out[34]), .out3(wire_out[35]), .out4(wire_out[36]), .out5(wire_out[37]), .out6(wire_out[38]), .out7(wire_out[39]), .out8(wire_out[40]), .out9(wire_out[41]), .out10(wire_out[42]), .out11(wire_out[43]), .out12(wire_out[44]), .out13(wire_out[45]), .out14(wire_out[46]), .out15(wire_out[47])
);

MLB mlb_in3(
    .clk(clk), .rst(rst), 
    .in0(reg_in[48]), .in1(reg_in[49]), .in2(reg_in[50]), .in3(reg_in[51]), .in4(reg_in[52]), .in5(reg_in[53]), .in6(reg_in[54]), .in7(reg_in[55]), .in8(reg_in[56]), .in9(reg_in[57]), .in10(reg_in[58]), .in11(reg_in[59]), .in12(reg_in[60]), .in13(reg_in[61]), .in14(reg_in[62]), .in15(reg_in[63]), 
    .read_en(input_read_en), .write_en(input_write_en), .sub_tile_idx(sub_tile_idx), .unit_tile_idx(unit_tile_idx), 
    .out0(wire_out[48]), .out1(wire_out[49]), .out2(wire_out[50]), .out3(wire_out[51]), .out4(wire_out[52]), .out5(wire_out[53]), .out6(wire_out[54]), .out7(wire_out[55]), .out8(wire_out[56]), .out9(wire_out[57]), .out10(wire_out[58]), .out11(wire_out[59]), .out12(wire_out[60]), .out13(wire_out[61]), .out14(wire_out[62]), .out15(wire_out[63])
);

endmodule
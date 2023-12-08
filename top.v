//综合顶层文件
module top(
    // common signal
    input               clk,
    input               rst,
    // MLB signal
    input               read_en,
    input               write_en,
    // PE_array control signal
    input [2:0]         col_index,  
    input [7:0]         sel_cu,                                                    
    input [7:0]         sel_cu_go_back, 
    input [7:0]         sel_adder,       
    input [3:0]         is_save_cu_out,   
    input [1:0]         sum_row_pe,    
    input [1:0]         sum_column_pe,
    // sort_relu signal 
    input [31:0]        ins_index,   //处理实例的下标，用与排序
    input               asce,        //升序或降序
    // out acc signal  
    input[2:0]          acc_sig      //累加控制信号

);

    wire[31:0]           in_data[63:0];  //PE array需要的一列4个PE的in数据
    wire[31:0]           par_data[63:0];  //PE array需要的一列4个PE的par数据
    wire [31:0]          scalar_output[3:0]; 
    wire [31:0]          out[3:0][15:0];
    wire [31:0]          sum_scalar_output;  //scalar_output[0]经过acc_out模块之后的累加输出
    wire                 is_start_sort;    //是否开始排序

    wire [4:0]           sel_pe0;
    wire [4:0]           sel_pe1;
    wire [4:0]           sel_pe2;
    wire [4:0]           sel_pe3;

    assign  sel_pe0 = col_index;
    assign  sel_pe1 = col_index + 8;
    assign  sel_pe2 = col_index + 16;
    assign  sel_pe3 = col_index + 24;

    MLB buf_in0(
        .clk(clk),
        .rst(rst),
        .read_en(read_en),
        .sel_pe(sel_pe0),
        .out0(in_data[0]),
        .out1(in_data[1]),
        .out2(in_data[2]),
        .out3(in_data[3]),
        .out4(in_data[4]),
        .out5(in_data[5]),
        .out6(in_data[6]),
        .out7(in_data[7]),
        .out8(in_data[8]),
        .out9(in_data[9]),
        .out10(in_data[10]),
        .out11(in_data[11]),
        .out12(in_data[12]),
        .out13(in_data[13]),
        .out14(in_data[14]),
        .out15(in_data[15])
    );

    MLB buf_in1(
        .clk(clk),
        .rst(rst),
        .read_en(read_en),
        .sel_pe(sel_pe1),
        .out0(in_data[16]),
        .out1(in_data[17]),
        .out2(in_data[18]),
        .out3(in_data[19]),
        .out4(in_data[20]),
        .out5(in_data[21]),
        .out6(in_data[22]),
        .out7(in_data[23]),
        .out8(in_data[24]),
        .out9(in_data[25]),
        .out10(in_data[26]),
        .out11(in_data[27]),
        .out12(in_data[28]),
        .out13(in_data[29]),
        .out14(in_data[30]),
        .out15(in_data[31])
    );

    MLB buf_in2(
        .clk(clk),
        .rst(rst),
        .read_en(read_en),
        .sel_pe(sel_pe2),
        .out0(in_data[32]),
        .out1(in_data[33]),
        .out2(in_data[34]),
        .out3(in_data[35]),
        .out4(in_data[36]),
        .out5(in_data[37]),
        .out6(in_data[38]),
        .out7(in_data[39]),
        .out8(in_data[40]),
        .out9(in_data[41]),
        .out10(in_data[42]),
        .out11(in_data[43]),
        .out12(in_data[44]),
        .out13(in_data[45]),
        .out14(in_data[46]),
        .out15(in_data[47])
    );

    MLB buf_in3(
        .clk(clk),
        .rst(rst),
        .read_en(read_en),
        .sel_pe(sel_pe3),
        .out0(in_data[48]),
        .out1(in_data[49]),
        .out2(in_data[50]),
        .out3(in_data[51]),
        .out4(in_data[52]),
        .out5(in_data[53]),
        .out6(in_data[54]),
        .out7(in_data[55]),
        .out8(in_data[56]),
        .out9(in_data[57]),
        .out10(in_data[58]),
        .out11(in_data[59]),
        .out12(in_data[60]),
        .out13(in_data[61]),
        .out14(in_data[62]),
        .out15(in_data[63])
    );

    MLB buf_par0(
        .clk(clk),
        .rst(rst),
        .read_en(read_en),
        .sel_pe(sel_pe0),
        .out0(par_data[0]),
        .out1(par_data[1]),
        .out2(par_data[2]),
        .out3(par_data[3]),
        .out4(par_data[4]),
        .out5(par_data[5]),
        .out6(par_data[6]),
        .out7(par_data[7]),
        .out8(par_data[8]),
        .out9(par_data[9]),
        .out10(par_data[10]),
        .out11(par_data[11]),
        .out12(par_data[12]),
        .out13(par_data[13]),
        .out14(par_data[14]),
        .out15(par_data[15])
    );

    MLB buf_par1(
        .clk(clk),
        .rst(rst),
        .read_en(read_en),
        .sel_pe(sel_pe1),
        .out0(par_data[16]),
        .out1(par_data[17]),
        .out2(par_data[18]),
        .out3(par_data[19]),
        .out4(par_data[20]),
        .out5(par_data[21]),
        .out6(par_data[22]),
        .out7(par_data[23]),
        .out8(par_data[24]),
        .out9(par_data[25]),
        .out10(par_data[26]),
        .out11(par_data[27]),
        .out12(par_data[28]),
        .out13(par_data[29]),
        .out14(par_data[30]),
        .out15(par_data[31])
    );

    MLB buf_par2(
        .clk(clk),
        .rst(rst),
        .read_en(read_en),
        .sel_pe(sel_pe2),
        .out0(par_data[32]),
        .out1(par_data[33]),
        .out2(par_data[34]),
        .out3(par_data[35]),
        .out4(par_data[36]),
        .out5(par_data[37]),
        .out6(par_data[38]),
        .out7(par_data[39]),
        .out8(par_data[40]),
        .out9(par_data[41]),
        .out10(par_data[42]),
        .out11(par_data[43]),
        .out12(par_data[44]),
        .out13(par_data[45]),
        .out14(par_data[46]),
        .out15(par_data[47])
    );

    MLB buf_par3(
        .clk(clk),
        .rst(rst),
        .read_en(read_en),
        .sel_pe(sel_pe3),
        .out0(par_data[48]),
        .out1(par_data[49]),
        .out2(par_data[50]),
        .out3(par_data[51]),
        .out4(par_data[52]),
        .out5(par_data[53]),
        .out6(par_data[54]),
        .out7(par_data[55]),
        .out8(par_data[56]),
        .out9(par_data[57]),
        .out10(par_data[58]),
        .out11(par_data[59]),
        .out12(par_data[60]),
        .out13(par_data[61]),
        .out14(par_data[62]),
        .out15(par_data[63])
    );

    MLB buf_out0(
        .clk(clk),
        .rst(rst),
        .write_en(write_en),
        .sel_pe(sel_pe0),
        .in0(out[0][0]),
        .in1(out[0][1]),
        .in2(out[0][2]),
        .in3(out[0][3]),
        .in4(out[0][4]),
        .in5(out[0][5]),
        .in6(out[0][6]),
        .in7(out[0][7]),
        .in8(out[0][8]),
        .in9(out[0][9]),
        .in10(out[0][10]),
        .in11(out[0][11]),
        .in12(out[0][12]),
        .in13(out[0][13]),
        .in14(out[0][14]),
        .in15(out[0][15])
    );

    MLB buf_out1(
        .clk(clk),
        .rst(rst),
        .write_en(write_en),
        .sel_pe(sel_pe1),
        .in0(out[1][0]),
        .in1(out[1][1]),
        .in2(out[1][2]),
        .in3(out[1][3]),
        .in4(out[1][4]),
        .in5(out[1][5]),
        .in6(out[1][6]),
        .in7(out[1][7]),
        .in8(out[1][8]),
        .in9(out[1][9]),
        .in10(out[1][10]),
        .in11(out[1][11]),
        .in12(out[1][12]),
        .in13(out[1][13]),
        .in14(out[1][14]),
        .in15(out[1][15])
    );

    MLB buf_out2(
        .clk(clk),
        .rst(rst),
        .write_en(write_en),
        .sel_pe(sel_pe2),
        .in0(out[2][0]),
        .in1(out[2][1]),
        .in2(out[2][2]),
        .in3(out[2][3]),
        .in4(out[2][4]),
        .in5(out[2][5]),
        .in6(out[2][6]),
        .in7(out[2][7]),
        .in8(out[2][8]),
        .in9(out[2][9]),
        .in10(out[2][10]),
        .in11(out[2][11]),
        .in12(out[2][12]),
        .in13(out[2][13]),
        .in14(out[2][14]),
        .in15(out[2][15])
    );

    MLB buf_out3(
        .clk(clk),
        .rst(rst),
        .write_en(write_en),
        .sel_pe(sel_pe3),
        .in0(out[3][0]),
        .in1(out[3][1]),
        .in2(out[3][2]),
        .in3(out[3][3]),
        .in4(out[3][4]),
        .in5(out[3][5]),
        .in6(out[3][6]),
        .in7(out[3][7]),
        .in8(out[3][8]),
        .in9(out[3][9]),
        .in10(out[3][10]),
        .in11(out[3][11]),
        .in12(out[3][12]),
        .in13(out[3][13]),
        .in14(out[3][14]),
        .in15(out[3][15])
    );

    PE_array pe_array (
        .clk(clk),
        .rst(rst),
        .In0_0(in_data[0]), .In0_1(in_data[1]), .In0_2(in_data[2]), .In0_3(in_data[3]), .In0_4(in_data[4]), .In0_5(in_data[5]), .In0_6(in_data[6]), .In0_7(in_data[7]), .In0_8(in_data[8]), .In0_9(in_data[9]), .In0_10(in_data[10]), .In0_11(in_data[11]), .In0_12(in_data[12]), .In0_13(in_data[13]), .In0_14(in_data[14]), .In0_15(in_data[15]),
        .Par0_0(par_data[0]), .Par0_1(par_data[1]), .Par0_2(par_data[2]), .Par0_3(par_data[3]), .Par0_4(par_data[4]), .Par0_5(par_data[5]), .Par0_6(par_data[6]), .Par0_7(par_data[7]), .Par0_8(par_data[8]), .Par0_9(par_data[9]), .Par0_10(par_data[10]), .Par0_11(par_data[11]), .Par0_12(par_data[12]), .Par0_13(par_data[13]), .Par0_14(par_data[14]), .Par0_15(par_data[15]),
        .In1_0(in_data[16]), .In1_1(in_data[17]), .In1_2(in_data[18]), .In1_3(in_data[19]), .In1_4(in_data[20]), .In1_5(in_data[21]), .In1_6(in_data[22]), .In1_7(in_data[23]), .In1_8(in_data[24]), .In1_9(in_data[25]), .In1_10(in_data[26]), .In1_11(in_data[27]), .In1_12(in_data[28]), .In1_13(in_data[29]), .In1_14(in_data[30]), .In1_15(in_data[31]),
        .Par1_0(par_data[16]), .Par1_1(par_data[17]), .Par1_2(par_data[18]), .Par1_3(par_data[19]), .Par1_4(par_data[20]), .Par1_5(par_data[21]), .Par1_6(par_data[22]), .Par1_7(par_data[23]), .Par1_8(par_data[24]), .Par1_9(par_data[25]), .Par1_10(par_data[26]), .Par1_11(par_data[27]), .Par1_12(par_data[28]), .Par1_13(par_data[29]), .Par1_14(par_data[30]), .Par1_15(par_data[31]),
        .In2_0(in_data[32]), .In2_1(in_data[33]), .In2_2(in_data[34]), .In2_3(in_data[35]), .In2_4(in_data[36]), .In2_5(in_data[37]), .In2_6(in_data[38]), .In2_7(in_data[39]), .In2_8(in_data[40]), .In2_9(in_data[41]), .In2_10(in_data[42]), .In2_11(in_data[43]), .In2_12(in_data[44]), .In2_13(in_data[45]), .In2_14(in_data[46]), .In2_15(in_data[47]),
        .Par2_0(par_data[32]), .Par2_1(par_data[33]), .Par2_2(par_data[34]), .Par2_3(par_data[35]), .Par2_4(par_data[36]), .Par2_5(par_data[37]), .Par2_6(par_data[38]), .Par2_7(par_data[39]), .Par2_8(par_data[40]), .Par2_9(par_data[41]), .Par2_10(par_data[42]), .Par2_11(par_data[43]), .Par2_12(par_data[44]), .Par2_13(par_data[45]), .Par2_14(par_data[46]), .Par2_15(par_data[47]),
        .In3_0(in_data[48]), .In3_1(in_data[49]), .In3_2(in_data[50]), .In3_3(in_data[51]), .In3_4(in_data[52]), .In3_5(in_data[53]), .In3_6(in_data[54]), .In3_7(in_data[55]), .In3_8(in_data[56]), .In3_9(in_data[57]), .In3_10(in_data[58]), .In3_11(in_data[59]), .In3_12(in_data[60]), .In3_13(in_data[61]), .In3_14(in_data[62]), .In3_15(in_data[63]),
        .Par3_0(par_data[48]), .Par3_1(par_data[49]), .Par3_2(par_data[50]), .Par3_3(par_data[51]), .Par3_4(par_data[52]), .Par3_5(par_data[53]), .Par3_6(par_data[54]), .Par3_7(par_data[55]), .Par3_8(par_data[56]), .Par3_9(par_data[57]), .Par3_10(par_data[58]), .Par3_11(par_data[59]), .Par3_12(par_data[60]), .Par3_13(par_data[61]), .Par3_14(par_data[62]), .Par3_15(par_data[63]),
        .Col_index(col_index),
        .Sel_cu(sel_cu),
        .Sel_cu_go_back(sel_cu_go_back),
        .Sel_adder(sel_adder), 
        .Is_save_cu_out(is_save_cu_out),
        .Sum_row_pe(sum_row_pe),
        .Sum_column_pe(sum_column_pe),
        .Scalar_output0(scalar_output[0]), .Scalar_output1(scalar_output[1]), .Scalar_output2(scalar_output[2]), .Scalar_output3(scalar_output[3]),
        .Out0_0(out[0][0]), .Out0_1(out[0][1]), .Out0_2(out[0][2]), .Out0_3(out[0][3]), .Out0_4(out[0][4]), .Out0_5(out[0][5]), .Out0_6(out[0][6]), .Out0_7(out[0][7]), .Out0_8(out[0][8]), .Out0_9(out[0][9]), .Out0_10(out[0][10]), .Out0_11(out[0][11]), .Out0_12(out[0][12]), .Out0_13(out[0][13]), .Out0_14(out[0][14]), .Out0_15(out[0][15]),
        .Out1_0(out[1][0]), .Out1_1(out[1][1]), .Out1_2(out[1][2]), .Out1_3(out[1][3]), .Out1_4(out[1][4]), .Out1_5(out[1][5]), .Out1_6(out[1][6]), .Out1_7(out[1][7]), .Out1_8(out[1][8]), .Out1_9(out[1][9]), .Out1_10(out[1][10]), .Out1_11(out[1][11]), .Out1_12(out[1][12]), .Out1_13(out[1][13]), .Out1_14(out[1][14]), .Out1_15(out[1][15]),
        .Out2_0(out[2][0]), .Out2_1(out[2][1]), .Out2_2(out[2][2]), .Out2_3(out[2][3]), .Out2_4(out[2][4]), .Out2_5(out[2][5]), .Out2_6(out[2][6]), .Out2_7(out[2][7]), .Out2_8(out[2][8]), .Out2_9(out[2][9]), .Out2_10(out[2][10]), .Out2_11(out[2][11]), .Out2_12(out[2][12]), .Out2_13(out[2][13]), .Out2_14(out[2][14]), .Out2_15(out[2][15]),
        .Out3_0(out[3][0]), .Out3_1(out[3][1]), .Out3_2(out[3][2]), .Out3_3(out[3][3]), .Out3_4(out[3][4]), .Out3_5(out[3][5]), .Out3_6(out[3][6]), .Out3_7(out[3][7]), .Out3_8(out[3][8]), .Out3_9(out[3][9]), .Out3_10(out[3][10]), .Out3_11(out[3][11]), .Out3_12(out[3][12]), .Out3_13(out[3][13]), .Out3_14(out[3][14]), .Out3_15(out[3][15])
    );

    out_acc acc_inst(.clk(clk), .rst(rst), .sig(acc_sig), .data(scalar_output[0]), .out(sum_scalar_output), .isStop(is_start_sort));

    sort_relu sort_isnt(.clk(clk), .rst(rst), .in(sum_scalar_output), .index(ins_index), .asce(asce), .is_start(is_start_sort));
    

endmodule
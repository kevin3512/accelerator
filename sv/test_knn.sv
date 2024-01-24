//点积操作
`timescale 1ns/1ns
module test_knn;
    parameter         REF_IMAGE_NUM = 60000;
    parameter         TEST_IMAGE_NUM = 10000;
    parameter         IMAGE_SIZE = 784;   //28*28
    parameter         BUFFER_SIZE = 2048;  //4 块 512
    parameter         TEST_N = 10;     //实际运行的测试用例数量
    parameter         REF_N = 60;      //实际运行的参考用例数量（训练集）
    reg               clk;
    reg               rst;
    reg [31:0]        in[3:0][15:0];       
    reg [31:0]        par[3:0][15:0];
    reg [2:0]         col_index;  
    reg [7:0]         sel_cu;                                                    
    reg [7:0]         sel_cu_go_back;   
    reg [7:0]         sel_adder;          
    reg [3:0]         is_save_cu_out;    
    reg               clear_reg;      
                      //control output model(one row PE or one column PE or one PE or all PE)
    reg [1:0]         sum_row_pe;              
    reg [1:0]         sum_column_pe;         
    wire [31:0]       scalar_output[3:0]; 
    wire [31:0]       out[3:0][15:0];

    //MNIST数据集数据
    reg[31:0]         input_data[7:0][63:0];
    reg[31:0]         par_data[7:0][63:0];
    //图片加载1000个verdi可以显示成功，3000不行
    reg[7:0]          ref_images[REF_IMAGE_NUM-1:0][IMAGE_SIZE-1:0];
    reg[7:0]          ref_labels[REF_IMAGE_NUM-1:0]; 
    reg[7:0]          test_images[TEST_IMAGE_NUM-1:0][IMAGE_SIZE-1:0];
    reg[7:0]          test_labels[TEST_IMAGE_NUM-1:0]; 

    integer           img_index;  //测试用例（测试集）下标
    integer           ref_index;  //参考用例（训练集）下标

    //排序模块需要
    reg[31:0]         mem_data[BUFFER_SIZE-1:0];   //4块buff的总长
    reg               read_en;
    reg[1:0]          write_en;
    reg               clear_reg_sort;   //清除排序模块内部寄存器数据
    integer           sort_ref_index;

    //MLB模块相关
    wire[31:0]        wire_in[63:0];    //MLB 和 PE_array直连   
    wire[31:0]        wire_par[63:0];  //MLB 和 PE_array直连
    reg[31:0]         wire_mem_in[3:0][511:0];  //MLB和内存直连，从内存读数据到MLB，总共4块tile，每块512
    reg[31:0]         wire_mem_par[3:0][511:0];
    reg[1:0]          pe_array_num;    //表示第几组提供给pe_array的数据（0~3）
    reg[1:0]          sub_tile_idx_in;     //MLB切分为4块sub_tile，一个sub_tile切分为8块unit_tile
    reg[2:0]          unit_tile_idx_in;    //MLB切分为4块sub_tile，一个sub_tile切分为8块unit_tile
    reg[1:0]          sub_tile_idx_par;    
    reg[2:0]          unit_tile_idx_par;   
    reg[1:0]          data_base_idx;     //数据基础下标，要么为0，要么为512的倍数，因为PE array最多能计算512个数
    //acc累加模块需要的信号
    reg[2:0]          acc_sig;
    reg               acc_is_stop; 
    reg               clear_reg_acc;
    wire[31:0]        acc_scalar_output;

    integer mlb_num;    //4个MLB采用低位交叉编址的方式 ， 一张图片的数据保存在4个MLB块中
    integer mlb_num_index;
    
    //debug
    reg[7:0]        debug_test_image[9:0][783:0];
    reg[7:0]        debug_ref_image[59:0][783:0];

    //Input buffer
    MLB mlb_in0 (  
        .clk(clk),
        .rst(rst),
        .read_en(read_en),
        .write_en(write_en),
        .sub_tile_idx(sub_tile_idx_in),
        .unit_tile_idx(unit_tile_idx_in),
        .in0(wire_mem_in[0][sub_tile_idx_in*128+unit_tile_idx_in*16]), .in1(wire_mem_in[0][sub_tile_idx_in*128+unit_tile_idx_in*16+1]), .in2(wire_mem_in[0][sub_tile_idx_in*128+unit_tile_idx_in*16+2]), .in3(wire_mem_in[0][sub_tile_idx_in*128+unit_tile_idx_in*16+3]),
            .in4(wire_mem_in[0][sub_tile_idx_in*128+unit_tile_idx_in*16+4]),  .in5(wire_mem_in[0][sub_tile_idx_in*128+unit_tile_idx_in*16+5]), .in6(wire_mem_in[0][sub_tile_idx_in*128+unit_tile_idx_in*16+6]), .in7(wire_mem_in[0][sub_tile_idx_in*128+unit_tile_idx_in*16+7]),
                .in8(wire_mem_in[0][sub_tile_idx_in*128+unit_tile_idx_in*16+8]), .in9(wire_mem_in[0][sub_tile_idx_in*128+unit_tile_idx_in*16+9]), .in10(wire_mem_in[0][sub_tile_idx_in*128+unit_tile_idx_in*16+10]), .in11(wire_mem_in[0][sub_tile_idx_in*128+unit_tile_idx_in*16+11]),
                    .in12(wire_mem_in[0][sub_tile_idx_in*128+unit_tile_idx_in*16+12]), .in13(wire_mem_in[0][sub_tile_idx_in*128+unit_tile_idx_in*16+13]), .in14(wire_mem_in[0][sub_tile_idx_in*128+unit_tile_idx_in*16+14]), .in15(wire_mem_in[0][sub_tile_idx_in*128+unit_tile_idx_in*16+15]), 
        .out0(wire_in[0]), .out1(wire_in[1]), .out2(wire_in[2]), .out3(wire_in[3]), .out4(wire_in[4]), 
            .out5(wire_in[5]), .out6(wire_in[6]), .out7(wire_in[7]), .out8(wire_in[8]), .out9(wire_in[9]), 
                .out10(wire_in[10]), .out11(wire_in[11]), .out12(wire_in[12]), .out13(wire_in[13]),.out14(wire_in[14]), .out15(wire_in[15])
        
    );

    MLB mlb_in1 (
        .clk(clk),
        .rst(rst),
        .read_en(read_en),
        .write_en(write_en),
        .sub_tile_idx(sub_tile_idx_in),
        .unit_tile_idx(unit_tile_idx_in),
        .in0(wire_mem_in[1][sub_tile_idx_in*128+unit_tile_idx_in*16]), .in1(wire_mem_in[1][sub_tile_idx_in*128+unit_tile_idx_in*16+1]), .in2(wire_mem_in[1][sub_tile_idx_in*128+unit_tile_idx_in*16+2]), .in3(wire_mem_in[1][sub_tile_idx_in*128+unit_tile_idx_in*16+3]),
            .in4(wire_mem_in[1][sub_tile_idx_in*128+unit_tile_idx_in*16+4]),  .in5(wire_mem_in[1][sub_tile_idx_in*128+unit_tile_idx_in*16+5]), .in6(wire_mem_in[1][sub_tile_idx_in*128+unit_tile_idx_in*16+6]), .in7(wire_mem_in[1][sub_tile_idx_in*128+unit_tile_idx_in*16+7]),
                .in8(wire_mem_in[1][sub_tile_idx_in*128+unit_tile_idx_in*16+8]), .in9(wire_mem_in[1][sub_tile_idx_in*128+unit_tile_idx_in*16+9]), .in10(wire_mem_in[1][sub_tile_idx_in*128+unit_tile_idx_in*16+10]), .in11(wire_mem_in[1][sub_tile_idx_in*128+unit_tile_idx_in*16+11]),
                    .in12(wire_mem_in[1][sub_tile_idx_in*128+unit_tile_idx_in*16+12]), .in13(wire_mem_in[1][sub_tile_idx_in*128+unit_tile_idx_in*16+13]), .in14(wire_mem_in[1][sub_tile_idx_in*128+unit_tile_idx_in*16+14]), .in15(wire_mem_in[1][sub_tile_idx_in*128+unit_tile_idx_in*16+15]), 
        .out0(wire_in[16]), .out1(wire_in[17]), .out2(wire_in[18]), .out3(wire_in[19]), .out4(wire_in[20]), 
            .out5(wire_in[21]), .out6(wire_in[22]), .out7(wire_in[23]), .out8(wire_in[24]), .out9(wire_in[25]), 
                .out10(wire_in[26]), .out11(wire_in[27]), .out12(wire_in[28]), .out13(wire_in[29]),.out14(wire_in[30]), .out15(wire_in[31])
    );

    MLB mlb_in2 (
        .clk(clk),
        .rst(rst),
        .read_en(read_en),
        .write_en(write_en),
        .sub_tile_idx(sub_tile_idx_in),
        .unit_tile_idx(unit_tile_idx_in),
        .in0(wire_mem_in[2][sub_tile_idx_in*128+unit_tile_idx_in*16]), .in1(wire_mem_in[2][sub_tile_idx_in*128+unit_tile_idx_in*16+1]), .in2(wire_mem_in[2][sub_tile_idx_in*128+unit_tile_idx_in*16+2]), .in3(wire_mem_in[2][sub_tile_idx_in*128+unit_tile_idx_in*16+3]),
            .in4(wire_mem_in[2][sub_tile_idx_in*128+unit_tile_idx_in*16+4]),  .in5(wire_mem_in[2][sub_tile_idx_in*128+unit_tile_idx_in*16+5]), .in6(wire_mem_in[2][sub_tile_idx_in*128+unit_tile_idx_in*16+6]), .in7(wire_mem_in[2][sub_tile_idx_in*128+unit_tile_idx_in*16+7]),
                .in8(wire_mem_in[2][sub_tile_idx_in*128+unit_tile_idx_in*16+8]), .in9(wire_mem_in[2][sub_tile_idx_in*128+unit_tile_idx_in*16+9]), .in10(wire_mem_in[2][sub_tile_idx_in*128+unit_tile_idx_in*16+10]), .in11(wire_mem_in[2][sub_tile_idx_in*128+unit_tile_idx_in*16+11]),
                    .in12(wire_mem_in[2][sub_tile_idx_in*128+unit_tile_idx_in*16+12]), .in13(wire_mem_in[2][sub_tile_idx_in*128+unit_tile_idx_in*16+13]), .in14(wire_mem_in[2][sub_tile_idx_in*128+unit_tile_idx_in*16+14]), .in15(wire_mem_in[2][sub_tile_idx_in*128+unit_tile_idx_in*16+15]), 
        .out0(wire_in[32]), .out1(wire_in[33]), .out2(wire_in[34]), .out3(wire_in[35]), .out4(wire_in[36]), 
            .out5(wire_in[37]), .out6(wire_in[38]), .out7(wire_in[39]), .out8(wire_in[40]), .out9(wire_in[41]), 
                .out10(wire_in[42]), .out11(wire_in[43]), .out12(wire_in[44]), .out13(wire_in[45]),.out14(wire_in[46]), .out15(wire_in[47])
    );
    MLB mlb_in3 (
        .clk(clk),
        .rst(rst),
        .read_en(read_en),
        .write_en(write_en),
        .sub_tile_idx(sub_tile_idx_in),
        .unit_tile_idx(unit_tile_idx_in),
        .in0(wire_mem_in[3][sub_tile_idx_in*128+unit_tile_idx_in*16]), .in1(wire_mem_in[3][sub_tile_idx_in*128+unit_tile_idx_in*16+1]), .in2(wire_mem_in[3][sub_tile_idx_in*128+unit_tile_idx_in*16+2]), .in3(wire_mem_in[3][sub_tile_idx_in*128+unit_tile_idx_in*16+3]),
            .in4(wire_mem_in[3][sub_tile_idx_in*128+unit_tile_idx_in*16+4]),  .in5(wire_mem_in[3][sub_tile_idx_in*128+unit_tile_idx_in*16+5]), .in6(wire_mem_in[3][sub_tile_idx_in*128+unit_tile_idx_in*16+6]), .in7(wire_mem_in[3][sub_tile_idx_in*128+unit_tile_idx_in*16+7]),
                .in8(wire_mem_in[3][sub_tile_idx_in*128+unit_tile_idx_in*16+8]), .in9(wire_mem_in[3][sub_tile_idx_in*128+unit_tile_idx_in*16+9]), .in10(wire_mem_in[3][sub_tile_idx_in*128+unit_tile_idx_in*16+10]), .in11(wire_mem_in[3][sub_tile_idx_in*128+unit_tile_idx_in*16+11]),
                    .in12(wire_mem_in[3][sub_tile_idx_in*128+unit_tile_idx_in*16+12]), .in13(wire_mem_in[3][sub_tile_idx_in*128+unit_tile_idx_in*16+13]), .in14(wire_mem_in[3][sub_tile_idx_in*128+unit_tile_idx_in*16+14]), .in15(wire_mem_in[3][sub_tile_idx_in*128+unit_tile_idx_in*16+15]), 
        .out0(wire_in[48]), .out1(wire_in[49]), .out2(wire_in[50]), .out3(wire_in[51]), .out4(wire_in[52]), 
            .out5(wire_in[53]), .out6(wire_in[54]), .out7(wire_in[55]), .out8(wire_in[56]), .out9(wire_in[57]), 
                .out10(wire_in[58]), .out11(wire_in[59]), .out12(wire_in[60]), .out13(wire_in[61]),.out14(wire_in[62]), .out15(wire_in[63])
    );


    // Weight buffer
    MLB mlb_par0 (
        .clk(clk),
        .rst(rst),
        .read_en(read_en),
        .write_en(write_en),
        .sub_tile_idx(sub_tile_idx_par),
        .unit_tile_idx(unit_tile_idx_par),
        .in0(wire_mem_par[0][sub_tile_idx_par*128+unit_tile_idx_par*16]), .in1(wire_mem_par[0][sub_tile_idx_par*128+unit_tile_idx_par*16+1]), .in2(wire_mem_par[0][sub_tile_idx_par*128+unit_tile_idx_par*16+2]), .in3(wire_mem_par[0][sub_tile_idx_par*128+unit_tile_idx_par*16+3]),
            .in4(wire_mem_par[0][sub_tile_idx_par*128+unit_tile_idx_par*16+4]),  .in5(wire_mem_par[0][sub_tile_idx_par*128+unit_tile_idx_par*16+5]), .in6(wire_mem_par[0][sub_tile_idx_par*128+unit_tile_idx_par*16+6]), .in7(wire_mem_par[0][sub_tile_idx_par*128+unit_tile_idx_par*16+7]),
                .in8(wire_mem_par[0][sub_tile_idx_par*128+unit_tile_idx_par*16+8]), .in9(wire_mem_par[0][sub_tile_idx_par*128+unit_tile_idx_par*16+9]), .in10(wire_mem_par[0][sub_tile_idx_par*128+unit_tile_idx_par*16+10]), .in11(wire_mem_par[0][sub_tile_idx_par*128+unit_tile_idx_par*16+11]),
                    .in12(wire_mem_par[0][sub_tile_idx_par*128+unit_tile_idx_par*16+12]), .in13(wire_mem_par[0][sub_tile_idx_par*128+unit_tile_idx_par*16+13]), .in14(wire_mem_par[0][sub_tile_idx_par*128+unit_tile_idx_par*16+14]), .in15(wire_mem_par[0][sub_tile_idx_par*128+unit_tile_idx_par*16+15]), 
        .out0(wire_par[0]), .out1(wire_par[1]), .out2(wire_par[2]), .out3(wire_par[3]), .out4(wire_par[4]), 
            .out5(wire_par[5]), .out6(wire_par[6]), .out7(wire_par[7]), .out8(wire_par[8]), .out9(wire_par[9]), 
                .out10(wire_par[10]), .out11(wire_par[11]), .out12(wire_par[12]), .out13(wire_par[13]),.out14(wire_par[14]), .out15(wire_par[15])
        
    );

    MLB mlb_par1 (
        .clk(clk),
        .rst(rst),
        .read_en(read_en),
        .write_en(write_en),
        .sub_tile_idx(sub_tile_idx_par),
        .unit_tile_idx(unit_tile_idx_par),
        .in0(wire_mem_par[1][sub_tile_idx_par*128+unit_tile_idx_par*16]), .in1(wire_mem_par[1][sub_tile_idx_par*128+unit_tile_idx_par*16+1]), .in2(wire_mem_par[1][sub_tile_idx_par*128+unit_tile_idx_par*16+2]), .in3(wire_mem_par[1][sub_tile_idx_par*128+unit_tile_idx_par*16+3]),
            .in4(wire_mem_par[1][sub_tile_idx_par*128+unit_tile_idx_par*16+4]),  .in5(wire_mem_par[1][sub_tile_idx_par*128+unit_tile_idx_par*16+5]), .in6(wire_mem_par[1][sub_tile_idx_par*128+unit_tile_idx_par*16+6]), .in7(wire_mem_par[1][sub_tile_idx_par*128+unit_tile_idx_par*16+7]),
                .in8(wire_mem_par[1][sub_tile_idx_par*128+unit_tile_idx_par*16+8]), .in9(wire_mem_par[1][sub_tile_idx_par*128+unit_tile_idx_par*16+9]), .in10(wire_mem_par[1][sub_tile_idx_par*128+unit_tile_idx_par*16+10]), .in11(wire_mem_par[1][sub_tile_idx_par*128+unit_tile_idx_par*16+11]),
                    .in12(wire_mem_par[1][sub_tile_idx_par*128+unit_tile_idx_par*16+12]), .in13(wire_mem_par[1][sub_tile_idx_par*128+unit_tile_idx_par*16+13]), .in14(wire_mem_par[1][sub_tile_idx_par*128+unit_tile_idx_par*16+14]), .in15(wire_mem_par[1][sub_tile_idx_par*128+unit_tile_idx_par*16+15]), 
        .out0(wire_par[16]), .out1(wire_par[17]), .out2(wire_par[18]), .out3(wire_par[19]), .out4(wire_par[20]), 
            .out5(wire_par[21]), .out6(wire_par[22]), .out7(wire_par[23]), .out8(wire_par[24]), .out9(wire_par[25]), 
                .out10(wire_par[26]), .out11(wire_par[27]), .out12(wire_par[28]), .out13(wire_par[29]),.out14(wire_par[30]), .out15(wire_par[31])
    );

    MLB mlb_par2 (
        .clk(clk),
        .rst(rst),
        .read_en(read_en),
        .write_en(write_en),
        .sub_tile_idx(sub_tile_idx_par),
        .unit_tile_idx(unit_tile_idx_par),
        .in0(wire_mem_par[2][sub_tile_idx_par*128+unit_tile_idx_par*16]), .in1(wire_mem_par[2][sub_tile_idx_par*128+unit_tile_idx_par*16+1]), .in2(wire_mem_par[2][sub_tile_idx_par*128+unit_tile_idx_par*16+2]), .in3(wire_mem_par[2][sub_tile_idx_par*128+unit_tile_idx_par*16+3]),
            .in4(wire_mem_par[2][sub_tile_idx_par*128+unit_tile_idx_par*16+4]),  .in5(wire_mem_par[2][sub_tile_idx_par*128+unit_tile_idx_par*16+5]), .in6(wire_mem_par[2][sub_tile_idx_par*128+unit_tile_idx_par*16+6]), .in7(wire_mem_par[2][sub_tile_idx_par*128+unit_tile_idx_par*16+7]),
                .in8(wire_mem_par[2][sub_tile_idx_par*128+unit_tile_idx_par*16+8]), .in9(wire_mem_par[2][sub_tile_idx_par*128+unit_tile_idx_par*16+9]), .in10(wire_mem_par[2][sub_tile_idx_par*128+unit_tile_idx_par*16+10]), .in11(wire_mem_par[2][sub_tile_idx_par*128+unit_tile_idx_par*16+11]),
                    .in12(wire_mem_par[2][sub_tile_idx_par*128+unit_tile_idx_par*16+12]), .in13(wire_mem_par[2][sub_tile_idx_par*128+unit_tile_idx_par*16+13]), .in14(wire_mem_par[2][sub_tile_idx_par*128+unit_tile_idx_par*16+14]), .in15(wire_mem_par[2][sub_tile_idx_par*128+unit_tile_idx_par*16+15]), 
        .out0(wire_par[32]), .out1(wire_par[33]), .out2(wire_par[34]), .out3(wire_par[35]), .out4(wire_par[36]), 
            .out5(wire_par[37]), .out6(wire_par[38]), .out7(wire_par[39]), .out8(wire_par[40]), .out9(wire_par[41]), 
                .out10(wire_par[42]), .out11(wire_par[43]), .out12(wire_par[44]), .out13(wire_par[45]),.out14(wire_par[46]), .out15(wire_par[47])
    );
    MLB mlb_par3 (
        .clk(clk),
        .rst(rst),
        .read_en(read_en),
        .write_en(write_en),
        .sub_tile_idx(sub_tile_idx_par),
        .unit_tile_idx(unit_tile_idx_par),
        .in0(wire_mem_par[3][sub_tile_idx_par*128+unit_tile_idx_par*16]), .in1(wire_mem_par[3][sub_tile_idx_par*128+unit_tile_idx_par*16+1]), .in2(wire_mem_par[3][sub_tile_idx_par*128+unit_tile_idx_par*16+2]), .in3(wire_mem_par[3][sub_tile_idx_par*128+unit_tile_idx_par*16+3]),
            .in4(wire_mem_par[3][sub_tile_idx_par*128+unit_tile_idx_par*16+4]),  .in5(wire_mem_par[3][sub_tile_idx_par*128+unit_tile_idx_par*16+5]), .in6(wire_mem_par[3][sub_tile_idx_par*128+unit_tile_idx_par*16+6]), .in7(wire_mem_par[3][sub_tile_idx_par*128+unit_tile_idx_par*16+7]),
                .in8(wire_mem_par[3][sub_tile_idx_par*128+unit_tile_idx_par*16+8]), .in9(wire_mem_par[3][sub_tile_idx_par*128+unit_tile_idx_par*16+9]), .in10(wire_mem_par[3][sub_tile_idx_par*128+unit_tile_idx_par*16+10]), .in11(wire_mem_par[3][sub_tile_idx_par*128+unit_tile_idx_par*16+11]),
                    .in12(wire_mem_par[3][sub_tile_idx_par*128+unit_tile_idx_par*16+12]), .in13(wire_mem_par[3][sub_tile_idx_par*128+unit_tile_idx_par*16+13]), .in14(wire_mem_par[3][sub_tile_idx_par*128+unit_tile_idx_par*16+14]), .in15(wire_mem_par[3][sub_tile_idx_par*128+unit_tile_idx_par*16+15]), 
        .out0(wire_par[48]), .out1(wire_par[49]), .out2(wire_par[50]), .out3(wire_par[51]), .out4(wire_par[52]), 
            .out5(wire_par[53]), .out6(wire_par[54]), .out7(wire_par[55]), .out8(wire_par[56]), .out9(wire_par[57]), 
                .out10(wire_par[58]), .out11(wire_par[59]), .out12(wire_par[60]), .out13(wire_par[61]),.out14(wire_par[62]), .out15(wire_par[63])
    );

    PE_array pe_array (
        .clk(clk),
        .rst(rst),
        .In0_0(wire_in[0]), .In0_1(wire_in[1]), .In0_2(wire_in[2]), .In0_3(wire_in[3]), .In0_4(wire_in[4]), .In0_5(wire_in[5]), .In0_6(wire_in[6]), .In0_7(wire_in[7]), .In0_8(wire_in[8]), .In0_9(wire_in[9]), .In0_10(wire_in[10]), .In0_11(wire_in[11]), .In0_12(wire_in[12]), .In0_13(wire_in[13]), .In0_14(wire_in[14]), .In0_15(wire_in[15]),
        .Par0_0(wire_par[0]), .Par0_1(wire_par[1]), .Par0_2(wire_par[2]), .Par0_3(wire_par[3]), .Par0_4(wire_par[4]), .Par0_5(wire_par[5]), .Par0_6(wire_par[6]), .Par0_7(wire_par[7]), .Par0_8(wire_par[8]), .Par0_9(wire_par[9]), .Par0_10(wire_par[10]), .Par0_11(wire_par[11]), .Par0_12(wire_par[12]), .Par0_13(wire_par[13]), .Par0_14(wire_par[14]), .Par0_15(wire_par[15]),
        .In1_0(wire_in[16]), .In1_1(wire_in[17]), .In1_2(wire_in[18]), .In1_3(wire_in[19]), .In1_4(wire_in[20]), .In1_5(wire_in[21]), .In1_6(wire_in[22]), .In1_7(wire_in[23]), .In1_8(wire_in[24]), .In1_9(wire_in[25]), .In1_10(wire_in[26]), .In1_11(wire_in[27]), .In1_12(wire_in[28]), .In1_13(wire_in[29]), .In1_14(wire_in[30]), .In1_15(wire_in[31]),
        .Par1_0(wire_par[16]), .Par1_1(wire_par[17]), .Par1_2(wire_par[18]), .Par1_3(wire_par[19]), .Par1_4(wire_par[20]), .Par1_5(wire_par[21]), .Par1_6(wire_par[22]), .Par1_7(wire_par[23]), .Par1_8(wire_par[24]), .Par1_9(wire_par[25]), .Par1_10(wire_par[26]), .Par1_11(wire_par[27]), .Par1_12(wire_par[28]), .Par1_13(wire_par[29]), .Par1_14(wire_par[30]), .Par1_15(wire_par[31]),
        .In2_0(wire_in[32]), .In2_1(wire_in[33]), .In2_2(wire_in[34]), .In2_3(wire_in[35]), .In2_4(wire_in[36]), .In2_5(wire_in[37]), .In2_6(wire_in[38]), .In2_7(wire_in[39]), .In2_8(wire_in[40]), .In2_9(wire_in[41]), .In2_10(wire_in[42]), .In2_11(wire_in[43]), .In2_12(wire_in[44]), .In2_13(wire_in[45]), .In2_14(wire_in[46]), .In2_15(wire_in[47]),
        .Par2_0(wire_par[32]), .Par2_1(wire_par[33]), .Par2_2(wire_par[34]), .Par2_3(wire_par[35]), .Par2_4(wire_par[36]), .Par2_5(wire_par[37]), .Par2_6(wire_par[38]), .Par2_7(wire_par[39]), .Par2_8(wire_par[40]), .Par2_9(wire_par[41]), .Par2_10(wire_par[42]), .Par2_11(wire_par[43]), .Par2_12(wire_par[44]), .Par2_13(wire_par[45]), .Par2_14(wire_par[46]), .Par2_15(wire_par[47]),
        .In3_0(wire_in[48]), .In3_1(wire_in[49]), .In3_2(wire_in[50]), .In3_3(wire_in[51]), .In3_4(wire_in[52]), .In3_5(wire_in[53]), .In3_6(wire_in[54]), .In3_7(wire_in[55]), .In3_8(wire_in[56]), .In3_9(wire_in[57]), .In3_10(wire_in[58]), .In3_11(wire_in[59]), .In3_12(wire_in[60]), .In3_13(wire_in[61]), .In3_14(wire_in[62]), .In3_15(wire_in[63]),
        .Par3_0(wire_par[48]), .Par3_1(wire_par[49]), .Par3_2(wire_par[50]), .Par3_3(wire_par[51]), .Par3_4(wire_par[52]), .Par3_5(wire_par[53]), .Par3_6(wire_par[54]), .Par3_7(wire_par[55]), .Par3_8(wire_par[56]), .Par3_9(wire_par[57]), .Par3_10(wire_par[58]), .Par3_11(wire_par[59]), .Par3_12(wire_par[60]), .Par3_13(wire_par[61]), .Par3_14(wire_par[62]), .Par3_15(wire_par[63]),
        .Col_index(col_index),
        .Sel_cu(sel_cu),
        .Sel_cu_go_back(sel_cu_go_back),
        .Sel_adder(sel_adder), 
        .Is_save_cu_out(is_save_cu_out),
        .Clear_reg(clear_reg),
        .Sum_row_pe(sum_row_pe),
        .Sum_column_pe(sum_column_pe),
        .Scalar_output0(scalar_output[0]), .Scalar_output1(scalar_output[1]), .Scalar_output2(scalar_output[2]), .Scalar_output3(scalar_output[3]),
        .Out0_0(out[0][0]), .Out0_1(out[0][1]), .Out0_2(out[0][2]), .Out0_3(out[0][3]), .Out0_4(out[0][4]), .Out0_5(out[0][5]), .Out0_6(out[0][6]), .Out0_7(out[0][7]), .Out0_8(out[0][8]), .Out0_9(out[0][9]), .Out0_10(out[0][10]), .Out0_11(out[0][11]), .Out0_12(out[0][12]), .Out0_13(out[0][13]), .Out0_14(out[0][14]), .Out0_15(out[0][15]),
        .Out1_0(out[1][0]), .Out1_1(out[1][1]), .Out1_2(out[1][2]), .Out1_3(out[1][3]), .Out1_4(out[1][4]), .Out1_5(out[1][5]), .Out1_6(out[1][6]), .Out1_7(out[1][7]), .Out1_8(out[1][8]), .Out1_9(out[1][9]), .Out1_10(out[1][10]), .Out1_11(out[1][11]), .Out1_12(out[1][12]), .Out1_13(out[1][13]), .Out1_14(out[1][14]), .Out1_15(out[1][15]),
        .Out2_0(out[2][0]), .Out2_1(out[2][1]), .Out2_2(out[2][2]), .Out2_3(out[2][3]), .Out2_4(out[2][4]), .Out2_5(out[2][5]), .Out2_6(out[2][6]), .Out2_7(out[2][7]), .Out2_8(out[2][8]), .Out2_9(out[2][9]), .Out2_10(out[2][10]), .Out2_11(out[2][11]), .Out2_12(out[2][12]), .Out2_13(out[2][13]), .Out2_14(out[2][14]), .Out2_15(out[2][15]),
        .Out3_0(out[3][0]), .Out3_1(out[3][1]), .Out3_2(out[3][2]), .Out3_3(out[3][3]), .Out3_4(out[3][4]), .Out3_5(out[3][5]), .Out3_6(out[3][6]), .Out3_7(out[3][7]), .Out3_8(out[3][8]), .Out3_9(out[3][9]), .Out3_10(out[3][10]), .Out3_11(out[3][11]), .Out3_12(out[3][12]), .Out3_13(out[3][13]), .Out3_14(out[3][14]), .Out3_15(out[3][15])
    );

    //累加模块
    acc_out acc_inst(.clk(clk), .rst(rst), .sig(acc_sig), .data0(scalar_output[0]), .isStop0(acc_is_stop), .out0(acc_scalar_output), .clear_reg0(clear_reg_acc));

    //排序模块
    sort_relu sort_isnt(.clk(clk), .rst(rst), .in(acc_scalar_output), .index(sort_ref_index), .sig(4'b0001), .asce(1'b1), .is_output(1'b1), .clear_reg(clear_reg_sort)); 

    //输出保存

    initial begin     
        if(TEST_N < 100)begin
            $fsdbDumpfile("tb.fsdb");
            $fsdbDumpvars(0);
            $fsdbDumpMDA();
        end         
        clk = 0;
        rst = 1;
        forever begin
            #1 clk = ~clk;
        end
    end

    //读取MNIST手写图片数据集（每张图片28*28）
    task read_mnist_dataset_task;
        output ref_images;
        output ref_labels;
        output test_images;
        output test_labels;
        reg[7:0]        ref_images[REF_IMAGE_NUM-1:0][IMAGE_SIZE-1:0];
        reg[7:0]        ref_labels[REF_IMAGE_NUM-1:0]; 
        reg[7:0]        test_images[TEST_IMAGE_NUM-1:0][IMAGE_SIZE-1:0];
        reg[7:0]        test_labels[TEST_IMAGE_NUM-1:0]; 
        begin
            $readmemh("mnist_dataset/ref-images.hex", ref_images);
            $readmemh("mnist_dataset/test-images.hex", test_images);
            $readmemh("mnist_dataset/ref-labels.hex", ref_labels);
            $readmemh("mnist_dataset/test-labels.hex", test_labels);
        end

    endtask

    //读取数据到input_data和par_data数据，这是PE_array所需要的输入
    task read_in_and_par;
        input[7:0]   in[IMAGE_SIZE-1:0];
        input[7:0]   par[IMAGE_SIZE-1:0];
        input        index;   //取第几组，讲IMAGE_SIZE按照32*16的大小进行切分，取第index组给input_data和par_data赋值
        output       input_data;
        output       par_data;
        reg[31:0]    input_data[7:0][63:0];
        reg[31:0]    par_data[7:0][63:0];
        integer      start_index;
        begin
            // Calculate the start index for the chunk
            start_index = index * 512;
             // 将指定索引处的数据块分配给 input_data
            for (integer i = 0; i < 8; i = i + 1) begin
                for (integer j = 0; j < 64; j = j + 1) begin
                    input_data[i][j] = in[start_index + i * 64 + j];
                end
            end

            // 将指定索引处的数据块分配给 par_data
            for (integer i = 0; i < 8; i = i + 1) begin
                for (integer j = 0; j < 64; j = j + 1) begin
                    par_data[i][j] = par[start_index + i * 64 + j];
                end
            end
        end

    endtask

    //从MLB中读取数据到input_data和par_data数据，这是PE_array所需要的输入
    task read_in_and_par_from_mlb;
        input[7:0]   in[IMAGE_SIZE-1:0];
        input[7:0]   par[IMAGE_SIZE-1:0];
        input        index;   //取第几组，讲IMAGE_SIZE按照32*16的大小进行切分，取第index组给input_data和par_data赋值
        output       input_data;
        output       par_data;
        reg[31:0]    input_data[7:0][63:0];
        reg[31:0]    par_data[7:0][63:0];
        integer      start_index;
        begin
            // Calculate the start index for the chunk
            start_index = index * 512;
             // 将指定索引处的数据块分配给 input_data
            for (integer i = 0; i < 8; i = i + 1) begin
                for (integer j = 0; j < 64; j = j + 1) begin
                    input_data[i][j] = in[start_index + i * 64 + j];
                end
            end

            // 将指定索引处的数据块分配给 par_data
            for (integer i = 0; i < 8; i = i + 1) begin
                for (integer j = 0; j < 64; j = j + 1) begin
                    par_data[i][j] = par[start_index + i * 64 + j];
                end
            end
        end

    endtask

    //给PE_array的in和par输入赋值
    task assign_in_and_par;
        input [31:0] input_data[63:0];
        input [31:0] par_data[63:0];
        begin
            in[0][15:0] = input_data[15:0];
            par[0][15:0] = par_data[15:0];
            in[1][15:0] = input_data[31:16];
            par[1][15:0] = par_data[31:16];
            in[2][15:0] = input_data[47:32];
            par[2][15:0] = par_data[47:32];
            in[3][15:0] = input_data[63:48];
            par[3][15:0] = par_data[63:48];
            
        end
    endtask

    //进行一次点积计算，传入PE_array需要的数据
    task cal_dot_product;
        input [31:0]    input_data[7:0][63:0];
        input [31:0]    par_data[7:0][63:0];
        begin
            sum_row_pe = 2'b10;    //row select sum of row PE  
            sum_column_pe = 2'b10;  //column select sum of column PE
            for (integer i = 0; i < 8; i = i + 1)begin
                //控制信号清零，这样再次赋值才会生效
                #2;
                sel_cu = 8'b0;   
                sel_cu_go_back = 8'b0;  
                sel_adder = 8'b0;    
                col_index = i[2:0];
                assign_in_and_par(input_data[i][63:0], par_data[i][63:0]);
                #2;
                sel_cu = 8'b10101010;   //multiple
                sel_cu_go_back = 8'b10101010;  // go next
                sel_adder = 8'b10101010;     //sum of all
            end
        end
    endtask

    //进行一次距离计算，传入PE_array需要的数据
    task cal_distance;
        input [31:0]    input_data[7:0][63:0];
        input [31:0]    par_data[7:0][63:0];
        begin
            sum_row_pe = 2'b10;    //row select sum of row PE  
            sum_column_pe = 2'b10;  //column select sum of column PE
            is_save_cu_out = 4'b0000;
            for (integer i = 0; i < 8; i = i + 1)begin
                #2
                col_index = i[2:0];
                //控制信号清零，这样再次赋值才会生效
                assign_in_and_par(input_data[i][63:0], par_data[i][63:0]);
                sel_cu = 8'b00000000;   //subtraction
                #2
                is_save_cu_out = 4'b1111;
                sel_cu_go_back = 8'b01010101;  // cu result go to par
                sel_adder = 8'b00000000;
                #2
                sel_cu_go_back = 8'b11111111;  // cu result go to in
                #2
                is_save_cu_out = 4'b0000;
                sel_cu = 8'b11111111;   //multiplication
                sel_cu_go_back = 8'b10101010;  //go next
                #2
                //当is_save_cu_out置为0时，不能马上将sel_adder放开，否则会导致要赋值给in和par的cu_out先给cu_computer_out再给adder_in最终将值输出从而造成结果出错
                sel_adder = 8'b10101010;     
                #10;
            end
        end
    endtask

    initial begin
        // 从数据集中读取文件到内存
        read_mnist_dataset_task(ref_images, ref_labels, test_images, test_labels);
        $display("读取到训练集图片最后一个字节(第%d个)为%h" ,REF_IMAGE_NUM, ref_images[REF_IMAGE_NUM-1][IMAGE_SIZE-1]);
        $display("读取到测试集图片最后一个字节(第%d个)为%h" ,TEST_IMAGE_NUM, test_images[TEST_IMAGE_NUM-1][IMAGE_SIZE-1]);
        for(integer kk1 = 0; kk1 < 10; kk1 = kk1 + 1)begin
            debug_test_image[kk1][783:0] = test_images[kk1][783:0];
        end
        for(integer kk2 = 0; kk2 < 60; kk2 = kk2 + 1)begin
            debug_ref_image[kk2][783:0] = ref_images[kk2][783:0];
        end
        //测试用例数量10000
        //------------------------------------------向MLB写数据start-------------------------------------------
        for (img_index = 0; img_index < TEST_N; img_index = img_index + 1)begin
            $display("正在计算第%0d个图片的分类结果", img_index+1);
            acc_is_stop = 0;
            write_en = 1;
            read_en = 0;
            //清除一下上一张测试图片保留的排序模块的寄存器数据
            clear_reg_sort = 1;
            #2
            clear_reg_sort = 0;
            sub_tile_idx_in = 0;
            unit_tile_idx_in = 0;
            for(integer j = 0; j < 512; j = j + 16)begin
                sub_tile_idx_in = j / 128;
                unit_tile_idx_in = (j / 16) % 8;
                data_base_idx = sub_tile_idx_in % 2;
                for(integer k = 0; k < 16; k = k + 1)begin  // 一个PE控制信号需要对应16个输入数据
                    if(sub_tile_idx_in < 2)begin //使用image0赋值
                        wire_mem_in[0][j+k] = test_images[img_index][data_base_idx*512+unit_tile_idx_in*64+k];
                        wire_mem_in[1][j+k] = test_images[img_index][data_base_idx*512+unit_tile_idx_in*64+k+16];
                        wire_mem_in[2][j+k] = test_images[img_index][data_base_idx*512+unit_tile_idx_in*64+k+32];
                        wire_mem_in[3][j+k] = test_images[img_index][data_base_idx*512+unit_tile_idx_in*64+k+48];
                    end else begin  //使用image1赋值 , 这里不加1是为了 把in数据的4块MLB都用一张图填充满，便于和par计算
                        wire_mem_in[0][j+k] = test_images[img_index][data_base_idx*512+unit_tile_idx_in*64+k];  
                        wire_mem_in[1][j+k] = test_images[img_index][data_base_idx*512+unit_tile_idx_in*64+k+16];
                        wire_mem_in[2][j+k] = test_images[img_index][data_base_idx*512+unit_tile_idx_in*64+k+32];
                        wire_mem_in[3][j+k] = test_images[img_index][data_base_idx*512+unit_tile_idx_in*64+k+48];
                    end
                end
                #2;
            end
            // 参考用例数量 60000
            for(ref_index = 0; ref_index < REF_N; ref_index = ref_index + 2)begin  //一个循环读取2张图片
                //把2张参考用例图片数据写入到MLB，从内存读取数据到MLB
                write_en = 1;
                read_en = 0;
                sub_tile_idx_par = 0;
                unit_tile_idx_par = 0;
                for(integer x = 0; x < 512; x = x + 16)begin  //一次循环，给4个MLB赋值
                    sub_tile_idx_par = x / 128;  // 0~3 变化1次
                    unit_tile_idx_par = (x / 16) % 8;  //0~7变化4次
                    data_base_idx = sub_tile_idx_par % 2;
                    for(integer y = 0 ; y < 16; y = y + 1)begin  // 一个PE控制信号需要对应16个输入数据
                        if(sub_tile_idx_par < 2)begin //使用image0赋值
                            wire_mem_par[0][x+y] = ref_images[ref_index][data_base_idx*512+unit_tile_idx_par*64+y];
                            wire_mem_par[1][x+y] = ref_images[ref_index][data_base_idx*512+unit_tile_idx_par*64+y+16];
                            wire_mem_par[2][x+y] = ref_images[ref_index][data_base_idx*512+unit_tile_idx_par*64+y+32];
                            wire_mem_par[3][x+y] = ref_images[ref_index][data_base_idx*512+unit_tile_idx_par*64+y+48];
                        end else begin  //使用image1赋值
                            wire_mem_par[0][x+y] = ref_images[ref_index+1][data_base_idx*512+unit_tile_idx_par*64+y];
                            wire_mem_par[1][x+y] = ref_images[ref_index+1][data_base_idx*512+unit_tile_idx_par*64+y+16];
                            wire_mem_par[2][x+y] = ref_images[ref_index+1][data_base_idx*512+unit_tile_idx_par*64+y+32];
                            wire_mem_par[3][x+y] = ref_images[ref_index+1][data_base_idx*512+unit_tile_idx_par*64+y+48];
                        end
                    end 
                    #2;
                end
                //还有一些残缺的部分补全一下0
                for(integer u = 784 ; u < 1024; u = u + 1)begin
                    for(integer v = 0; v < 4; v = v + 1)begin
                        wire_mem_in[v][u] = 32'h0;
                        wire_mem_par[v][u] = 32'h0;
                    end
                end
                clear_reg_acc = 1;  //初始化寄存器的状态，避免出现第一个数据由于acc_out不为0，而出现累加失败的情况，也即32'hxxxx_xxxx + 任何数 依旧是32'hxxxx_xxxx
                #2 //这里要等2个时间单位，是为了保证pe_array_num=1的时候 ， col_index不会马上变为0，从而导致PE_array无法输出
                //------------------------------------------向MLB写数据finish-------------------------------------------
                //------------------------------------------从MLB读数据start--------------------------------------------
                // 开始对写满的4块MLB进行读数据，然后计算，这里执行4次
                for(integer w = 0; w < 4; w = w + 1)begin
                    write_en = 0;
                    read_en = 1;
                    sub_tile_idx_in = w;
                    sub_tile_idx_par = w;
                    //从MLB中读取8次数据进行计算(cal_distance)
                    sum_row_pe = 2'b10;    //row select sum of row PE  
                    sum_column_pe = 2'b10;  //column select sum of column PE
                    is_save_cu_out = 4'b0000;
                    clear_reg = 1'b0;  //reset last time running value 1
                    acc_sig = 3'b1;
                    acc_is_stop = 0;
                    clear_reg_acc = 0;
                    pe_array_num = w;
                    col_index = 3'bxxx;   //需要保证在清除之前就变为0，防止清除数据后col_index还是为7，从而极速计算
                    clear_reg = 1'b1;   //一组PE array计算之前，需要清除上一次PE array计算的结果，防止在本次计算中继续叠加
                    #2
                    clear_reg = 1'b0;
                    for (integer z = 0; z < 8; z = z + 1)begin
                        col_index = z[2:0];
                        unit_tile_idx_in = z[2:0];
                        unit_tile_idx_par = z[2:0];
                        //控制信号清零，这样再次赋值才会生效
                        sel_cu = 8'b00000000;   //subtraction
                        sel_cu_go_back = 8'b00000000;  //需要把置为0，否则上一次的结果会顺延到下一个周期
                        #4
                        is_save_cu_out = 4'b1111;
                        sel_cu_go_back = 8'b01010101;  // cu result go to par
                        sel_adder = 8'b00000000;
                        #4
                        sel_cu_go_back = 8'b11111111;  // cu result go to in
                        #4
                        is_save_cu_out = 4'b0000;
                        sel_cu = 8'b11111111;   //multiplication
                        sel_cu_go_back = 8'b10101010;  //go next
                        #4
                        //当is_save_cu_out置为0时，不能马上将sel_adder放开，否则会导致要赋值给in和par的cu_out先给cu_computer_out再给adder_in最终将值输出从而造成结果出错
                        sel_adder = 8'b10101010;  
                        #4;   
                        sel_adder = 8'b00000000;   //在下次减法操作前，需要关闭进入加法树的通道，否则会让减法的结果输出
                    end
                    //计算完两个PE array的结果之后，将其累加，才是两张图片之间距离计算的输出
                    if(w == 1 || w == 3)begin
                        if(w == 1) begin
                            sort_ref_index = ref_index;
                        end else begin
                            sort_ref_index = ref_index + 1;
                        end
                        #4;  //这里需要等一下PE array的结果出来之后再输出
                        acc_is_stop = 1;  //输出结果，然后等2个时间单位，再清除累加和
                        #2
                        acc_is_stop = 0;  
                        //PE array 8列数据计算完成，清除内部累加寄存器，否则第二次循环的话，会把上一次的值累加
                        clear_reg_acc = 1'b1;
                        #2
                        clear_reg_acc = 1'b0;
                    end 
                    
                    #2;
                end
                //----------------- -------------------------从MLB读数据finish--------------------------------------------
            end
            #100;  //这里是为了给最后一个数据时间去处理
        end
        #100
        $finish; // 完成仿真
    end

endmodule
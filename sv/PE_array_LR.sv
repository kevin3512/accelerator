//LR模型
`timescale 1ns/1ns
module test_LR;
    parameter         REF_IMAGE_NUM = 60000;
    parameter         TEST_IMAGE_NUM = 10000;
    parameter         IMAGE_SIZE = 784;   //28*28
    parameter         BUFFER_SIZE = 2048;  //4 块 512
    parameter         TEST_N = 10;     //实际运行的测试用例数量
    parameter         REF_N = 1000;      //实际运行的参考用例数量（训练集）
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
    reg[7:0]          test_images[TEST_IMAGE_NUM-1:0][IMAGE_SIZE:0];
    reg[7:0]          test_labels[TEST_IMAGE_NUM-1:0]; 

    reg[31:0]         layer1_weights[784:0][9:0];
    reg[31:0]         layer1_weights_one_dim[7839:0];
    reg[31:0]         layer1_biases[9:0];

    reg[7:0]          layer1_input[784:0];  //784个图片的数据+1，用与和layer1_biases相乘计算


    reg               input_read_en;
    reg               input_write_en;
    reg               par_read_en;
    reg               par_write_en;
    reg               output_read_en;
    reg               output_write_en;
    reg[31:0]         input_buf_in[15:0];  //MLB和内存直连，从内存读数据到MLB，总共4块tile，每块512
    reg[31:0]         par_buf_in[63:0];
    wire[31:0]        wire_input_buf_out[15:0];  
    wire[31:0]        wire_par_buf_out[63:0];
    wire[31:0]        wire_output_buf_out[63:0];
    reg[1:0]          select_mlb;          //用于选择InputBuf的哪一个MLB
    reg[1:0]          sub_tile_idx_in;     //MLB切分为4块sub_tile，一个sub_tile切分为8块unit_tile
    reg[2:0]          unit_tile_idx_in;    //MLB切分为4块sub_tile，一个sub_tile切分为8块unit_tile
    reg[1:0]          sub_tile_idx_par;    
    reg[2:0]          unit_tile_idx_par;   
    reg[1:0]          sub_tile_idx_out;    
    reg[2:0]          unit_tile_idx_out; 

    integer           test_index;  //测试用例（测试集）下标
    integer           ref_index;  //参考用例（训练集）下标

    reg[4:0]          pe_idx;   //MLB一共32行PE存储空间, pe_idx表示第几行PE
    reg[3:0]          data_idx;  //PE一共有16个数，data_idx表示第几个数
    reg               is_scalar;

    //排序模块需要
    reg               clear_reg_sort;   //清除排序模块内部寄存器数据
    integer           sort_ref_index;
    reg[1:0]          input_mlb_num;    //输入到4块OutputBuffer的MLB中的哪一块
    reg               is_output_relu;
    reg[31:0]         relu_out[3:0];

    
    //acc累加模块需要的信号
    reg[2:0]          acc_sig;
    reg               acc_is_stop; 
    reg               clear_reg_acc;
    wire[31:0]        acc_scalar_output[3:0];

    //debug
    reg[7:0]        debug_test_image[9:0][783:0];
    reg[7:0]        debug_ref_image[59:0][783:0];
    integer         debug_hor_portion_id;
    reg[7:0]         debug;

    //Input buffer
    InputBuffer input_buf_ins(
        .clk(clk),
        .rst(rst),
        .select_in(input_buf_in),
        .select_mlb(select_mlb),   //输出的时候，用于选择指定MLB输出
        .input_read_en(input_read_en),
        .input_write_en(input_write_en),
        .sub_tile_idx(sub_tile_idx_in),
        .unit_tile_idx(unit_tile_idx_in),
        .select_out(wire_input_buf_out)
    );

    //Parameter buffer
    ParameterBuffer par_buf_ins(
        .clk(clk),
        .rst(rst),
        .in(par_buf_in),
        .par_read_en(par_read_en),
        .par_write_en(par_write_en),
        .sub_tile_idx(sub_tile_idx_par),
        .unit_tile_idx(unit_tile_idx_par),
        .out(wire_par_buf_out)
    );

    //Output buffer
    OutputBuffer output_buf_ins(
        .clk(clk),
        .rst(rst),
        .is_scalar(is_scalar),
        .in_scalar(relu_out),
        .pe_idx(pe_idx),
        .data_idx(data_idx),
        .output_read_en(output_read_en),
        .output_write_en(output_write_en),
        .sub_tile_idx(sub_tile_idx_out),
        .unit_tile_idx(unit_tile_idx_out),
        .out(wire_output_buf_out)
    );

    PE_array pe_array (
        .clk(clk),
        .rst(rst),
        .In0_0(wire_input_buf_out[0]), .In0_1(wire_input_buf_out[1]), .In0_2(wire_input_buf_out[2]), .In0_3(wire_input_buf_out[3]), .In0_4(wire_input_buf_out[4]), .In0_5(wire_input_buf_out[5]), .In0_6(wire_input_buf_out[6]), .In0_7(wire_input_buf_out[7]), .In0_8(wire_input_buf_out[8]), .In0_9(wire_input_buf_out[9]), .In0_10(wire_input_buf_out[10]), .In0_11(wire_input_buf_out[11]), .In0_12(wire_input_buf_out[12]), .In0_13(wire_input_buf_out[13]), .In0_14(wire_input_buf_out[14]), .In0_15(wire_input_buf_out[15]),
        .Par0_0(wire_par_buf_out[0]), .Par0_1(wire_par_buf_out[1]), .Par0_2(wire_par_buf_out[2]), .Par0_3(wire_par_buf_out[3]), .Par0_4(wire_par_buf_out[4]), .Par0_5(wire_par_buf_out[5]), .Par0_6(wire_par_buf_out[6]), .Par0_7(wire_par_buf_out[7]), .Par0_8(wire_par_buf_out[8]), .Par0_9(wire_par_buf_out[9]), .Par0_10(wire_par_buf_out[10]), .Par0_11(wire_par_buf_out[11]), .Par0_12(wire_par_buf_out[12]), .Par0_13(wire_par_buf_out[13]), .Par0_14(wire_par_buf_out[14]), .Par0_15(wire_par_buf_out[15]),
        .In1_0(wire_input_buf_out[0]), .In1_1(wire_input_buf_out[1]), .In1_2(wire_input_buf_out[2]), .In1_3(wire_input_buf_out[3]), .In1_4(wire_input_buf_out[4]), .In1_5(wire_input_buf_out[5]), .In1_6(wire_input_buf_out[6]), .In1_7(wire_input_buf_out[7]), .In1_8(wire_input_buf_out[8]), .In1_9(wire_input_buf_out[9]), .In1_10(wire_input_buf_out[10]), .In1_11(wire_input_buf_out[11]), .In1_12(wire_input_buf_out[12]), .In1_13(wire_input_buf_out[13]), .In1_14(wire_input_buf_out[14]), .In1_15(wire_input_buf_out[15]),
        .Par1_0(wire_par_buf_out[16]), .Par1_1(wire_par_buf_out[17]), .Par1_2(wire_par_buf_out[18]), .Par1_3(wire_par_buf_out[19]), .Par1_4(wire_par_buf_out[20]), .Par1_5(wire_par_buf_out[21]), .Par1_6(wire_par_buf_out[22]), .Par1_7(wire_par_buf_out[23]), .Par1_8(wire_par_buf_out[24]), .Par1_9(wire_par_buf_out[25]), .Par1_10(wire_par_buf_out[26]), .Par1_11(wire_par_buf_out[27]), .Par1_12(wire_par_buf_out[28]), .Par1_13(wire_par_buf_out[29]), .Par1_14(wire_par_buf_out[30]), .Par1_15(wire_par_buf_out[31]),
        .In2_0(wire_input_buf_out[0]), .In2_1(wire_input_buf_out[1]), .In2_2(wire_input_buf_out[2]), .In2_3(wire_input_buf_out[3]), .In2_4(wire_input_buf_out[4]), .In2_5(wire_input_buf_out[5]), .In2_6(wire_input_buf_out[6]), .In2_7(wire_input_buf_out[7]), .In2_8(wire_input_buf_out[8]), .In2_9(wire_input_buf_out[9]), .In2_10(wire_input_buf_out[10]), .In2_11(wire_input_buf_out[11]), .In2_12(wire_input_buf_out[12]), .In2_13(wire_input_buf_out[13]), .In2_14(wire_input_buf_out[14]), .In2_15(wire_input_buf_out[15]),
        .Par2_0(wire_par_buf_out[32]), .Par2_1(wire_par_buf_out[33]), .Par2_2(wire_par_buf_out[34]), .Par2_3(wire_par_buf_out[35]), .Par2_4(wire_par_buf_out[36]), .Par2_5(wire_par_buf_out[37]), .Par2_6(wire_par_buf_out[38]), .Par2_7(wire_par_buf_out[39]), .Par2_8(wire_par_buf_out[40]), .Par2_9(wire_par_buf_out[41]), .Par2_10(wire_par_buf_out[42]), .Par2_11(wire_par_buf_out[43]), .Par2_12(wire_par_buf_out[44]), .Par2_13(wire_par_buf_out[45]), .Par2_14(wire_par_buf_out[46]), .Par2_15(wire_par_buf_out[47]),
        .In3_0(wire_input_buf_out[0]), .In3_1(wire_input_buf_out[1]), .In3_2(wire_input_buf_out[2]), .In3_3(wire_input_buf_out[3]), .In3_4(wire_input_buf_out[4]), .In3_5(wire_input_buf_out[5]), .In3_6(wire_input_buf_out[6]), .In3_7(wire_input_buf_out[7]), .In3_8(wire_input_buf_out[8]), .In3_9(wire_input_buf_out[9]), .In3_10(wire_input_buf_out[10]), .In3_11(wire_input_buf_out[11]), .In3_12(wire_input_buf_out[12]), .In3_13(wire_input_buf_out[13]), .In3_14(wire_input_buf_out[14]), .In3_15(wire_input_buf_out[15]),
        .Par3_0(wire_par_buf_out[48]), .Par3_1(wire_par_buf_out[49]), .Par3_2(wire_par_buf_out[50]), .Par3_3(wire_par_buf_out[51]), .Par3_4(wire_par_buf_out[52]), .Par3_5(wire_par_buf_out[53]), .Par3_6(wire_par_buf_out[54]), .Par3_7(wire_par_buf_out[55]), .Par3_8(wire_par_buf_out[56]), .Par3_9(wire_par_buf_out[57]), .Par3_10(wire_par_buf_out[58]), .Par3_11(wire_par_buf_out[59]), .Par3_12(wire_par_buf_out[60]), .Par3_13(wire_par_buf_out[61]), .Par3_14(wire_par_buf_out[62]), .Par3_15(wire_par_buf_out[63]),
        .Col_index(col_index),
        .Sel_cu(sel_cu),
        .Sel_cu_go_back(sel_cu_go_back),
        .Sel_adder(sel_adder), 
        .Is_save_cu_out(is_save_cu_out),
        .Clear_reg(clear_reg),
        .Is_shift_right(1'b1),   //需要进行反量化操作——右移16位
        .Sum_row_pe(sum_row_pe),
        .Sum_column_pe(sum_column_pe),
        .Scalar_output0(scalar_output[0]), .Scalar_output1(scalar_output[1]), .Scalar_output2(scalar_output[2]), .Scalar_output3(scalar_output[3]),
        .Out0_0(out[0][0]), .Out0_1(out[0][1]), .Out0_2(out[0][2]), .Out0_3(out[0][3]), .Out0_4(out[0][4]), .Out0_5(out[0][5]), .Out0_6(out[0][6]), .Out0_7(out[0][7]), .Out0_8(out[0][8]), .Out0_9(out[0][9]), .Out0_10(out[0][10]), .Out0_11(out[0][11]), .Out0_12(out[0][12]), .Out0_13(out[0][13]), .Out0_14(out[0][14]), .Out0_15(out[0][15]),
        .Out1_0(out[1][0]), .Out1_1(out[1][1]), .Out1_2(out[1][2]), .Out1_3(out[1][3]), .Out1_4(out[1][4]), .Out1_5(out[1][5]), .Out1_6(out[1][6]), .Out1_7(out[1][7]), .Out1_8(out[1][8]), .Out1_9(out[1][9]), .Out1_10(out[1][10]), .Out1_11(out[1][11]), .Out1_12(out[1][12]), .Out1_13(out[1][13]), .Out1_14(out[1][14]), .Out1_15(out[1][15]),
        .Out2_0(out[2][0]), .Out2_1(out[2][1]), .Out2_2(out[2][2]), .Out2_3(out[2][3]), .Out2_4(out[2][4]), .Out2_5(out[2][5]), .Out2_6(out[2][6]), .Out2_7(out[2][7]), .Out2_8(out[2][8]), .Out2_9(out[2][9]), .Out2_10(out[2][10]), .Out2_11(out[2][11]), .Out2_12(out[2][12]), .Out2_13(out[2][13]), .Out2_14(out[2][14]), .Out2_15(out[2][15]),
        .Out3_0(out[3][0]), .Out3_1(out[3][1]), .Out3_2(out[3][2]), .Out3_3(out[3][3]), .Out3_4(out[3][4]), .Out3_5(out[3][5]), .Out3_6(out[3][6]), .Out3_7(out[3][7]), .Out3_8(out[3][8]), .Out3_9(out[3][9]), .Out3_10(out[3][10]), .Out3_11(out[3][11]), .Out3_12(out[3][12]), .Out3_13(out[3][13]), .Out3_14(out[3][14]), .Out3_15(out[3][15])
    );

    //累加模块
    acc_out acc_inst(
        .clk(clk), 
        .rst(rst), 
        .sig(acc_sig), 
        .data0(scalar_output[0]), .data1(scalar_output[1]), .data2(scalar_output[2]), .data3(scalar_output[3]), 
        .isStop0(acc_is_stop), .isStop1(acc_is_stop), .isStop2(acc_is_stop), .isStop3(acc_is_stop),
        .out0(acc_scalar_output[0]), .out1(acc_scalar_output[1]), .out2(acc_scalar_output[2]), .out3(acc_scalar_output[3]), 
        .clear_reg0(clear_reg_acc), .clear_reg1(clear_reg_acc), .clear_reg2(clear_reg_acc), .clear_reg3(clear_reg_acc));

    //排序模块
    sort_relu sort_isnt0(
        .clk(clk), 
        .rst(rst), 
        .in(acc_scalar_output[0]), 
        .sig(4'b0010),     //ReLu激活函数
        .asce(1'b1), 
        .is_output(is_output_relu), 
        .clear_reg(clear_reg_sort), 
        .out(relu_out[0])); 

    sort_relu sort_isnt1(
        .clk(clk), 
        .rst(rst), 
        .in(acc_scalar_output[1]), 
        .sig(4'b0010),     //ReLu激活函数
        .asce(1'b1), 
        .is_output(is_output_relu), 
        .clear_reg(clear_reg_sort), 
        .out(relu_out[1])); 

    sort_relu sort_isnt2(
        .clk(clk), 
        .rst(rst), 
        .in(acc_scalar_output[2]), 
        .sig(4'b0010),     //ReLu激活函数
        .asce(1'b1), 
        .is_output(is_output_relu), 
        .clear_reg(clear_reg_sort), 
        .out(relu_out[2])); 

    sort_relu sort_isnt3(
        .clk(clk), 
        .rst(rst), 
        .in(acc_scalar_output[3]), 
        .sig(4'b0010),     //ReLu激活函数
        .asce(1'b1), 
        .is_output(is_output_relu), 
        .clear_reg(clear_reg_sort), 
        .out(relu_out[3])); 

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

    //读取MNIST手写图片数据集（每张图片28*28)和DNN模型训练好的参数
    task read_dataset_and_parameters;
        output test_images;
        output test_labels;
        output layer1_weights;
        output layer1_biases;
        reg[7:0]        test_images[TEST_IMAGE_NUM-1:0][IMAGE_SIZE:0];
        reg[7:0]        test_labels[TEST_IMAGE_NUM-1:0]; 
        reg[31:0]       layer1_weights[784:0][9:0];
        reg[31:0]       layer1_weights_one_dim[7839:0];
        reg[31:0]       layer1_biases[9:0];

        begin
            $readmemh("mnist_dataset/test-images.hex", test_images);
            $readmemh("mnist_dataset/test-labels.hex", test_labels);
            $readmemh("mnist_dataset/LR_weights_784x10.hex", layer1_weights_one_dim);
            $readmemh("mnist_dataset/LR_biases_10.hex", layer1_biases);


            // 将一维数组映射到二维数组
            for (integer i=0; i<784; i=i+1) begin
                for (integer j=0; j<19; j=j+1) begin
                    layer1_weights[i][j] = layer1_weights_one_dim[i*10+j];
                end
            end

        end

    endtask


    task load_layer1_inputs;
        // 添加一个1到所有images的最后一个位置 ， 用与和偏置值biase相乘
        layer1_input[783:0] = test_images[test_index][783:0];
        layer1_input[784] = 8'b1;
        // 将 biased 添加到 weights 的最后一行
        layer1_weights[784][9:0] = layer1_biases[9:0];
    endtask


    initial begin
        // 读取数据集和DNN模型参数到内存
        read_dataset_and_parameters(test_images, test_labels, layer1_weights, layer1_biases);
        $display("layer1_weight:%h" , layer1_weights[783][9]);
        for(integer kk1 = 0; kk1 < 10; kk1 = kk1 + 1)begin
            debug_test_image[kk1][783:0] = test_images[kk1][783:0];
        end
        for(integer kk2 = 0; kk2 < 60; kk2 = kk2 + 1)begin
            debug_ref_image[kk2][783:0] = ref_images[kk2][783:0];
        end
        //总共对多少张测试图片进行分类
        for(test_index = 0; test_index < TEST_N; test_index = test_index + 1)begin
            $display("正在计算第%0d张测试图片的分类结果", test_index);
            //-------------------------------计算L1层结果start-------------------------
            //加载L1层的输入和权重数据
            load_layer1_inputs();
            //写入一张图片数据到InputBuffer
            input_read_en = 0;
            input_write_en = 1;
            for(integer col = 0, num = 0; col < 2; col = col + 1)begin  //一张图片保存2列
                select_mlb = col;
                for(integer row = 0; row < 32; row = row + 1)begin  //第一列保存32行，第二列保存6行
                    sub_tile_idx_in = row / 8;
                    unit_tile_idx_in = row % 8;
                    for(integer k = 0; k < 16; k = k + 1)begin
                        num = col*512+row*16+k;
                        if(num <= 784)begin
                            input_buf_in[k] = layer1_input[num];  //按列优先的顺序来依次写入到InputBuf
                        end else begin
                            input_buf_in[k] = 0;
                        end
                    end
                    #2;
                end
                
            end
            debug = 8'h12;
            //开始进行L1层的数据计算，将10个数据分成3段去求，每一段的4个值求出来了，再求下一段
            for(integer hor_portion_id = 0, col_start = 0; hor_portion_id < 3; hor_portion_id = hor_portion_id + 1)begin
                col_start = 4 * hor_portion_id;
                clear_reg_acc = 1;  //清除累加值acc_data，避免第二段数据求值的时候，继续被累加sub_idx
                #2
                clear_reg_acc = 0;
                //垂直取weights（784*9）的数据，取满InputBuf共2轮，计算出最终的4/10个数
                for(integer ver_portion_id = 0, row_start = 0; ver_portion_id < 2; ver_portion_id = ver_portion_id + 1)begin 
                    row_start = 512 * ver_portion_id;  //每组取32个PE的数据，每个PE取16个数
                    select_mlb = ver_portion_id;
                    //从内存中读满参数到parameter中
                    par_write_en = 1;
                    par_read_en = 0; 
                    for(integer i = 0, row_num = 0; i < 32; i++)begin  //总共32行
                        for(int j = 0; j < 4; j++)begin   //4列
                            for(int k = 0; k < 16; k++)begin //每个PE有16个数
                                row_num = row_start+i*16+k;
                                sub_tile_idx_par = i/8;
                                unit_tile_idx_par = i%8;
                                if(row_num <= 784)begin
                                    par_buf_in[j*16+k] = layer1_weights[row_start+i*16+k][col_start+j];
                                end else begin
                                    par_buf_in[j*16+k] = 0;
                                end
                            end
                            #2;
                        end
                    end

                    //从InputBuf和ParmeterBuf开始读数据到PE array中计算
                    input_read_en = 1;
                    input_write_en = 0;
                    par_read_en = 1;
                    par_write_en = 0;
                    for(integer sub_idx = 0; sub_idx < 4; sub_idx ++)begin  //4轮PE-array才能计算完全部InputBuf和ParBuf
                        sub_tile_idx_in = sub_idx;
                        sub_tile_idx_par = sub_idx;
                        sum_row_pe = 2'b10;    
                        sum_column_pe = 2'b01;  // 输出一行PE的和到scalar_out[3:0]
                        is_save_cu_out = 4'b0000;
                        clear_reg = 1'b0;  //reset last time running value 1
                        acc_sig = 3'b1;
                        acc_is_stop = 0;
                        clear_reg_acc = 0;
                        col_index = 3'bxxx;   //需要保证在清除之前就变为0，防止清除数据后col_index还是为7，从而极速计算
                        clear_reg = 1'b1;   //一组PE array计算之前，需要清除上一次PE array计算的结果，防止在本次计算中继续叠加
                        #2
                        clear_reg = 1'b0;
                        for(integer unit_idx = 0; unit_idx < 8; unit_idx ++)begin //每一轮需要8次读数据到PE-array， unit_idx = col_index
                            col_index = unit_idx;
                            unit_tile_idx_in = unit_idx;
                            unit_tile_idx_par = unit_idx;
                            is_save_cu_out = 4'b0000;
                            sel_cu = 8'b11111111;   //multiplication
                            sel_cu_go_back = 8'b10101010;  //go next
                            sel_adder = 8'b10101010;  //adder tree
                            if(ver_portion_id == 1 && sub_idx == 2 && unit_idx == 1)begin  //表示2轮InputBuf和ParmeterBuf的数据都读取完了，Acc累加完毕, acc保存的就是最终值，进入下一步激活ReLu
                                debug = 8'h1f;
                                //acc输入到ReLu
                                #4;  //这里需要等一下PE array的结果出来之后再输出
                                acc_is_stop = 1;  //输出结果，然后等2个时间单位，再清除累加和
                                is_scalar = 1;
                                //ReLu输入到OutputBuf
                                is_output_relu = 1;
                                //写入OutputBuf相关信号准备
                                output_write_en = 1;
                                output_read_en = 0;
                                
                                data_idx = hor_portion_id % 16;   //一组hor_portion循环保存4个数，16个保存64个数
                                pe_idx = hor_portion_id / 16;
                                #4
                                acc_is_stop = 0;  
                                //PE array 8列数据计算完成，清除内部累加寄存器，否则第二次循环的话，会把上一次的值累加
                                clear_reg_acc = 1'b1;
                                #2
                                clear_reg_acc = 1'b0;
                                output_write_en = 0;
                                output_read_en = 0;

                                #100;
                            end else begin   //数据输出到acc就结束了（4个数）
                                acc_is_stop = 0;
                            end

                            #2;
                        end
                    end
                end
            end
            //--------------------------------计算L1层结果finish-----------------------

            
        end
        #100
        $finish; // 完成仿真
    end

endmodule
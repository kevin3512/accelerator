`timescale 1ns/1ns
module test_dnn;
    parameter                     REF_IMAGE_NUM = 60000;
    parameter                     TEST_IMAGE_NUM = 10000;
    parameter                     IMAGE_SIZE = 784;   //28*28
    parameter                     K = 20;
    parameter                     TESE_N = 1000;     //实际运行的测试用例数量
    parameter                     REF_N = 1000;      //实际运行的参考用例数量（训练集）
    reg[7:0]                      ref_images[REF_IMAGE_NUM-1:0][IMAGE_SIZE-1:0];
    reg[7:0]                      ref_labels[REF_IMAGE_NUM-1:0]; 
    reg[7:0]                      test_images[TEST_IMAGE_NUM-1:0][IMAGE_SIZE:0];
    reg[7:0]                      test_labels[TEST_IMAGE_NUM-1:0]; 
    reg[31:0]                     layer1_weights[784:0][1023:0];
    reg[31:0]                     layer1_weights_one_dim[802815:0];
    reg[31:0]                     layer1_biases[1023:0];
    reg[31:0]                     layer2_weights[1024:0][511:0];
    reg[31:0]                     layer2_weights_one_dim[524287:0];
    reg[31:0]                     layer2_biases[511:0];
    reg[31:0]                     layer3_weights[512:0][255:0];
    reg[31:0]                     layer3_weights_one_dim[131071:0];
    reg[31:0]                     layer3_biases[255:0];
    reg[31:0]                     layer4_weights[256:0][9:0];
    reg[31:0]                     layer4_weights_one_dim[2559:0];
    reg[31:0]                     layer4_biases[9:0];

    reg[7:0]                      layer1_input[784:0];  //784个图片的数据+1，用与和layer1_biases相乘计算
    reg[31:0]                     layer2_input[1024:0];  //1024个layer1的输出+1，用于和layer2_biase相乘计算
    reg[31:0]                     layer3_input[512:0];  //512个layer2的输出+1，用于和layer3_biases相乘计算
    reg[31:0]                     layer4_input[256:0];  //256个layer3的输出+1,用与和layer4_biases相乘计算

    integer                       test_index;  //测试用例（测试集）下标
    integer                       ref_index;  //参考用例（训练集）下标
    integer                       group_idx;  //进行几轮计算
    reg[31:0]                     hot_buff_in[15:0];   //hotbuff的输入
    reg[31:0]                     cold_buff_in[255:0];  //coldbuffer的输入
    wire[31:0]                    wire_hotmlu_in[15:0];   //MLU的输入 , 总共16组MLU，每个MLU需要16个数据，每个数据16bit
    wire[31:0]                    wire_coldmlu_in[255:0];  //MLU的输入
    reg[7:0]                      hot_idx;    //hotbuff读写的下标
    reg[4:0]                      cold_idx;
    reg[3:0]                      outbuf_idx;  //outputbuff读写的下标
    wire[3:0]                     wire_mlu_idx;    //控制MLU第几组的下标
    reg                           hot_read_en;
    reg                           hot_write_en;
    reg                           cold_read_en;
    reg                           cold_write_en;
    reg                           output_read_en;
    reg                           output_write_en;

    reg                           clk;
    reg                           rst;
    reg[2:0]                      sel_output;      //选择输出哪一部分
    // Adder部分需要的输入
    reg[1:0]                      symbol;
    //  Multiplier部分需要的输入
    reg                           sel_in;
    reg[7:0]                      shift_right;        //反量化，右移16位
    // Acc部分需要的输入
    reg                           is_output;
    reg                           clear_reg_acc;      //清除acc寄存器信号
    // Misc部分需要的输入
    reg[31:0]                     index;
    reg[2:0]                      fun_id;       //非线性函数id
    reg                           asce;   //升序排序信号，1表示升序（从小到大排列），0表示降序
    reg                           clear_reg_sort;     //清除排序模块寄存器数据
    reg[31:0]                     mlu_count;           //vector输出计数，用与输出的长度超过16的情况
    reg[31:0]                     out_scalar[15:0];  //总共有16组结果，每组1个数据
    reg[31:0]                     out_vector[15:0][15:0];  //总共有16组结果，每组16位数据
    // ALU部分需要的输入
    reg[1:0]                      alu_select;       //alu选择哪一个输入
    reg[3:0]                      alu_run_case;
    reg[31:0]                     alu_in_count;    //alu输入count
    reg[31:0]                     alu_out_count;   //alu输出count
    reg[31:0]                     out_vector_collect[47:0][15:0];
    reg[31:0]                     out_sort[15:0][K-1:0];
    reg[31:0]                     out_sort_index[15:0][K-1:0];
    wire[31:0]                    wire_alu_out[255:0];         

    // OutputBuffer的输出
    wire[31:0]                    wire_outputbuf_out[255:0]; 

    //debug
    reg[7:0]                      debug_test_image[31:0][783:0];
    reg[7:0]                      debug_ref_image[29:0][783:0];
            

    HotBuffer hotbuf_ins(.clk(clk), .rst(rst), .in(hot_buff_in), .idx(hot_idx), .read_en(hot_read_en), .write_en(hot_write_en), .out(wire_hotmlu_in));
    ColdBuffer coldbuf_ins(.clk(clk), .rst(rst), .in(cold_buff_in), .idx(cold_idx), .read_en(cold_read_en), .write_en(cold_write_en), .out(wire_coldmlu_in));

    MLU MLU_ins0(
        .clk(clk),
        .rst(rst),
        .hot_in(wire_hotmlu_in), 
        .cold_in(wire_coldmlu_in[15:0]), 
        .sel_output(sel_output),
        .symbol(symbol), 
        .sel_in(sel_in), 
        .shift_right(shift_right),
        .is_output(is_output), 
        .clear_reg_acc(clear_reg_acc), 
        .index(index), 
        .fun_id(fun_id), 
        .asce(asce),
        .clear_reg_sort(clear_reg_sort), 
        .count(mlu_count),
        .out_scalar(out_scalar[0]),
        .out_vector(out_vector[0]));

    MLU MLU_ins1(
        .clk(clk),
        .rst(rst),
        .hot_in(wire_hotmlu_in), 
        .cold_in(wire_coldmlu_in[31:16]), 
        .sel_output(sel_output),
        .symbol(symbol),  
        .sel_in(sel_in), 
        .shift_right(shift_right),
        .is_output(is_output), 
        .clear_reg_acc(clear_reg_acc), 
        .index(index), 
        .fun_id(fun_id), 
        .asce(asce),
        .clear_reg_sort(clear_reg_sort), 
        .count(mlu_count),
        .out_scalar(out_scalar[1]),
        .out_vector(out_vector[1]));

    MLU MLU_ins2(
        .clk(clk),
        .rst(rst),
        .hot_in(wire_hotmlu_in), 
        .cold_in(wire_coldmlu_in[47:32]), 
        .sel_output(sel_output),
        .symbol(symbol),  
        .sel_in(sel_in), 
        .shift_right(shift_right),
        .is_output(is_output), 
        .clear_reg_acc(clear_reg_acc), 
        .index(index), 
        .fun_id(fun_id), 
        .asce(asce),
        .clear_reg_sort(clear_reg_sort), 
        .count(mlu_count),
        .out_scalar(out_scalar[2]),
        .out_vector(out_vector[2]));

    MLU MLU_ins3(
        .clk(clk),
        .rst(rst),
        .hot_in(wire_hotmlu_in), 
        .cold_in(wire_coldmlu_in[63:48]), 
        .sel_output(sel_output),
        .symbol(symbol),  
        .sel_in(sel_in), 
        .shift_right(shift_right),
        .is_output(is_output), 
        .clear_reg_acc(clear_reg_acc), 
        .index(index), 
        .fun_id(fun_id), 
        .asce(asce),
        .clear_reg_sort(clear_reg_sort), 
        .count(mlu_count),
        .out_scalar(out_scalar[3]),
        .out_vector(out_vector[3]));

    MLU MLU_ins4(
        .clk(clk),
        .rst(rst),
        .hot_in(wire_hotmlu_in), 
        .cold_in(wire_coldmlu_in[79:64]), 
        .sel_output(sel_output),
        .symbol(symbol),  
        .sel_in(sel_in), 
        .shift_right(shift_right),
        .is_output(is_output), 
        .clear_reg_acc(clear_reg_acc), 
        .index(index), 
        .fun_id(fun_id), 
        .asce(asce),
        .clear_reg_sort(clear_reg_sort), 
        .count(mlu_count),
        .out_scalar(out_scalar[4]),
        .out_vector(out_vector[4]));

    MLU MLU_ins5(
        .clk(clk),
        .rst(rst),
        .hot_in(wire_hotmlu_in), 
        .cold_in(wire_coldmlu_in[95:80]), 
        .sel_output(sel_output),
        .symbol(symbol),  
        .sel_in(sel_in), 
        .shift_right(shift_right),
        .is_output(is_output), 
        .clear_reg_acc(clear_reg_acc), 
        .index(index), 
        .fun_id(fun_id), 
        .asce(asce),
        .clear_reg_sort(clear_reg_sort), 
        .count(mlu_count),
        .out_scalar(out_scalar[5]),
        .out_vector(out_vector[5]));

    MLU MLU_ins6(
        .clk(clk),
        .rst(rst),
        .hot_in(wire_hotmlu_in), 
        .cold_in(wire_coldmlu_in[111:96]), 
        .sel_output(sel_output),
        .symbol(symbol),  
        .sel_in(sel_in), 
        .shift_right(shift_right),
        .is_output(is_output), 
        .clear_reg_acc(clear_reg_acc), 
        .index(index), 
        .fun_id(fun_id), 
        .asce(asce),
        .clear_reg_sort(clear_reg_sort), 
        .count(mlu_count),
        .out_scalar(out_scalar[6]),
        .out_vector(out_vector[6]));

    MLU MLU_ins7(
        .clk(clk),
        .rst(rst),
        .hot_in(wire_hotmlu_in), 
        .cold_in(wire_coldmlu_in[127:112]), 
        .sel_output(sel_output),
        .symbol(symbol),  
        .sel_in(sel_in), 
        .shift_right(shift_right),
        .is_output(is_output), 
        .clear_reg_acc(clear_reg_acc), 
        .index(index), 
        .fun_id(fun_id), 
        .asce(asce),
        .clear_reg_sort(clear_reg_sort), 
        .count(mlu_count),
        .out_scalar(out_scalar[7]),
        .out_vector(out_vector[7]));

    MLU MLU_ins8(
        .clk(clk),
        .rst(rst),
        .hot_in(wire_hotmlu_in), 
        .cold_in(wire_coldmlu_in[143:128]), 
        .sel_output(sel_output),
        .symbol(symbol),  
        .sel_in(sel_in), 
        .shift_right(shift_right),
        .is_output(is_output), 
        .clear_reg_acc(clear_reg_acc), 
        .index(index), 
        .fun_id(fun_id), 
        .asce(asce),
        .clear_reg_sort(clear_reg_sort), 
        .count(mlu_count),
        .out_scalar(out_scalar[8]),
        .out_vector(out_vector[8]));

    MLU MLU_ins9(
        .clk(clk),
        .rst(rst),
        .hot_in(wire_hotmlu_in), 
        .cold_in(wire_coldmlu_in[159:144]), 
        .sel_output(sel_output),
        .symbol(symbol),  
        .sel_in(sel_in), 
        .shift_right(shift_right),
        .is_output(is_output), 
        .clear_reg_acc(clear_reg_acc), 
        .index(index), 
        .fun_id(fun_id), 
        .asce(asce),
        .clear_reg_sort(clear_reg_sort), 
        .count(mlu_count),
        .out_scalar(out_scalar[9]),
        .out_vector(out_vector[9]));

    MLU MLU_ins10(
        .clk(clk),
        .rst(rst),
        .hot_in(wire_hotmlu_in), 
        .cold_in(wire_coldmlu_in[175:160]), 
        .sel_output(sel_output),
        .symbol(symbol),  
        .sel_in(sel_in), 
        .shift_right(shift_right),
        .is_output(is_output), 
        .clear_reg_acc(clear_reg_acc), 
        .index(index), 
        .fun_id(fun_id), 
        .asce(asce),
        .clear_reg_sort(clear_reg_sort), 
        .count(mlu_count),
        .out_scalar(out_scalar[10]),
        .out_vector(out_vector[10]));

    MLU MLU_ins11(
        .clk(clk),
        .rst(rst),
        .hot_in(wire_hotmlu_in), 
        .cold_in(wire_coldmlu_in[191:176]), 
        .sel_output(sel_output),
        .symbol(symbol),  
        .sel_in(sel_in), 
        .shift_right(shift_right),
        .is_output(is_output), 
        .clear_reg_acc(clear_reg_acc), 
        .index(index), 
        .fun_id(fun_id), 
        .asce(asce),
        .clear_reg_sort(clear_reg_sort), 
        .count(mlu_count),
        .out_scalar(out_scalar[11]),
        .out_vector(out_vector[11]));

    MLU MLU_ins12(
        .clk(clk),
        .rst(rst),
        .hot_in(wire_hotmlu_in), 
        .cold_in(wire_coldmlu_in[207:192]), 
        .sel_output(sel_output),
        .symbol(symbol),  
        .sel_in(sel_in), 
        .shift_right(shift_right),
        .is_output(is_output), 
        .clear_reg_acc(clear_reg_acc), 
        .index(index), 
        .fun_id(fun_id), 
        .asce(asce),
        .clear_reg_sort(clear_reg_sort), 
        .count(mlu_count),
        .out_scalar(out_scalar[12]),
        .out_vector(out_vector[12]));

    MLU MLU_ins13(
        .clk(clk),
        .rst(rst),
        .hot_in(wire_hotmlu_in), 
        .cold_in(wire_coldmlu_in[223:208]), 
        .sel_output(sel_output),
        .symbol(symbol),  
        .sel_in(sel_in), 
        .shift_right(shift_right),
        .is_output(is_output), 
        .clear_reg_acc(clear_reg_acc), 
        .index(index), 
        .fun_id(fun_id), 
        .asce(asce),
        .clear_reg_sort(clear_reg_sort), 
        .count(mlu_count),
        .out_scalar(out_scalar[13]),
        .out_vector(out_vector[13]));

    MLU MLU_ins14(
        .clk(clk),
        .rst(rst),
        .hot_in(wire_hotmlu_in), 
        .cold_in(wire_coldmlu_in[239:224]), 
        .sel_output(sel_output),
        .symbol(symbol),  
        .sel_in(sel_in), 
        .shift_right(shift_right),
        .is_output(is_output), 
        .clear_reg_acc(clear_reg_acc), 
        .index(index), 
        .fun_id(fun_id), 
        .asce(asce),
        .clear_reg_sort(clear_reg_sort), 
        .count(mlu_count),
        .out_scalar(out_scalar[14]),
        .out_vector(out_vector[14]));

    MLU MLU_ins15(
        .clk(clk),
        .rst(rst),
        .hot_in(wire_hotmlu_in), 
        .cold_in(wire_coldmlu_in[255:240]), 
        .sel_output(sel_output),
        .symbol(symbol),  
        .sel_in(sel_in), 
        .shift_right(shift_right),
        .is_output(is_output), 
        .clear_reg_acc(clear_reg_acc), 
        .index(index), 
        .fun_id(fun_id), 
        .asce(asce),
        .clear_reg_sort(clear_reg_sort), 
        .count(mlu_count),
        .out_scalar(out_scalar[15]),
        .out_vector(out_vector[15]));

    
    ALU alu_ins0(.clk(clk), .rst(rst), .select(alu_select), .in(out_scalar[0]), .in_mlu(out_vector[0]), .in_output(wire_outputbuf_out[15:0]), .in_count(alu_in_count), .out_count(alu_out_count), .run_case(alu_run_case), .is_asce_sort(1'b1), .out(wire_alu_out[15:0]));
    
    ALU alu_ins1(.clk(clk), .rst(rst), .select(alu_select), .in(out_scalar[1]), .in_mlu(out_vector[1]), .in_output(wire_outputbuf_out[31:16]), .in_count(alu_in_count), .out_count(alu_out_count), .run_case(alu_run_case), .is_asce_sort(1'b1), .out(wire_alu_out[31:16]));
    
    ALU alu_ins2(.clk(clk), .rst(rst), .select(alu_select), .in(out_scalar[2]), .in_mlu(out_vector[2]), .in_output(wire_outputbuf_out[47:32]), .in_count(alu_in_count), .out_count(alu_out_count), .run_case(alu_run_case), .is_asce_sort(1'b1), .out(wire_alu_out[47:32]));

    ALU alu_ins3(.clk(clk), .rst(rst), .select(alu_select), .in(out_scalar[3]), .in_mlu(out_vector[3]), .in_output(wire_outputbuf_out[63:48]), .in_count(alu_in_count), .out_count(alu_out_count), .run_case(alu_run_case), .is_asce_sort(1'b1), .out(wire_alu_out[63:48]));

    ALU alu_ins4(.clk(clk), .rst(rst), .select(alu_select), .in(out_scalar[4]), .in_mlu(out_vector[4]), .in_output(wire_outputbuf_out[79:64]), .in_count(alu_in_count), .out_count(alu_out_count), .run_case(alu_run_case), .is_asce_sort(1'b1), .out(wire_alu_out[79:64]));

    ALU alu_ins5(.clk(clk), .rst(rst), .select(alu_select), .in(out_scalar[5]), .in_mlu(out_vector[5]), .in_output(wire_outputbuf_out[95:80]), .in_count(alu_in_count), .out_count(alu_out_count), .run_case(alu_run_case), .is_asce_sort(1'b1), .out(wire_alu_out[95:80]));

    ALU alu_ins6(.clk(clk), .rst(rst), .select(alu_select), .in(out_scalar[6]), .in_mlu(out_vector[6]), .in_output(wire_outputbuf_out[111:96]), .in_count(alu_in_count), .out_count(alu_out_count), .run_case(alu_run_case), .is_asce_sort(1'b1), .out(wire_alu_out[111:96]));

    ALU alu_ins7(.clk(clk), .rst(rst), .select(alu_select), .in(out_scalar[7]), .in_mlu(out_vector[7]), .in_output(wire_outputbuf_out[127:112]), .in_count(alu_in_count), .out_count(alu_out_count), .run_case(alu_run_case), .is_asce_sort(1'b1), .out(wire_alu_out[127:112]));

    ALU alu_ins8(.clk(clk), .rst(rst), .select(alu_select), .in(out_scalar[8]), .in_mlu(out_vector[8]), .in_output(wire_outputbuf_out[143:128]), .in_count(alu_in_count), .out_count(alu_out_count), .run_case(alu_run_case), .is_asce_sort(1'b1), .out(wire_alu_out[143:128]));

    ALU alu_ins9(.clk(clk), .rst(rst), .select(alu_select), .in(out_scalar[9]), .in_mlu(out_vector[9]), .in_output(wire_outputbuf_out[159:144]), .in_count(alu_in_count), .out_count(alu_out_count), .run_case(alu_run_case), .is_asce_sort(1'b1), .out(wire_alu_out[159:144]));

    ALU alu_ins10(.clk(clk), .rst(rst), .select(alu_select), .in(out_scalar[10]), .in_mlu(out_vector[10]), .in_output(wire_outputbuf_out[175:160]), .in_count(alu_in_count), .out_count(alu_out_count), .run_case(alu_run_case), .is_asce_sort(1'b1), .out(wire_alu_out[175:160]));

    ALU alu_ins11(.clk(clk), .rst(rst), .select(alu_select), .in(out_scalar[11]), .in_mlu(out_vector[11]), .in_output(wire_outputbuf_out[191:176]), .in_count(alu_in_count), .out_count(alu_out_count), .run_case(alu_run_case), .is_asce_sort(1'b1), .out(wire_alu_out[191:176]));

    ALU alu_ins12(.clk(clk), .rst(rst), .select(alu_select), .in(out_scalar[12]), .in_mlu(out_vector[12]), .in_output(wire_outputbuf_out[207:192]), .in_count(alu_in_count), .out_count(alu_out_count), .run_case(alu_run_case), .is_asce_sort(1'b1), .out(wire_alu_out[207:192]));

    ALU alu_ins13(.clk(clk), .rst(rst), .select(alu_select), .in(out_scalar[13]), .in_mlu(out_vector[13]), .in_output(wire_outputbuf_out[223:208]), .in_count(alu_in_count), .out_count(alu_out_count), .run_case(alu_run_case), .is_asce_sort(1'b1), .out(wire_alu_out[223:208]));

    ALU alu_ins14(.clk(clk), .rst(rst), .select(alu_select), .in(out_scalar[14]), .in_mlu(out_vector[14]), .in_output(wire_outputbuf_out[239:224]), .in_count(alu_in_count), .out_count(alu_out_count), .run_case(alu_run_case), .is_asce_sort(1'b1), .out(wire_alu_out[239:224]));

    ALU alu_ins15(.clk(clk), .rst(rst), .select(alu_select), .in(out_scalar[15]), .in_mlu(out_vector[15]), .in_output(wire_outputbuf_out[255:240]), .in_count(alu_in_count), .out_count(alu_out_count), .run_case(alu_run_case), .is_asce_sort(1'b1), .out(wire_alu_out[255:240]));

    OutputBuffer outputbuf_ins(.clk(clk), .rst(rst), .in(wire_alu_out), .idx(outbuf_idx), .read_en(output_read_en), .write_en(output_write_en), .out(wire_outputbuf_out));
 
    //读取MNIST手写图片数据集（每张图片28*28)和DNN模型训练好的参数
    task read_dataset_and_parameters;
        output test_images;
        output test_labels;
        output layer1_weights;
        output layer1_biases;
        output layer2_weights;
        output layer2_biases;
        output layer3_weights;
        output layer3_biases;
        output layer4_weights;
        output layer4_biases;
        reg[7:0]        test_images[TEST_IMAGE_NUM-1:0][IMAGE_SIZE:0];
        reg[7:0]        test_labels[TEST_IMAGE_NUM-1:0]; 
        reg[31:0]       layer1_weights[784:0][1023:0];
        reg[31:0]       layer1_weights_one_dim[802815:0];
        reg[31:0]       layer1_biases[1023:0];
        reg[31:0]       layer2_weights[1024:0][511:0];
        reg[31:0]       layer2_weights_one_dim[524287:0];
        reg[31:0]       layer2_biases[511:0];
        reg[31:0]       layer3_weights[512:0][255:0];
        reg[31:0]       layer3_weights_one_dim[131071:0];
        reg[31:0]       layer3_biases[255:0];
        reg[31:0]       layer4_weights[256:0][9:0];
        reg[31:0]       layer4_weights_one_dim[2559:0];
        reg[31:0]       layer4_biases[9:0];


        begin
            $readmemh("mnist_dataset/test-images.hex", test_images);
            $readmemh("mnist_dataset/test-labels.hex", test_labels);
            $readmemh("mnist_dataset/layer1_weights_784x1024.hex", layer1_weights_one_dim);
            $readmemh("mnist_dataset/layer1_biases_1024.hex", layer1_biases);

            $readmemh("mnist_dataset/layer2_weights_1024x512.hex", layer2_weights_one_dim);
            $readmemh("mnist_dataset/layer2_biases_512.hex", layer2_biases);

            $readmemh("mnist_dataset/layer3_weights_512x256.hex", layer3_weights_one_dim);
            $readmemh("mnist_dataset/layer3_biases_256.hex", layer3_biases);

            $readmemh("mnist_dataset/layer4_weights_256x10.hex", layer4_weights_one_dim);
            $readmemh("mnist_dataset/layer4_biases_10.hex", layer4_biases);

            // 将一维数组映射到二维数组
            for (integer i=0; i<784; i=i+1) begin
                for (integer j=0; j<1024; j=j+1) begin
                    layer1_weights[i][j] = layer1_weights_one_dim[i*1024+j];
                end
            end

            for (integer i2=0; i2<1024; i2=i2+1) begin
                for (integer j2=0; j2<512; j2=j2+1) begin
                    layer2_weights[i2][j2] = layer2_weights_one_dim[i2*512+j2];
                end
            end

            for (integer i=0; i<512; i=i+1) begin
                for (integer j=0; j<256; j=j+1) begin
                    layer3_weights[i][j] = layer3_weights_one_dim[i*256+j];
                end
            end

            for (integer i=0; i<256; i=i+1) begin
                for (integer j=0; j<10; j=j+1) begin
                    layer4_weights[i][j] = layer4_weights_one_dim[i*10+j];
                end
            end
        end

    endtask

    task load_layer1_inputs;
        // 添加一个1到所有images的最后一个位置 ， 用与和偏置值biase相乘
        layer1_input[783:0] = test_images[test_index][783:0];
        layer1_input[784] = 8'b1;
        // 将 biased 添加到 weights 的最后一行
        layer1_weights[784][1023:0] = layer1_biases[1023:0];
    endtask

    //从OutputBuffer读取layer1_input数据
    task load_layer2_inputs;
        output_read_en = 1;
        output_write_en = 0;
        outbuf_idx = 0;
        #4
        layer2_input[255:0] = wire_outputbuf_out[255:0];
        outbuf_idx = 1;
        #4
        layer2_input[511:256] = wire_outputbuf_out[255:0];
        outbuf_idx = 2;
        #4
        layer2_input[767:512] = wire_outputbuf_out[255:0];
        outbuf_idx = 3;
        #4
        layer2_input[1023:768] = wire_outputbuf_out[255:0];
        layer2_input[1024] = 1;  //最后一个给1是为了和biases相乘计算
        // 将 biased 添加到 weights 的最后一行
        layer2_weights[1024] = layer2_biases;
    endtask

    //从OutputBuffer读取layer3_input数据
    task load_layer3_inputs;
        output_read_en = 1;
        output_write_en = 0;
        outbuf_idx = 0;
        #4
        layer3_input[255:0] = wire_outputbuf_out[255:0];
        outbuf_idx = 1;
        #4
        layer3_input[511:256] = wire_outputbuf_out[255:0];
        
        layer3_input[512] = 1;  //最后一个给1是为了和biases相乘计算
        // 将 biased 添加到 weights 的最后一行
        layer3_weights[512] = layer3_biases;
    endtask

    //从OutputBuffer读取layer4_input数据
    task load_layer4_inputs;
        output_read_en = 1;
        output_write_en = 0;
        outbuf_idx = 0;
        #4
        layer4_input[255:0] = wire_outputbuf_out[255:0];
        layer4_input[256] = 1;  //最后一个给1是为了和biases相乘计算
        // 将 biased 添加到 weights 的最后一行
        layer4_weights[256] = layer4_biases;
    endtask


    initial begin       
        if(TEST_N < 100)begin
            $fsdbDumpfile("tb2.fsdb");
            $fsdbDumpvars(0);
            $fsdbDumpMDA();
        end 
        clk = 0;
        rst = 1;
        forever begin
            #1 clk = ~clk;
        end
    end

    // 第一阶段，将每张测试图片和所有参考图片之间的距离求出，分别保存在MLU中（即：每个MLU保存的是十六份中一份的值），然后以部分和的形式保存到Output Buffer中
    // 第二阶段，从Output Buffer中读出图片距离的16个部分和，然后进入MLU的排序模块，进行排序
    initial begin
        // 读取数据集和DNN模型参数到内存
        read_dataset_and_parameters(test_images, test_labels, layer1_weights, layer1_biases, layer2_weights, layer2_biases, layer3_weights, layer3_biases, layer4_weights, layer4_biases);
        $display("layer1_weight:%h, layer2_weight:%h, layer3_weight:%h, layer4_weight:%h" , layer1_weights[783][1023], layer2_weights[1023][511], layer3_weights[511][255], layer4_weights[255][9]);

        for(integer kk1 = 0; kk1 < 10; kk1 = kk1 + 1)begin
            debug_test_image[kk1][783:0] = test_images[kk1][783:0];
        end
        ref_index = 0;
        test_index = 0;
        outbuf_idx = 0;  //OutputBuf的idx累加，因为所有的参数都可以保存进来
        //将所有的测试用例，每16张一批，分别和所有的参考图片进行计算距离，并排序
         for(test_index = 0; test_index < TESE_N; test_index = test_index + 1)begin
            $display("正在计算第%0d~%0d张测试图片的分类结果", test_index, test_index+1);
            
            //加载L1层的输入和权重数据
            load_layer1_inputs();

            //-----------------计算L1层结果start------------------------------------------------
            //读取Larer1_input数据到Hotbuffer
            hot_read_en = 0;
            hot_write_en = 1;
            for(integer i = 0 ; i < 49; i = i + 1)begin  //128个MLU
                hot_idx = i;
                for(integer j = 0; j < 16; j = j + 1)begin  //1个MLU有16个数
                    hot_buff_in[j] = layer1_input[(i%49)*16+j];
                    #2;
                end
            end
            //将1024个数据分成64段去求，每一段的最终数据求出来了，再求下一段
            for(integer hor_portion_id = 0, col_start = 0; hor_portion_id < 64; hor_portion_id = hor_portion_id + 1)begin

                col_start = 16 * hor_portion_id;
                clear_reg_acc = 1;  //初始化寄存器的状态，避免出现32'hxxxx_xxxx + 任何数 依旧是32'hxxxx_xxxx的情况
                #2; 
                clear_reg_acc = 0;

                //垂直取weights 784*1024的数据，取满ColdBuf共4轮，计算出最终的16/1024个数
                for(integer ver_portion_id = 0, row_start = 0; ver_portion_id < 4; ver_portion_id++)begin   //需要遍历4轮，才能拿到计算完一张图片49+1个MLU的数据
                    
                    row_start = 256 * ver_portion_id;

                    //从内存读取64轮中的一轮参数到ColdBuffer;
                    cold_read_en = 0;
                    cold_write_en = 1;
                    //------------------向ColdBuffer写入部分权重参数---------------------
                    for(integer i = 0; i < 16; i = i + 1)begin  //16组MLU
                        cold_idx = i;
                        for(integer j = 0; j < 16; j = j + 1)begin  //每组16个MLU, j表示第几个MLU
                            for(integer k = 0, row_num = 0 ; k < 16; k = k + 1)begin  //每个MLU16维数据
                                row_num = row_start+j*16+k;  //row_num表示二维数组的行数，最大为784
                                if(row_num <= 784)begin
                                    cold_buff_in[j*16+k] = layer1_weights[row_start+i*16+k][col_start+j];
                                end else begin
                                    cold_buff_in[j*16+k] = 0;
                                end
                            end
                            #2;
                        end
                    end

                    //开始从ColdBuffer和HotBuffer读数据到一组MLU中
                    hot_read_en = 1;
                    hot_write_en = 0;
                    cold_read_en = 1;
                    cold_write_en = 0;
                    for(integer cold_mlus_id = 0; cold_mlus_id < 16; cold_mlus_id = cold_mlus_id + 1)begin
                        //从ColdBuffer和HotBuffer读取一组共计16MLU的数据进行计算
                        cold_idx = cold_mlus_id;
                        hot_idx = ver_portion_id * 16 + cold_mlus_id;
                        symbol = 2'b01;
                        #2;    //给时间记录数据
                        sel_in = 1;  //选择从HotBuf和ColdBuf直接传递过来的数据
                        shift_right = 8'b00010000;  //右移16位
                        fun_id = 3'b001;  // 使用ReLu作为非线性函数
                        asce = 1'b1;

                        if(hot_idx >= 49)begin   //多一个是image的全1行乘以biases值
                            // alu_run_case = 4'b0100;  //清除ALU之前的输出数据，避免造成干扰
                            // #4;
                            //输出到OutputBuf
                            sel_output = 3'b101;   //sel_6选择nonlinear作为MLU输出
                            is_output = 1;        //Acc输出到sel_6模块
                            #4;
                            is_output = 0;    //清空为0了，避免0输出
                            alu_select = 2'b01;  //选择来自MLU的输入
                            alu_in_count = 0;
                            alu_out_count = 0;
                            alu_run_case = 4'b0011;  //保存MLU的out_scale然后输出
                            output_read_en = 0;
                            output_write_en = 1;
                            outbuf_idx = hor_portion_id/16;
                            #4;
                            alu_select = 0;
                            alu_out_count = 32'hxxxx_xxxx;
                            break;
                        end else begin
                            //部分和保存到Acc为止
                            is_output = 0;
                            sel_output = 3'b0;  //MLU不输出
                        end
                        
                    end

                end
            end
            //-----------------计算L1层结果finish------------------------------------------------


            //-----------------计算L2层结果start------------------------------------------------
            //加载L2层的输入和权重数据
            load_layer2_inputs();
            //读取Larer2_input数据到Hotbuffer
            hot_read_en = 0;
            hot_write_en = 1;
            for(integer i = 0 ; i < 64; i = i + 1)begin
                hot_idx = i;
                for(integer j = 0; j < 16; j = j + 1)begin  //1个MLU有16个数
                    hot_buff_in[j] = layer2_input[i*16+j];
                    #2;
                end
            end
            //-----------------读取L2层的计算参数，1024*512，计算后得到512个数据---------------------
            //将512个数据分成32段去求，每一段的最终数据求出来了，再求下一段
            for(integer hor_portion_id = 0, col_start = 0; hor_portion_id < 32; hor_portion_id = hor_portion_id + 1)begin

                col_start = 16 * hor_portion_id;
                clear_reg_acc = 1;  //初始化寄存器的状态，避免出现32'hxxxx_xxxx + 任何数 依旧是32'hxxxx_xxxx的情况
                #2; 
                clear_reg_acc = 0;

                //垂直取weights 1025*512的数据，取满ColdBuf共5轮，计算出最终的16/512个数
                for(integer ver_portion_id = 0, row_start = 0; ver_portion_id < 5; ver_portion_id++)begin   //需要遍历5轮，才能拿到计算完1024+biases的数据
                    
                    row_start = 256 * ver_portion_id; //当row_start=1024的时候就是计算偏置值的时候了

                    //从内存读取32轮中的一轮参数到ColdBuffer;
                    cold_read_en = 0;
                    cold_write_en = 1;
                    //------------------向ColdBuffer写入部分权重参数---------------------
                    for(integer i = 0; i < 16; i = i + 1)begin  //16组MLU
                        cold_idx = i;
                        for(integer j = 0; j < 16; j = j + 1)begin  //每组16个MLU, j表示第几个MLU
                            for(integer k = 0, row_num = 0 ; k < 16; k = k + 1)begin  //每个MLU16维数据
                                row_num = row_start+j*16+k;  //row_num表示二维数组的行数，最大为1024
                                if(row_num <= 1024)begin
                                    cold_buff_in[j*16+k] = layer2_weights[row_start+i*16+k][col_start+j];
                                end else begin
                                    cold_buff_in[j*16+k] = 0;
                                end
                            end
                            #2;
                        end
                    end

                    //开始从ColdBuffer和HotBuffer读数据到一组MLU中
                    hot_read_en = 1;
                    hot_write_en = 0;
                    cold_read_en = 1;
                    cold_write_en = 0;
                    for(integer cold_mlus_id = 0; cold_mlus_id < 16; cold_mlus_id = cold_mlus_id + 1)begin
                        //从ColdBuffer和HotBuffer读取一组共计16MLU的数据进行计算
                        cold_idx = cold_mlus_id;
                        hot_idx = ver_portion_id * 16 + cold_mlus_id;
                        symbol = 2'b01;
                        #2;    //给时间记录数据
                        sel_in = 1;  //选择从HotBuf和ColdBuf直接传递过来的数据
                        shift_right = 8'b00010000;  //右移16位
                        fun_id = 3'b001;  // 使用ReLu作为非线性函数
                        asce = 1'b1;

                        if(hot_idx >= 64)begin   //多一个是输入的全1行乘以biases值
                            // alu_run_case = 4'b0100;  //清除ALU之前的输出数据，避免造成干扰
                            // #4;
                            //输出到OutputBuf
                            sel_output = 3'b101;   //sel_6选择nonlinear作为MLU输出
                            is_output = 1;        //Acc输出到sel_6模块
                            #4;
                            is_output = 0;    //清空为0了，避免0输出
                            alu_select = 2'b01;  //选择来自MLU的输入
                            alu_in_count = 0;
                            alu_out_count = 0;
                            alu_run_case = 4'b0011;  //保存MLU的out_scale然后输出
                            output_read_en = 0;
                            output_write_en = 1;
                            outbuf_idx = 4+ hor_portion_id/16;
                            #4;
                            alu_select = 0;
                            alu_out_count = 32'hxxxx_xxxx;
                            break;
                        end else begin
                            //部分和保存到Acc为止
                            is_output = 0;
                            sel_output = 3'b0;  //MLU不输出
                        end
                        
                    end

                end
            end
            //-----------------计算L2层结果finish------------------------------------------------


            //-----------------计算L3层结果start------------------------------------------------
            //加载L3层的输入和权重数据
            load_layer3_inputs();
            //读取layer3_input数据到Hotbuffer
            hot_read_en = 0;
            hot_write_en = 1;
            for(integer i = 0 ; i < 32; i = i + 1)begin
                hot_idx = i;
                for(integer j = 0; j < 16; j = j + 1)begin  //1个MLU有16个数
                    hot_buff_in[j] = layer3_input[i*16+j];
                    #2;
                end
            end
            //-----------------读取L3层的计算参数，512*256，计算后得到256个数据---------------------
            //将256个数据分成16段去求，每一段的最终数据求出来了，再求下一段
            for(integer hor_portion_id = 0, col_start = 0; hor_portion_id < 16; hor_portion_id = hor_portion_id + 1)begin

                col_start = 16 * hor_portion_id;
                clear_reg_acc = 1;  //初始化寄存器的状态，避免出现32'hxxxx_xxxx + 任何数 依旧是32'hxxxx_xxxx的情况
                #2; 
                clear_reg_acc = 0;

                //垂直取weights 513*256的数据，取满ColdBuf共3轮，计算出最终的16/256个数
                for(integer ver_portion_id = 0, row_start = 0; ver_portion_id < 3; ver_portion_id++)begin   //需要遍历3轮，才能拿到计算完512+biases的数据
                    
                    row_start = 256 * ver_portion_id; //当row_start=512的时候就是计算偏置值的时候了

                    //从内存读取32轮中的一轮参数到ColdBuffer;
                    cold_read_en = 0;
                    cold_write_en = 1;
                    //------------------向ColdBuffer写入部分权重参数---------------------
                    for(integer i = 0; i < 16; i = i + 1)begin  //16组MLU
                        cold_idx = i;
                        for(integer j = 0; j < 16; j = j + 1)begin  //每组16个MLU, j表示第几个MLU
                            for(integer k = 0, row_num = 0 ; k < 16; k = k + 1)begin  //每个MLU16维数据
                                row_num = row_start+j*16+k;  //row_num表示二维数组的行数，最大为512
                                if(row_num <= 512)begin
                                    cold_buff_in[j*16+k] = layer3_weights[row_start+i*16+k][col_start+j];
                                end else begin
                                    cold_buff_in[j*16+k] = 0;
                                end
                            end
                            #2;
                        end
                    end

                    //开始从ColdBuffer和HotBuffer读数据到一组MLU中
                    hot_read_en = 1;
                    hot_write_en = 0;
                    cold_read_en = 1;
                    cold_write_en = 0;
                    for(integer cold_mlus_id = 0; cold_mlus_id < 16; cold_mlus_id = cold_mlus_id + 1)begin
                        //从ColdBuffer和HotBuffer读取一组共计16MLU的数据进行计算
                        cold_idx = cold_mlus_id;
                        hot_idx = ver_portion_id * 16 + cold_mlus_id;
                        symbol = 2'b01;
                        #2;    //给时间记录数据
                        sel_in = 1;  //选择从HotBuf和ColdBuf直接传递过来的数据
                        shift_right = 8'b00010000;  //右移16位
                        fun_id = 3'b001;  // 使用ReLu作为非线性函数
                        asce = 1'b1;

                        if(hot_idx >= 32)begin   //多一个是输入的全1行乘以biases值
                            // alu_run_case = 4'b0100;  //清除ALU之前的输出数据，避免造成干扰
                            // #4;
                            //输出到OutputBuf
                            sel_output = 3'b101;   //sel_6选择nonlinear作为MLU输出
                            is_output = 1;        //Acc输出到sel_6模块
                            #4;
                            is_output = 0;    //清空为0了，避免0输出
                            alu_select = 2'b01;  //选择来自MLU的输入
                            alu_in_count = 0;
                            alu_out_count = 0;
                            alu_run_case = 4'b0011;  //保存MLU的out_scale然后输出
                            output_read_en = 0;
                            output_write_en = 1;
                            outbuf_idx = 6+ hor_portion_id/16;
                            #4;
                            alu_select = 0;
                            alu_out_count = 32'hxxxx_xxxx;
                            break;
                        end else begin
                            //部分和保存到Acc为止
                            is_output = 0;
                            sel_output = 3'b0;  //MLU不输出
                        end
                        
                    end

                end
            end
            
            //-----------------计算L3层结果finish------------------------------------------------
            

            //-----------------计算L4层结果start------------------------------------------------
            //加载L4层的输入和权重数据
            load_layer4_inputs();
            //读取layer4_input数据到Hotbuffer
            hot_read_en = 0;
            hot_write_en = 1;
            for(integer i = 0 ; i < 16; i = i + 1)begin
                hot_idx = i;
                for(integer j = 0; j < 16; j = j + 1)begin  //1个MLU有16个数
                    hot_buff_in[j] = layer4_input[i*16+j];
                    #2;
                end
            end
            //-----------------读取L4层的计算参数，256*10，计算后得到10个数据---------------------
            //10个数据不用按照每段16个划分，直接一次就求出来了
            alu_run_case = 4'b0100;  //清除ALU之前的输出数据，避免造成干扰
            #4
            for(integer hor_portion_id = 0, col_start = 0; hor_portion_id < 1; hor_portion_id = hor_portion_id + 1)begin

                col_start = 16 * hor_portion_id;
                clear_reg_acc = 1;  //初始化寄存器的状态，避免出现32'hxxxx_xxxx + 任何数 依旧是32'hxxxx_xxxx的情况
                #2; 
                clear_reg_acc = 0;

                //垂直取weights 257*10的数据，取满ColdBuf共2轮，计算出最终的10个数
                for(integer ver_portion_id = 0, row_start = 0; ver_portion_id < 2; ver_portion_id++)begin   //需要遍历3轮，才能拿到计算完512+biases的数据
                    
                    row_start = 256 * ver_portion_id; //当row_start=512的时候就是计算偏置值的时候了

                    //从内存读取32轮中的一轮参数到ColdBuffer;
                    cold_read_en = 0;
                    cold_write_en = 1;
                    //------------------向ColdBuffer写入部分权重参数---------------------
                    for(integer i = 0; i < 16; i = i + 1)begin  //16组MLU
                        cold_idx = i;
                        for(integer j = 0; j < 16; j = j + 1)begin  //每组16个MLU, j表示第几个MLU
                            for(integer k = 0, row_num = 0 ; k < 16; k = k + 1)begin  //每个MLU16维数据
                                row_num = row_start+j*16+k;  //row_num表示二维数组的行数，最大为512
                                if(row_num <= 256)begin
                                    cold_buff_in[j*16+k] = layer4_weights[row_start+i*16+k][col_start+j];
                                end else begin
                                    cold_buff_in[j*16+k] = 0;
                                end
                            end
                            #2;
                        end
                    end

                    //开始从ColdBuffer和HotBuffer读数据到一组MLU中
                    hot_read_en = 1;
                    hot_write_en = 0;
                    cold_read_en = 1;
                    cold_write_en = 0;
                    for(integer cold_mlus_id = 0; cold_mlus_id < 16; cold_mlus_id = cold_mlus_id + 1)begin
                        //从ColdBuffer和HotBuffer读取一组共计16MLU的数据进行计算
                        cold_idx = cold_mlus_id;
                        hot_idx = ver_portion_id * 16 + cold_mlus_id;
                        symbol = 2'b01;
                        #2;    //给时间记录数据
                        sel_in = 1;  //选择从HotBuf和ColdBuf直接传递过来的数据
                        shift_right = 8'b00010000;  //右移16位
                        fun_id = 3'b001;  // 使用ReLu作为非线性函数
                        asce = 1'b1;

                        if(hot_idx >= 16)begin   //多一个是输入的全1行乘以biases值
                            //输出到OutputBuf
                            sel_output = 3'b101;   //sel_6选择nonlinear作为MLU输出
                            is_output = 1;        //Acc输出到sel_6模块
                            #4;
                            is_output = 0;    //清空为0了，避免0输出
                            alu_select = 2'b01;  //选择来自MLU的输入
                            alu_in_count = 0;
                            alu_out_count = 1;  //直接输出部分结果
                            alu_run_case = 4'b0011;  //保存MLU的out_scale然后输出
                            output_read_en = 0;
                            output_write_en = 1;
                            outbuf_idx = 7+ hor_portion_id/16;
                            #4;
                            alu_select = 0;
                            alu_out_count = 32'hxxxx_xxxx;
                            break;
                        end else begin
                            //部分和保存到Acc为止
                            is_output = 0;
                            sel_output = 3'b0;  //MLU不输出
                        end
                        
                    end

                end
            end
            
            //-----------------计算L4层结果finish------------------------------------------------
         #4;
         end

        
        
        #100
        $finish;
    end
endmodule
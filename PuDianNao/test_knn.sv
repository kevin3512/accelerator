`timescale 1ns/1ns
module test_knn;
    parameter                     REF_IMAGE_NUM = 60000;
    parameter                     TEST_IMAGE_NUM = 10000;
    parameter                     IMAGE_SIZE = 784;   //28*28
    parameter                     Misc_WIDTH = 32;
    parameter                     K = 20;
    reg[7:0]                      ref_images[REF_IMAGE_NUM-1:0][IMAGE_SIZE-1:0];
    reg[7:0]                      ref_labels[REF_IMAGE_NUM-1:0]; 
    reg[7:0]                      test_images[TEST_IMAGE_NUM-1:0][IMAGE_SIZE-1:0];
    reg[7:0]                      test_labels[TEST_IMAGE_NUM-1:0]; 
    integer                       test_index;  //测试用例（测试集）下标
    integer                       ref_index;  //参考用例（训练集）下标
    integer                       group_idx;  //进行几轮计算
    reg[31:0]                     hot_buff_in[15:0];   //hotbuff的输入
    reg[31:0]                     cold_buff_in[255:0];  //coldbuffer的输入
    wire[31:0]                    wire_hotmlu_in[15:0];   //MLU的输入 , 总共16组MLU，每个MLU需要16个数据，每个数据16bit
    wire[31:0]                    wire_coldmlu_in[255:0];  //MLU的输入
    reg[7:0]                      hot_idx;    //hotbuff读写的下标
    reg[4:0]                      cold_idx;
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
    // Acc部分需要的输入
    reg                           is_output;
    reg                           clear_reg_acc;      //清除acc寄存器信号
    // Misc部分需要的输入
    reg[Misc_WIDTH-1:0]           index;
    reg[2:0]                      fun_id;       //非线性函数id
    reg                           asce;   //升序排序信号，1表示升序（从小到大排列），0表示降序
    reg                           clear_reg_sort;     //清除排序模块寄存器数据
    reg[31:0]                     count;           //vector输出计数，用与输出的长度超过16的情况
    reg[31:0]                     out_scalar[15:0];  //总共有16组结果，每组1个数据
    reg[31:0]                     out_vector[15:0][15:0];  //总共有16组结果，每组16位数据
    // ALU部分需要的输入
    reg[1:0]                      alu_select;       //alu选择哪一个输入
    reg                           is_start;
    reg[31:0]                     out_vector_collect[47:0][15:0];
    reg[31:0]                     out_sort[15:0][K-1:0];
    reg[31:0]                     out_sort_index[15:0][K-1:0];
    wire[31:0]                    wire_alu_out[255:0];         

    // OutputBuffer的输出
    wire[31:0]                    wire_outputbuf_out[255:0]; 
    reg[3:0]                      outbuf_idx;  
            

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
        .is_output(is_output), 
        .clear_reg_acc(clear_reg_acc), 
        .index(index), 
        .fun_id(fun_id), 
        .asce(asce),
        .clear_reg_sort(clear_reg_sort), 
        .count(count),
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
        .is_output(is_output), 
        .clear_reg_acc(clear_reg_acc), 
        .index(index), 
        .fun_id(fun_id), 
        .asce(asce),
        .clear_reg_sort(clear_reg_sort), 
        .count(count),
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
        .is_output(is_output), 
        .clear_reg_acc(clear_reg_acc), 
        .index(index), 
        .fun_id(fun_id), 
        .asce(asce),
        .clear_reg_sort(clear_reg_sort), 
        .count(count),
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
        .is_output(is_output), 
        .clear_reg_acc(clear_reg_acc), 
        .index(index), 
        .fun_id(fun_id), 
        .asce(asce),
        .clear_reg_sort(clear_reg_sort), 
        .count(count),
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
        .is_output(is_output), 
        .clear_reg_acc(clear_reg_acc), 
        .index(index), 
        .fun_id(fun_id), 
        .asce(asce),
        .clear_reg_sort(clear_reg_sort), 
        .count(count),
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
        .is_output(is_output), 
        .clear_reg_acc(clear_reg_acc), 
        .index(index), 
        .fun_id(fun_id), 
        .asce(asce),
        .clear_reg_sort(clear_reg_sort), 
        .count(count),
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
        .is_output(is_output), 
        .clear_reg_acc(clear_reg_acc), 
        .index(index), 
        .fun_id(fun_id), 
        .asce(asce),
        .clear_reg_sort(clear_reg_sort), 
        .count(count),
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
        .is_output(is_output), 
        .clear_reg_acc(clear_reg_acc), 
        .index(index), 
        .fun_id(fun_id), 
        .asce(asce),
        .clear_reg_sort(clear_reg_sort), 
        .count(count),
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
        .is_output(is_output), 
        .clear_reg_acc(clear_reg_acc), 
        .index(index), 
        .fun_id(fun_id), 
        .asce(asce),
        .clear_reg_sort(clear_reg_sort), 
        .count(count),
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
        .is_output(is_output), 
        .clear_reg_acc(clear_reg_acc), 
        .index(index), 
        .fun_id(fun_id), 
        .asce(asce),
        .clear_reg_sort(clear_reg_sort), 
        .count(count),
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
        .is_output(is_output), 
        .clear_reg_acc(clear_reg_acc), 
        .index(index), 
        .fun_id(fun_id), 
        .asce(asce),
        .clear_reg_sort(clear_reg_sort), 
        .count(count),
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
        .is_output(is_output), 
        .clear_reg_acc(clear_reg_acc), 
        .index(index), 
        .fun_id(fun_id), 
        .asce(asce),
        .clear_reg_sort(clear_reg_sort), 
        .count(count),
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
        .is_output(is_output), 
        .clear_reg_acc(clear_reg_acc), 
        .index(index), 
        .fun_id(fun_id), 
        .asce(asce),
        .clear_reg_sort(clear_reg_sort), 
        .count(count),
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
        .is_output(is_output), 
        .clear_reg_acc(clear_reg_acc), 
        .index(index), 
        .fun_id(fun_id), 
        .asce(asce),
        .clear_reg_sort(clear_reg_sort), 
        .count(count),
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
        .is_output(is_output), 
        .clear_reg_acc(clear_reg_acc), 
        .index(index), 
        .fun_id(fun_id), 
        .asce(asce),
        .clear_reg_sort(clear_reg_sort), 
        .count(count),
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
        .is_output(is_output), 
        .clear_reg_acc(clear_reg_acc), 
        .index(index), 
        .fun_id(fun_id), 
        .asce(asce),
        .clear_reg_sort(clear_reg_sort), 
        .count(count),
        .out_scalar(out_scalar[15]),
        .out_vector(out_vector[15]));

    
    ALU alu_ins0(.clk(clk), .rst(rst), .select(alu_select), .in_mlu(out_vector[0]), .in_output(wire_outputbuf_out[15:0]), .count(count), .is_start(is_start), .is_asce_sort(1'b1), .out(wire_alu_out[15:0]));
    
    ALU alu_ins1(.clk(clk), .rst(rst), .select(alu_select), .in_mlu(out_vector[1]), .in_output(wire_outputbuf_out[31:16]), .count(count), .is_start(is_start), .is_asce_sort(1'b1), .out(wire_alu_out[31:16]));
    
    ALU alu_ins2(.clk(clk), .rst(rst), .select(alu_select), .in_mlu(out_vector[2]), .in_output(wire_outputbuf_out[47:32]), .count(count), .is_start(is_start), .is_asce_sort(1'b1), .out(wire_alu_out[47:32]));

    ALU alu_ins3(.clk(clk), .rst(rst), .select(alu_select), .in_mlu(out_vector[3]), .in_output(wire_outputbuf_out[63:48]), .count(count), .is_start(is_start), .is_asce_sort(1'b1), .out(wire_alu_out[63:48]));

    ALU alu_ins4(.clk(clk), .rst(rst), .select(alu_select), .in_mlu(out_vector[4]), .in_output(wire_outputbuf_out[79:64]), .count(count), .is_start(is_start), .is_asce_sort(1'b1), .out(wire_alu_out[79:64]));

    ALU alu_ins5(.clk(clk), .rst(rst), .select(alu_select), .in_mlu(out_vector[5]), .in_output(wire_outputbuf_out[95:80]), .count(count), .is_start(is_start), .is_asce_sort(1'b1), .out(wire_alu_out[95:80]));

    ALU alu_ins6(.clk(clk), .rst(rst), .select(alu_select), .in_mlu(out_vector[6]), .in_output(wire_outputbuf_out[111:96]), .count(count), .is_start(is_start), .is_asce_sort(1'b1), .out(wire_alu_out[111:96]));

    ALU alu_ins7(.clk(clk), .rst(rst), .select(alu_select), .in_mlu(out_vector[7]), .in_output(wire_outputbuf_out[127:112]), .count(count), .is_start(is_start), .is_asce_sort(1'b1), .out(wire_alu_out[127:112]));

    ALU alu_ins8(.clk(clk), .rst(rst), .select(alu_select), .in_mlu(out_vector[8]), .in_output(wire_outputbuf_out[143:128]), .count(count), .is_start(is_start), .is_asce_sort(1'b1), .out(wire_alu_out[143:128]));

    ALU alu_ins9(.clk(clk), .rst(rst), .select(alu_select), .in_mlu(out_vector[9]), .in_output(wire_outputbuf_out[159:144]), .count(count), .is_start(is_start), .is_asce_sort(1'b1), .out(wire_alu_out[159:144]));

    ALU alu_ins10(.clk(clk), .rst(rst), .select(alu_select), .in_mlu(out_vector[10]), .in_output(wire_outputbuf_out[175:160]), .count(count), .is_start(is_start), .is_asce_sort(1'b1), .out(wire_alu_out[175:160]));

    ALU alu_ins11(.clk(clk), .rst(rst), .select(alu_select), .in_mlu(out_vector[11]), .in_output(wire_outputbuf_out[191:176]), .count(count), .is_start(is_start), .is_asce_sort(1'b1), .out(wire_alu_out[191:176]));

    ALU alu_ins12(.clk(clk), .rst(rst), .select(alu_select), .in_mlu(out_vector[12]), .in_output(wire_outputbuf_out[207:192]), .count(count), .is_start(is_start), .is_asce_sort(1'b1), .out(wire_alu_out[207:192]));

    ALU alu_ins13(.clk(clk), .rst(rst), .select(alu_select), .in_mlu(out_vector[13]), .in_output(wire_outputbuf_out[223:208]), .count(count), .is_start(is_start), .is_asce_sort(1'b1), .out(wire_alu_out[223:208]));

    ALU alu_ins14(.clk(clk), .rst(rst), .select(alu_select), .in_mlu(out_vector[14]), .in_output(wire_outputbuf_out[239:224]), .count(count), .is_start(is_start), .is_asce_sort(1'b1), .out(wire_alu_out[239:224]));

    ALU alu_ins15(.clk(clk), .rst(rst), .select(alu_select), .in_mlu(out_vector[15]), .in_output(wire_outputbuf_out[255:240]), .count(count), .is_start(is_start), .is_asce_sort(1'b1), .out(wire_alu_out[255:240]));

    OutputBuffer outputbuf_ins(.clk(clk), .rst(rst), .in(wire_alu_out), .idx(outbuf_idx), .read_en(output_read_en), .write_en(output_write_en), .out(wire_outputbuf_out));
 
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


    initial begin              
        $fsdbDumpfile("tb2.fsdb");
        $fsdbDumpvars(0);
        $fsdbDumpMDA();
        clk = 0;
        rst = 1;
        forever begin
            #1 clk = ~clk;
        end
    end

    // 第一阶段，将每张测试图片和所有参考图片之间的距离求出，分别保存在MLU中（即：每个MLU保存的是十六份中一份的值），然后以部分和的形式保存到Output Buffer中
    // 第二阶段，从Output Buffer中读出图片距离的16个部分和，然后进入MLU的排序模块，进行排序
    initial begin
        // 从数据集中读取文件到内存
        read_mnist_dataset_task(ref_images, ref_labels, test_images, test_labels);
        $display("读取到训练集图片最后一个字节(第%d个)为%h" ,REF_IMAGE_NUM, ref_images[REF_IMAGE_NUM-1][IMAGE_SIZE-1]);
        $display("读取到测试集图片最后一个字节(第%d个)为%h" ,TEST_IMAGE_NUM, test_images[TEST_IMAGE_NUM-1][IMAGE_SIZE-1]);
        ref_index = 0;
        test_index = 0;
        for (ref_index = 0; ref_index < 60; ref_index = ref_index + 2)begin  //参考图片60张，一次取2张，占用128个MLU的数据所需
            // $display("正在计算第%0d~%0d个图片的分类结果", test_index, test_index+15);
            //---------------------------向HotBuffer和ColdBuffer写数据------------------------------------------------------
            //--------------向HotBuffer写入2张参考图片的数据------------------
            hot_read_en = 0;
            hot_write_en = 1;
            for(integer i = 0 ; i < 128; i = i + 1)begin  //128个MLU
                hot_idx = i;
                for(integer j = 0; j < 16; j = j + 1)begin  //1个MLU有16个数
                    if(i < 98)begin  
                        hot_buff_in[j] = test_images[ref_index+i/49][(i%49)*16+j];
                    end else begin   //由于128个MLU的位置只保存2张图片，即只需49*2=98个MLU的位置，因此后面的位置赋0，保证计算是不会出现数据为xxxx_xxxx的情况
                        hot_buff_in[j] = 0;
                    end
                    #2;
                end
            end
            // -------------开始计算每一张参考图片和所有的测试图片之间的距离--------------------
            for(test_index = 0; test_index < 64; test_index = test_index + 16)begin  //一个循环读取16张图片的1/5，需要读取5次ColdBuff才能计算完16张图片
                clear_reg_acc = 1;  //初始化寄存器的状态，避免出现32'hxxxx_xxxx + 任何数 依旧是32'hxxxx_xxxx的情况
                #2; 
                for(integer portion_id = 0, mlu_num = 0; portion_id < 4; portion_id = portion_id + 1)begin  //遍历4张测试图片和1张参考图片之间的计算
                    cold_read_en = 0;
                    cold_write_en = 1;
                    //------------------向ColdBuffer写入16张图片的1/4数据---------------------
                    for(integer i = 0; i < 16; i = i + 1)begin  //16组MLU
                        cold_idx = i;
                        for(integer j = 0; j < 16; j = j + 1)begin  //每组16个MLU, j表示第几个MLU
                            for(integer k = 0 ; k < 16; k = k + 1)begin  //每个MLU16维数据
                                mlu_num = portion_id * 16 + i;  //mlu_num表示已经计算了几个mlu的部分和了
                                if(mlu_num < 49)begin
                                    cold_buff_in[j*16+k] = test_images[test_index + j][mlu_num*16+k];
                                end else begin
                                    cold_buff_in[j*16+k] = 0;
                                end
                            end
                            #2;
                        end
                    end
                    
                    //---------------开始进行HotBuff所有数据和ColdBuff所有数据之间的运算------------------
                    for(integer cold_mlus_id = 0; cold_mlus_id < 16; cold_mlus_id = cold_mlus_id + 1)begin  //ColdBuf取一组MLU和HotBuf取一个MLU进行运算，总共16组
                        for(integer hot_mlu_id = 0; hot_mlu_id < 98; hot_mlu_id = hot_mlu_id + 1)begin   //HotBuf取一个MLU, 总共2张图片，98个（因为容量只有128个MLU，因此只能存2张图片完整数据）
                            hot_read_en = 1;
                            hot_write_en = 0;
                            cold_read_en = 1;
                            cold_write_en = 0;
                            hot_idx = hot_mlu_id;
                            cold_idx = cold_mlus_id;
                            symbol = 2'b10;
                            #2;    //给时间记录数据
                            sel_in = 0;  //选择从Adder层传递过来的数据
                            index = ref_index + hot_mlu_id/49;  //第几张图片
                            fun_id = 3'b0;  // 暂时用不上非线性函数
                            asce = 1'b1;
                            // 如果不是第一次图片和图片之间的运算，那么需要从OutputBuf读数据到ALU
                            if(ref_index > 0 || test_index > 0)begin
                                //TODO 从OutputBuf读数据到ALU
                            end
                            if(hot_mlu_id == 48 || hot_mlu_id == 97)begin  //每张图片的最后一次MLU运算，结果需要进行排序
                                sel_output = 3'b110; //将Ksort模块的结果输出到ALU
                                is_output = 1;
                                #4;
                                is_output = 0;    //清空为0了，避免0输出
                                //把输出的out_vector收集一下
                                for(count = 0; count <= 2*K / 16; count = count + 1)begin  //2*20=40，每次传16位，只需要传3次，前20位是排序的数据，后20位是对应的下标
                                    for(integer w = 0; w < 16; w = w + 1)begin
                                        out_vector_collect[count*16+w] = out_vector[w]; 
                                    end
                                    #4;
                                end
                                //解析out_vector_collect格式，赋值到out_sort和out_sort_index ， out_vector_collect格式是20个数据+20个index进行拼接
                                for(integer v = 0; v < 16; v = v + 1)begin
                                    out_sort[v] = {out_vector_collect[v*3][15:0], out_vector_collect[v*3+1][15:12]};
                                    out_sort_index[v] = {out_vector_collect[v*3+1][11:0], out_vector_collect[v*3+2][15:8]};
                                end
                            end else begin
                                sel_output = 3'b0;  //数据累加到acc就结束了，不输出到ALU
                                is_output = 0;
                            end 
                            #4;
                        end
                    end
                    
                end
            end
        end
        #4;
        
        #100
        $finish;
    end
endmodule
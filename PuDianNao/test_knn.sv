`timescale 1ns/1ns
module test_knn;
    parameter                     REF_IMAGE_NUM = 60000;
    parameter                     TEST_IMAGE_NUM = 10000;
    parameter                     IMAGE_SIZE = 784;   //28*28
    parameter                     Misc_WIDTH = 32;
    reg[7:0]                      ref_images[REF_IMAGE_NUM-1:0][IMAGE_SIZE-1:0];
    reg[7:0]                      ref_labels[REF_IMAGE_NUM-1:0]; 
    reg[7:0]                      test_images[TEST_IMAGE_NUM-1:0][IMAGE_SIZE-1:0];
    reg[7:0]                      test_labels[TEST_IMAGE_NUM-1:0]; 
    integer                       test_index;  //测试用例（测试集）下标
    integer                       ref_index;  //参考用例（训练集）下标
    integer                       group_idx;  //进行几轮计算
    reg[15:0]                     hot_buff_in[255:0];   //hotbuff的输入
    reg[15:0]                     cold_buff_in[255:0];  //coldbuffer的输入
    wire[15:0]                    wire_hotmlu_in[255:0];   //MLU的输入 , 总共16组MLU，每个MLU需要16个数据，每个数据16bit
    wire[15:0]                    wire_coldmlu_in[255:0];  //MLU的输入
    reg[5:0]                      hot_idx;    //hotbuff读写的下标
    reg[6:0]                      cold_idx;
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
    reg[31:0]                     out_scalar[15:0];  //总共有16组结果，每组1个数据
    reg[31:0]                     out_vector[15:0][15:0];  //总共有16组结果，每组16位数据

    HotBuffer hotbuf_ins(.clk(clk), .rst(rst), .in(hot_buff_in), .idx(hot_idx), .read_en(hot_read_en), .write_en(hot_write_en), .out(wire_hotmlu_in));
    ColdBuffer coldbuf_ins(.clk(clk), .rst(rst), .in(cold_buff_in), .idx(cold_idx), .read_en(cold_read_en), .write_en(cold_write_en), .out(wire_coldmlu_in));
    // OutputBuffer outputbuf_ins(.clk(clk), .rst(rst), .in(cold_buff_in), .idx(cold_idx), .read_en(output_read_en), .write_en(output_write_en), .out(wire_coldmlu_in));
    

    MLU MLU_ins0(
        .hot_in(wire_hotmlu_in[15:0]), 
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
        .out_scalar(out_scalar[0]),
        .out_vector(out_vector[0]));

    MLU MLU_ins1(
        .hot_in(wire_hotmlu_in[31:16]), 
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
        .out_scalar(out_scalar[1]),
        .out_vector(out_vector[1]));

    MLU MLU_ins2(
        .hot_in(wire_hotmlu_in[47:32]), 
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
        .out_scalar(out_scalar[2]),
        .out_vector(out_vector[2]));

    MLU MLU_ins3(
        .hot_in(wire_hotmlu_in[63:48]), 
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
        .out_scalar(out_scalar[3]),
        .out_vector(out_vector[3]));

    MLU MLU_ins4(
        .hot_in(wire_hotmlu_in[79:64]), 
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
        .out_scalar(out_scalar[4]),
        .out_vector(out_vector[4]));

    MLU MLU_ins5(
        .hot_in(wire_hotmlu_in[95:80]), 
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
        .out_scalar(out_scalar[5]),
        .out_vector(out_vector[5]));

    MLU MLU_ins6(
        .hot_in(wire_hotmlu_in[111:96]), 
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
        .out_scalar(out_scalar[6]),
        .out_vector(out_vector[6]));

    MLU MLU_ins7(
        .hot_in(wire_hotmlu_in[127:112]), 
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
        .out_scalar(out_scalar[7]),
        .out_vector(out_vector[7]));

    MLU MLU_ins8(
        .hot_in(wire_hotmlu_in[143:128]), 
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
        .out_scalar(out_scalar[8]),
        .out_vector(out_vector[8]));

    MLU MLU_ins9(
        .hot_in(wire_hotmlu_in[159:144]), 
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
        .out_scalar(out_scalar[9]),
        .out_vector(out_vector[9]));

    MLU MLU_ins10(
        .hot_in(wire_hotmlu_in[175:160]), 
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
        .out_scalar(out_scalar[10]),
        .out_vector(out_vector[10]));

    MLU MLU_ins11(
        .hot_in(wire_hotmlu_in[191:176]), 
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
        .out_scalar(out_scalar[11]),
        .out_vector(out_vector[11]));

    MLU MLU_ins12(
        .hot_in(wire_hotmlu_in[207:192]), 
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
        .out_scalar(out_scalar[12]),
        .out_vector(out_vector[12]));

    MLU MLU_ins13(
        .hot_in(wire_hotmlu_in[223:208]), 
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
        .out_scalar(out_scalar[13]),
        .out_vector(out_vector[13]));

    MLU MLU_ins14(
        .hot_in(wire_hotmlu_in[239:224]), 
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
        .out_scalar(out_scalar[14]),
        .out_vector(out_vector[14]));

    MLU MLU_ins15(
        .hot_in(wire_hotmlu_in[255:240]), 
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
        .out_scalar(out_scalar[15]),
        .out_vector(out_vector[15]));


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
        for (test_index = 0; test_index < 128; test_index = test_index + 32)begin  //HotBuffer 8KB 一次可以保存16张图片，ColdBuffer 16KB 一次可以保存32张
            $display("正在计算第%0d~%0d个图片的分类结果", test_index, test_index+15);
            //---------------------------向HotBuffer和ColdBuffer写数据------------------------------------------------------
            //--------------向ColdBuffer写入32张测试图片的数据------------------
            cold_read_en = 0;
            cold_write_en = 1;
            for(integer i = 0 ; i < 128; i = i + 1)begin
                cold_idx = i;
                for(integer j = 0; j < 256; j = j + 16)begin
                    for(integer k = 0 ; k < 16; k = k + 1)begin
                        if(i%4 == 3 && j >= 16)begin
                            cold_buff_in[j+k] = 16'b0;   //第4行的第一块之后的数据全赋0,因为一张image只能存49块，一行是16块，因此只能存到第4行第1块
                        end else begin
                            cold_buff_in[j+k] = test_images[i/4][256*(i%4)+k];
                        end
                    end
                    #2;
                end
            end
            // -------------开始计算每一张测试图片和所有的参考图片之间的距离--------------------
            for(integer test_img_idx = 0; test_img_idx < 32; test_img_idx = test_img_idx + 1)begin
                for(ref_index = 0; ref_index < 128; ref_index = ref_index + 16)begin  //一个循环读取16张图片
                    //------------------向HotBuffer写入16张图片的数据---------------------
                    hot_read_en = 0;
                    hot_write_en = 1;
                    for(integer i = 0; i < 64; i = i + 1)begin
                        hot_idx = i;
                        for(integer j = 0; j < 256; j = j + 16)begin
                            for(integer k = 0 ; k < 16; k = k + 1)begin
                                if(i%4 == 3 && j >= 16)begin
                                    hot_buff_in[j+k] = 16'b0;   //第4行的第一块之后的数据全赋0,因为一张image只能存49块，一行是16块，因此只能存到第4行第1块
                                end else begin
                                    hot_buff_in[j+k] = ref_images[i/4][256*(i%4)+k];
                                end
                            end
                            #2;
                        end
                    end
                    clear_reg_acc = 1;  //初始化寄存器的状态，避免出现32'hxxxx_xxxx + 任何数 依旧是32'hxxxx_xxxx的情况
                    #2; 
                    hot_read_en = 1;
                    hot_write_en = 0;
                    cold_read_en = 1;
                    cold_write_en = 0;
                    for(integer ref_img_idx = 0; ref_img_idx < 16; ref_img_idx = ref_img_idx + 1)begin  //遍历16张图片
                        //---------------开始计算1张测试图片和1张参考图片之间的距离------------------
                        for(integer mlu_idx = 0; mlu_idx < 4; mlu_idx = mlu_idx + 1)begin    //1张图片需要进行4轮MLU运算
                            hot_idx = test_img_idx * 4 + mlu_idx;
                            cold_idx = ref_img_idx * 4 + mlu_idx;
                            symbol = 2'b10;
                            #2;    //给时间记录数据
                            sel_in = 0;  //选择从Adder层传递过来的数据
                            index = ref_index * 16 + ref_img_idx;  //第几张图片
                            fun_id = 3'b0;  // 暂时用不上非线性函数
                            asce = 1'b1;
                            if(mlu_idx == 3)begin  //到第4块，运算完4轮之后，再输出Acc累加和
                                sel_output = 3'b110; //将Ksort模块的结果输出
                                is_output = 1;
                                #4;
                                clear_reg_acc = 1;
                                is_output = 0;    //清空为0了，避免0输出
                            end else begin
                                sel_output = 3'b0;
                                is_output = 0;
                                clear_reg_acc = 0;
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
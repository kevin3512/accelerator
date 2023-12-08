//点积操作
`timescale 1ns/1ns
module test_knn;
    parameter         REF_IMAGE_NUM = 60000;
    parameter         TEST_IMAGE_NUM = 10000;
    parameter         IMAGE_SIZE = 784;   //28*28
    parameter         BUFFER_SIZE = 2048;  //4 块 512
    reg               clk;
    reg               rst;
    reg [31:0]        in[3:0][15:0];       
    reg [31:0]        par[3:0][15:0];
    reg [2:0]         col_index;  
    reg [7:0]         sel_cu;                                                    
    reg [7:0]         sel_cu_go_back;   
    reg [7:0]         sel_adder;          
    reg [3:0]         is_save_cu_out;          
                      //control output model(one row PE or one column PE or one PE or all PE)
    reg [1:0]         sum_row_pe;              
    reg [1:0]         sum_column_pe;         
    wire [31:0]       scalar_output[3:0]; 
    wire [31:0]       out[3:0][15:0];

    //MNIST数据集数据
    reg[31:0]       input_data[7:0][63:0];
    reg[31:0]       par_data[7:0][63:0];
    //图片加载1000个verdi可以显示成功，3000不行
    reg[7:0]        ref_images[REF_IMAGE_NUM-1:0][IMAGE_SIZE-1:0];
    reg[7:0]        ref_labels[REF_IMAGE_NUM-1:0]; 
    reg[7:0]        test_images[TEST_IMAGE_NUM-1:0][IMAGE_SIZE-1:0];
    reg[7:0]        test_labels[TEST_IMAGE_NUM-1:0]; 

    integer         img_index;

    reg[31:0]       mem_data[BUFFER_SIZE-1:0];   //4块buff的总长
    reg             mlb_opt;
    reg[1:0]        mlb_sel;
    reg[31:0]       mem_data_in[BUFFER_SIZE-1:0];
    reg[31:0]       mem_data_par[BUFFER_SIZE-1:0];    

    //Input buffer
    MLB #(.LENGTH(2048), .COLUMN(8), .GROUP(64)) mlb_in (
        .clk(clk),
        .rst(rst),
        .mem_data(mem_data_in),
        .operator(mlb_opt),
        .sel_buf(mlb_sel),
        .out(input_data)
    );

    //Weight buffer
    MLB #(.LENGTH(2048), .COLUMN(8), .GROUP(64)) mlb_par (
        .clk(clk),
        .rst(rst),
        .mem_data(mem_data_par),
        .operator(mlb_opt),
        .sel_buf(mlb_sel),
        .out(par_data)
    );

    PE_array pe_array (
        .clk(clk),
        .rst(rst),
        .In0_0(in[0][0]), .In0_1(in[0][1]), .In0_2(in[0][2]), .In0_3(in[0][3]), .In0_4(in[0][4]), .In0_5(in[0][5]), .In0_6(in[0][6]), .In0_7(in[0][7]), .In0_8(in[0][8]), .In0_9(in[0][9]), .In0_10(in[0][10]), .In0_11(in[0][11]), .In0_12(in[0][12]), .In0_13(in[0][13]), .In0_14(in[0][14]), .In0_15(in[0][15]),
        .Par0_0(par[0][0]), .Par0_1(par[0][1]), .Par0_2(par[0][2]), .Par0_3(par[0][3]), .Par0_4(par[0][4]), .Par0_5(par[0][5]), .Par0_6(par[0][6]), .Par0_7(par[0][7]), .Par0_8(par[0][8]), .Par0_9(par[0][9]), .Par0_10(par[0][10]), .Par0_11(par[0][11]), .Par0_12(par[0][12]), .Par0_13(par[0][13]), .Par0_14(par[0][14]), .Par0_15(par[0][15]),
        .In1_0(in[1][0]), .In1_1(in[1][1]), .In1_2(in[1][2]), .In1_3(in[1][3]), .In1_4(in[1][4]), .In1_5(in[1][5]), .In1_6(in[1][6]), .In1_7(in[1][7]), .In1_8(in[1][8]), .In1_9(in[1][9]), .In1_10(in[1][10]), .In1_11(in[1][11]), .In1_12(in[1][12]), .In1_13(in[1][13]), .In1_14(in[1][14]), .In1_15(in[1][15]),
        .Par1_0(par[1][0]), .Par1_1(par[1][1]), .Par1_2(par[1][2]), .Par1_3(par[1][3]), .Par1_4(par[1][4]), .Par1_5(par[1][5]), .Par1_6(par[1][6]), .Par1_7(par[1][7]), .Par1_8(par[1][8]), .Par1_9(par[1][9]), .Par1_10(par[1][10]), .Par1_11(par[1][11]), .Par1_12(par[1][12]), .Par1_13(par[1][13]), .Par1_14(par[1][14]), .Par1_15(par[1][15]),
        .In2_0(in[2][0]), .In2_1(in[2][1]), .In2_2(in[2][2]), .In2_3(in[2][3]), .In2_4(in[2][4]), .In2_5(in[2][5]), .In2_6(in[2][6]), .In2_7(in[2][7]), .In2_8(in[2][8]), .In2_9(in[2][9]), .In2_10(in[2][10]), .In2_11(in[2][11]), .In2_12(in[2][12]), .In2_13(in[2][13]), .In2_14(in[2][14]), .In2_15(in[2][15]),
        .Par2_0(par[2][0]), .Par2_1(par[2][1]), .Par2_2(par[2][2]), .Par2_3(par[2][3]), .Par2_4(par[2][4]), .Par2_5(par[2][5]), .Par2_6(par[2][6]), .Par2_7(par[2][7]), .Par2_8(par[2][8]), .Par2_9(par[2][9]), .Par2_10(par[2][10]), .Par2_11(par[2][11]), .Par2_12(par[2][12]), .Par2_13(par[2][13]), .Par2_14(par[2][14]), .Par2_15(par[2][15]),
        .In3_0(in[3][0]), .In3_1(in[3][1]), .In3_2(in[3][2]), .In3_3(in[3][3]), .In3_4(in[3][4]), .In3_5(in[3][5]), .In3_6(in[3][6]), .In3_7(in[3][7]), .In3_8(in[3][8]), .In3_9(in[3][9]), .In3_10(in[3][10]), .In3_11(in[3][11]), .In3_12(in[3][12]), .In3_13(in[3][13]), .In3_14(in[3][14]), .In3_15(in[3][15]),
        .Par3_0(par[3][0]), .Par3_1(par[3][1]), .Par3_2(par[3][2]), .Par3_3(par[3][3]), .Par3_4(par[3][4]), .Par3_5(par[3][5]), .Par3_6(par[3][6]), .Par3_7(par[3][7]), .Par3_8(par[3][8]), .Par3_9(par[3][9]), .Par3_10(par[3][10]), .Par3_11(par[3][11]), .Par3_12(par[3][12]), .Par3_13(par[3][13]), .Par3_14(par[3][14]), .Par3_15(par[3][15]),
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

    sort_relu sort_isnt(.clk(clk), .rst(rst), .in(scalar_output[0]), .index(img_index), .asce(1'b1));

    initial begin
        $fsdbDumpfile("tb.fsdb");
        $fsdbDumpvars(0);
        $fsdbDumpMDA();
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
        // 从数据集中读取文件
        read_mnist_dataset_task(ref_images, ref_labels, test_images, test_labels);
        $display("读取到训练集图片最后一个字节(第%d个)为%h" ,REF_IMAGE_NUM, ref_images[REF_IMAGE_NUM-1][IMAGE_SIZE-1]);
        for (img_index = 0; img_index < 1000; img_index = img_index + 1)begin
            $display("正在计算第%d个图片的分类结果", img_index+1);
            for(integer i = 0; i < 6000; i = i + 2)begin  //一个循环读取2张图片
                //TODO 1,把2张图片数据写入到MLB
                //TODO 2,从MLB中读取4次数据进行计算(cal_distance)

                // 完成两张图片之间计算距离的操作 
                for(integer j = 0; j < 2; j = j + 1)begin
                    // 从内存中读取PE array所需数据
                    // read_in_and_par(test_images[img_index][IMAGE_SIZE-1:0], ref_images[i][IMAGE_SIZE-1:0], j , input_data, par_data);
                    // 从MLB中读取PE array所需数据
                    read_in_and_par_from_mlb(test_images[img_index][IMAGE_SIZE-1:0], ref_images[i][IMAGE_SIZE-1:0], j , input_data, par_data);
                    // cal_dot_product(input_data, par_data);
                    cal_distance(input_data, par_data);
                end
            end
        end
        #100
        $finish; // 完成仿真
    end

endmodule
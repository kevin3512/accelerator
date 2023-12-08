module sort_relu_tb;
    reg          clk;
    reg          rst;
    reg [31:0]   in_data;
    reg [31:0]   in_index;
    reg          asce;

    wire [31:0] value_out;
    wire [31:0] value_index_out;

    // 实例化被测试模块
    sort_relu inst (
    .clk(clk),
    .rst(rst),
    .in(in_data),
    .index(in_index),
    .asce(asce)
    );

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

  // 生成仿真模拟输入
  initial begin
    // 模拟升序排序
    asce = 1;

    // 第一个值
    in_data = 20;
    in_index = 0;
    #2;
    // 第二个值
    in_data = 15;
    in_index = 1;
    #2;
    in_data = 25;
    in_index = 2;
    #2;
    in_data = 5;
    in_index = 3;
    #2;
    in_data = 2;
    in_index = 4;
    #2;
    in_data = 10;
    in_index = 5;
    #2;
    in_data = 35;
    in_index = 6;
    // ... 添加更多的测试值

    // 模拟降序排序
    // asce = 0;

    // 第一个值
    in_data = 13;
    in_index = 7;
    #5;
    // 第二个值
    in_data = 11;
    in_index = 8;
    #5;
    in_data = 7;
    in_index = 9;
    #5;
    in_data = 15;
    in_index = 10;
    #5;
    in_data = 8;
    in_index = 11;
    #5;
    in_data = 12;
    in_index = 12;
    #5;
    in_data = 9;
    in_index = 13;

    // 在仿真中持续运行
    #1000 $finish;
  end

endmodule

module Misc#(parameter WIDTH = 32, K = 20)(
    input                   clk,
    input                   rst,
    input[WIDTH-1:0]        in,
    input[WIDTH-1:0]        index,
    input[2:0]              fun_id,       //非线性函数id
    input                   asce,   //升序排序信号，1表示升序（从小到大排列），0表示降序
    input                   clear_reg,
    output[WIDTH-1:0]       out_nonli,    //nonlinear模块输出
    output[WIDTH-1:0]       out_ksort[K-1:0],    //k_sort模块输出
    output[WIDTH-1:0]       out_ksort_index[K-1:0]
);

    nonlinear #(WIDTH) non_inst(.clk(clk), .rst(rst), .in(in), .fun_id(fun_id), .out(out_nonli));
    k_sort #(WIDTH, K) k_sort_inst(.clk(clk), .rst(rst), .in(in), .index(index), .asce(asce), .clear_reg(clear_reg), .out(out_ksort), .out_index(out_ksort_index));
endmodule 
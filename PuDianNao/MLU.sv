module MLU #(parameter DATA_WIDTH = 16, Counter_WIDTH = 16, Adder_WIDTH = 16, Multiplier_WIDTH = 16, Adder_tree_WIDTH = 16, Acc_WIDTH = 32, Misc_WIDTH = 32, K = 20)(
    input[DATA_WIDTH-1:0]           hot_in[15:0],
    input[DATA_WIDTH-1:0]           cold_in[15:0],
    input[2:0]                      sel_output,      //选择输出哪一部分
    //  Multiplier部分需要的输入
    input                           sel_in,
    // Acc部分需要的输入
    input                           isStop,
    input                           clear_reg,      //公共的清除寄存器信号
    // Misc部分需要的输入
    input[Misc_WIDTH-1:0]           index,
    input[2:0]                      fun_id,       //非线性函数id
    input                           asce,   //升序排序信号，1表示升序（从小到大排列），0表示降序
    input                           is_start,     //是否可以开始
    output[31:0]                    out_scalar,
    output[31:0]                    out_vector[15:0]

);
wire[Counter_WIDTH-1:0]         out_counter[15:0];
wire[Adder_WIDTH-1:0]           out_adder[15:0];
wire[Multiplier_WIDTH-1:0]      out_multiplier[15:0];
wire[Adder_tree_WIDTH-1:0]      out_adder_tree;
wire[Acc_WIDTH-1:0]             out_acc;
wire[Misc_WIDTH-1:0]            out_misc_nonlin;
wire[Misc_WIDTH-1:0]            out_misc_ksort[K-1:0];

Counter #(Counter_WIDTH) counter_ins (.hot_in(hot_in), .cold_in(cold_in), .out(out_counter));
Adder #(Adder_WIDTH) adder_ins(.hot_in(hot_in), .cold_in(cold_in), .out(out_adder));
Multiplier #(Multiplier_WIDTH) multiplier_ins(.hot_in(hot_in), .cold_in(cold_in), .pre_data(out_adder), .sel_in(sel_in), .out(out_multiplier));
Adder_tree #(Adder_tree_WIDTH) adder_tree_ins(.in(out_multiplier), .out(out_adder_tree));
Acc #(Acc_WIDTH) acc_ins(.in(out_adder_tree), .isStop(isStop), .clear_reg(clear_reg), .out(acc_out));
Misc #(Misc_WIDTH) misc_ins(.in(acc_out), .fun_id(fun_id), .asce(asce), .is_start(is_start), .clear_reg(clear_reg), .out_nonli(out_misc_nonlin), .out_ksort(out_misc_ksort));

sel_6 sel6_ins(.in_counter(out_counter), .in_adder(out_adder), .in_multiplier(out_multiplier), .in_acc(out_acc), .in_nonlin(out_misc_nonlin), .in_ksort(out_misc_ksort), .sel(sel_output), .out_scalar(out_scalar), .out_vector(out_vector));
endmodule
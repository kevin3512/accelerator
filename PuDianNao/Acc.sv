module Acc (
    input[31:0]    in,
    input               is_output,  //是否结束累加
    input               clear_reg,  //清除累加数据
    output[31:0]   out
);

reg[31:0]       acc_data = 32'h0;  //需要先拉clear_reg信号给acc_data赋0才能累加
reg             need_add;
reg[31:0]       out;

always @ (in) begin : set_new_data   //通过need_add来控制每个输入信号只累加一次
    if(in !== 32'hxxxx_xxxx)begin
        need_add = 1;
    end
end

always @(need_add or clear_reg) begin : clear_acc_reg   //将当前所有保存的寄存器清除
    if(need_add)begin
        acc_data = acc_data + in;
        need_add = 0;
    end
    if(clear_reg)begin   //清楚数据
        acc_data = 32'h0;
    end 
end

assign out = is_output ? acc_data : 32'hxxxx_xxxx;

endmodule
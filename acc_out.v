// 输出处理模块
module acc_out(
    input           clk,
    input           rst,
    input[2:0]      sig,     //累加或者拼接的控制信号
    input[31:0]     data,
    input           isStop,  //是否是最后一个数据
    output[31:0]    out,
);
reg[31:0]   acc_data;
reg[31:0]   out;

assign out = isStop ? acc_data : 32'hxxxx_xxxx;

always @ (posedge clk or negedge rst)begin
    if(!rst)begin
    end else begin
        case (sig)
            3'b001:  //acc 累加
            begin
                acc_data = acc_data + data;
            end
            3'b010:  //output
            begin
                out = acc_data;
            end
            3'b011:  //拼接开始
            begin
                isStop = 0;
            end
            3'b100:  //拼接结束 
            begin
                isStop = 1;
            end

        endcase
    end
end

endmodule
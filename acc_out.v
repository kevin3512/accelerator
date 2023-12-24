// 输出处理模块
module acc_out(
    input               clk,
    input               rst,
    input[2:0]          sig,     //累加或者拼接的控制信号
    input[31:0]         data,
    input               isStop,  //是否是最后一个数据
    input               clear_reg,  //清除当前的累加数据
    output[31:0]        out
);
reg[31:0]   acc_data;
reg         need_add;   
reg[31:0]   out;

always @ (data) begin : set_new_data
    need_add = 1;
end

always @(posedge clk or negedge rst) begin : clear_acc_reg   //将当前所有保存的寄存器清除
    if(!rst)begin

    end else begin
        if(clear_reg)begin
            acc_data = 32'h0;
        end // 
        
    end
end

always @(posedge clk or negedge rst)begin : output_result
    if(!rst)begin

    end else begin
        out = isStop ? acc_data : 32'hxxxx_xxxx;
    end
end

always @ (posedge clk or negedge rst)begin
    if(!rst)begin
    end else begin
        case (sig)
            3'b001:  //acc 累加
            begin
                if(need_add)begin
                    acc_data = acc_data + data;
                    need_add = 0;
                end
            end
            3'b010:  //output
            begin
                
            end
            3'b011:  //拼接开始
            begin
                
            end
            3'b100:  //拼接结束 
            begin
                
            end

        endcase
    end
end

endmodule
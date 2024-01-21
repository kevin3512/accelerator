// 输出处理模块
module acc_out(
    input               clk,
    input               rst,
    input[2:0]          sig,     //累加或者拼接的控制信号
    input[31:0]         data0, data1, data2, data3,
    input               isStop0, isStop1, isStop2, isStop3 , isStop_total,  //是否是最后一个数据
    input               clear_reg0, clear_reg1, clear_reg2, clear_reg3 , clear_reg_total,  //清除当前的累加数据
    output reg[31:0]    out0, out1, out2, out3, out_total
);
reg[31:0]   acc_data0, acc_data1, acc_data2, acc_data3;
reg         need_add0, need_add1, need_add2, need_add3;   
reg[31:0]   acc_data_total;

always @ (data0) begin : set_new_data0
    if(data0 !== 32'hxxxx_xxxx)begin
        need_add0 = 1;
    end
end

always @ (data1) begin : set_new_data1
    if(data1 !== 32'hxxxx_xxxx)begin
        need_add1 = 1;
    end
end

always @ (data2) begin : set_new_data2
    if(data2 !== 32'hxxxx_xxxx)begin
        need_add2 = 1;
    end
end

always @ (data3) begin : set_new_data3
    if(data3 !== 32'hxxxx_xxxx)begin
        need_add3 = 1;
    end
end

always @(posedge clk or negedge rst) begin : clear_acc_reg   //将当前所有保存的寄存器清除
    if(!rst)begin

    end else begin
        if(clear_reg0)begin
            acc_data0 = 32'h0;
        end  
        if(clear_reg1)begin
            acc_data1 = 32'h0;
        end
        if(clear_reg2)begin
            acc_data2 = 32'h0;
        end
        if(clear_reg3)begin
            acc_data3 = 32'h0;
        end
        if(clear_reg_total)begin
            acc_data_total = 32'h0;
        end
    end
end

always @(posedge clk or negedge rst)begin : output_result
    if(!rst)begin

    end else begin
        out0 = isStop0 ? acc_data0 : 32'hxxxx_xxxx;
        out1 = isStop1 ? acc_data1 : 32'hxxxx_xxxx;
        out2 = isStop2 ? acc_data2 : 32'hxxxx_xxxx;
        out3 = isStop3 ? acc_data3 : 32'hxxxx_xxxx;
        out_total = isStop_total ? acc_data_total : 32'hxxxx_xxxx;
    end
end

always @ (posedge clk or negedge rst)begin
    if(!rst)begin
    end else begin
        case (sig)
            3'b001:  //每个通道单独累加
                begin
                    if(need_add0)begin
                        acc_data0 = acc_data0 + data0;
                        need_add0 = 0;
                    end
                    if(need_add1)begin
                        acc_data1 = acc_data1 + data1;
                        need_add1 = 0;
                    end
                    if(need_add2)begin
                        acc_data2 = acc_data2 + data2;
                        need_add2 = 0;
                    end
                    if(need_add3)begin
                        acc_data3 = acc_data3 + data3;
                        need_add3 = 0;
                    end
                end
            3'b010:  //4个通道累加到一起
                begin
                    acc_data_total = acc_data0 + acc_data1 + acc_data2 + acc_data3; 
                end

        endcase
    end
end

endmodule
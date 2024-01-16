module sel_6 #(parameter K = 20)(
    input                  clk,
    input                  rst,
    input[31:0]            in_counter[15:0],
    input[31:0]            in_adder[15:0],
    input[31:0]            in_multiplier[15:0],
    input[31:0]            in_acc,
    input[31:0]            in_nonlin,
    input[31:0]            in_ksort[K-1:0],
    input[31:0]            in_ksort_index[K-1:0],   //ksort数据对应的下标
    input[2:0]             sel,      //选择信号
    input[31:0]            count,       //用与输出ksort数据的情况，当K大于16时，out_vector需要多轮输出，赋值位0,1,2三轮即可，16*3=48，足以输出2*20=40位
    output[31:0]           out_scalar,   //标量输出
    output[31:0]           out_vector[15:0]    //向量输出

);
reg[31:0]            out_scalar;
reg[31:0]            out_vector[15:0];
reg[31:0]            out_ksort[2*K-1:0];   //in_ksort和in_ksort_index的叠加

always@(posedge clk or negedge rst)begin
    if(!rst)begin

    end else begin
        case(sel)
            3'b001:
                begin
                    out_vector = in_counter;
                end
            3'b010:
                begin
                    out_vector = in_adder;
                end
            3'b011:
                begin
                    out_vector = in_multiplier;
                end
            3'b100:
                begin
                    out_scalar = in_acc;
                end
            3'b101:
                begin
                    out_scalar = in_nonlin;
                end
            3'b110:
                begin
                    for(integer i = 0 ; i < K; i = i + 1)begin
                        out_ksort[i] = in_ksort[i];
                        out_ksort[K+i] = in_ksort_index[i];
                    end
                    if (count*16 + 15 < 2*K)begin
                        //表示选择从count*16开始的16位数据赋值给out_vector
                        out_vector = out_ksort[count*16 +: 16];
                    end else begin
                        out_vector = out_ksort[count*16 +: 16];   //不足16位时，自动取到最后一位
                    end
                end
        endcase
    end
    
end

endmodule
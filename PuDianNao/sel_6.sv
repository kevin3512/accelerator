module sel_6 #(parameter K = 20)(
    input[31:0]            in_counter[15:0],
    input[15:0]            in_adder[15:0],
    input[15:0]            in_multiplier[15:0],
    input[31:0]            in_acc,
    input[31:0]            in_nonlin,
    input[31:0]            in_ksort[K-1:0],
    input[2:0]             sel,      //选择信号
    output[31:0]           out_scalar,   //标量输出
    output[31:0]           out_vector[15:0],    //向量输出
    output[31:0]           out_ksort[K-1:0]      //K排序输出

);

reg[31:0]       out_scalar;
reg[31:0]       out_vector[15:0];
reg[31:0]       out_ksort[K-1:0];

always@(*)begin
    case(sel)
        3'b001:
            begin
                out_vector[15:0] = in_counter[15:0];
            end
        3'b010:
            begin
                out_vector[15:0] = in_adder[15:0];
            end
        3'b011:
            begin
                out_vector[15:0] = in_multiplier[15:0];
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
                out_ksort[K-1:0] = in_ksort[K-1:0];
            end
    endcase
end

endmodule
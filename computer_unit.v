//PE中的基本计算单元CU
module computer_unit(
    input               clk,
    input               enable,
    input[31:0]         Input_data,  //输入数据
    input[31:0]         Input_par,   //输入参数，如：权重
    input[1:0]          Sel,         //控制信号
    output reg[31:0]    Out          //输出信号
);
    always @(posedge clk or negedge enable)
        if(!enable)begin
            //do nothing
        end else begin
            case(Sel)
                2'b00:                   //减法操作
                    Out = Input_data - Input_par ; 
                2'b01:                   //比较器
                    Out = Input_data > Input_par ? 1 : 0 ;
                2'b10:                   //加法器
                    Out = Input_data + Input_par ;
                2'b11:                   //乘法器
                    Out = Input_data * Input_par;
            endcase
        end
        

endmodule
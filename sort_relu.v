// 排序和激活模块
module sort_relu(
    input                       clk,
    input                       rst,
    input[31:0]                 in,
    input[3:0]                  sig,          //控制信号,4'b0001表示排序， 4'b0010表示ReLu
    input[31:0]                 index,
    input                       asce,   //升序排序信号，1表示升序（从小到大排列），0表示降序
    input                       is_output,     //是否输出,适用于排序进行控制，ReLu激活的话，设置好sig，给一个输入就直接输出
    input                       clear_reg,
    output reg[31:0]            out,          //输出信号
    output reg[31:0]            out_index     //输出对应的下标
);
parameter           K = 20;
reg[31:0]           value_index[K-1:0];   //保存的当前最大/小值的下标
reg[31:0]           value[K-1:0];         //保存的当前K个最大/小值
reg                 need_insert;         //新输入的in是否需要插入
reg[3:0]            output_index = 0;   //输出排序数组的下标 , 按照输出一个value，一个value_index的方式输出

always @ (in) begin : set_new_data   //来了新数据就需要插入
    need_insert = 1;
end


always @(posedge clk or negedge rst) begin : clear_sort_reg   //将当前所有保存的寄存器清除
    if(!rst)begin

    end else begin
        if(clear_reg)begin
            for(integer i = 0 ; i < K ; i = i + 1)begin
                value[i] = 32'hxxxx_xxxx;
                value_index[i] = 32'hxxxx_xxxx;
            end
        end
        
    end
end

always @(posedge clk or negedge rst)begin:compare
    integer i;
    integer j;
    reg   flag; //标志位，0表示没找到位置，继续遍历找，1表示找到遍历位置，开始数据后移
    flag = 0;
    
    if(!rst)begin
        //复位信号
    end else begin
        case(sig)
            4'b0001:   //排序
            begin
                if(need_insert)begin
                    for(i = 0; i < K; i = i + 1)begin
                        if(flag == 0)begin
                            if(value[i] === 32'hxxxx_xxxx || (asce && in < value[i])  || (!asce && in > value[i]))begin
                                for(j = K-1; j > i; j = j - 1)begin
                                    value[j] = value[j-1];
                                    value_index[j] = value_index[j-1];
                                end
                                value[i] = in;
                                value_index[i] = index;
                                break;
                            end
                        end 
                    end
                    need_insert = 0;  //插入过了，下个时钟上升沿就不要再插入了
                end
                if(is_output)begin
                    out = value[output_index];
                    out_index = value_index[output_index];
                    output_index = output_index + 1;
                    if(output_index == K)begin
                        output_index = 0;
                    end
                end
            end
            4'b0010:   //ReLu激活函数
            begin
                out = in[31] > 0 ? 0 : in;
                // out = in;
            end
        endcase
        
        
    end
end

endmodule
// 排序和激活模块
module k_sort#(parameter WIDTH = 32, K = 20)(
    input                clk,
    input                rst,
    input[WIDTH-1:0]     in,
    input[WIDTH-1:0]     index,
    input                asce,   //升序排序信号，1表示升序（从小到大排列），0表示降序
    input                clear_reg,
    output[31:0]         out[K-1:0],   //输出最小/大的k个结果
    output[31:0]         out_index[K-1:0]   //对应的下标
);

reg[WIDTH-1:0]      value_index[K-1:0];   //保存的当前最大/小值的下标
reg[WIDTH-1:0]      value[K-1:0];         //保存的当前K个最大/小值
reg                 need_insert;         //新输入的in是否需要插入

always @ (in) begin : set_new_data   //来了新数据就需要插入
    need_insert = 1;
end


generate
    genvar w;
    for (w = 0; w < K; w = w + 1) begin
        assign out[w] = value[w];
        assign out_index[w] = value_index[w];
    end
endgenerate


always @(clear_reg) begin : clear_sort_reg   //将当前所有保存的寄存器清除
    if(clear_reg)begin
        for(integer i = 0 ; i < K ; i = i + 1)begin
            value[i] = 32'hxxxx_xxxx;
            value_index[i] = 32'hxxxx_xxxx;
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
        
    end
end

endmodule
module OutputBuffer (
    input               clk,
    input               rst,
    input[31:0]         in[255:0],
    input[3:0]          idx,        // 8 KB = 16 * 256 * 16 bit，因此下标有4位
    input               read_en,    //读使能
    input               write_en,   //写使能
    output[31:0]        out[255:0]
);

reg[31:0]       buff[15:0][255:0];   //OutputBuff可以保存16轮16个MLU的输入
reg[31:0]       out[255:0];

always @ (posedge clk or negedge rst)begin: save_mem_data
    integer i, j;
    if(!rst)begin

    end else begin
        if(write_en)begin
            for(i = 0; i < 256; i = i + 1)begin
                buff[idx][i] = in[i];
            end
        end else if(read_en) begin
            for(j = 0; j < 256; j = j + 1)begin
                out[j] = buff[idx][j];
            end
        end
    end
end

endmodule
module HotBuffer (
    input               clk,
    input               rst,
    input[31:0]         in[15:0],
    input[7:0]          idx,        // 8 KB = 256 * 16 * 16bit ，因此可以存储256次输入，下标有8位
    input               read_en,    //读使能
    input               write_en,   //写使能
    output[31:0]        out[15:0]
);

reg[31:0]       buff[255:0][15:0];   //Hotbuff可以保存256个MLU的输入，每个MLU的输入需要16维
reg[31:0]       out[15:0];

always @ (posedge clk or negedge rst)begin: save_mem_data
    integer i, j;
    if(!rst)begin

    end else begin
        if(write_en)begin
            for(i = 0; i < 16; i = i + 1)begin
                buff[idx][i] = in[i];
            end
        end else if(read_en) begin
            for(j = 0; j < 16; j = j + 1)begin
                out[j] = buff[idx][j];
            end
        end
    end
end

endmodule
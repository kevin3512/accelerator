//Testbench of PE_array case 2、6 (ADS、aDS): output column PE's output
`timescale 1ns/1ns
module PE_array_case2_6tb;
    reg clk;
    reg rst;
    reg [31:0]        in0_0, in0_1, in0_2, in0_3, in0_4, in0_5, in0_6, in0_7, in0_8, in0_9, in0_10, in0_11, in0_12, in0_13, in0_14, in0_15;       
    reg [31:0]        par0_0, par0_1, par0_2, par0_3, par0_4, par0_5, par0_6, par0_7, par0_8, par0_9, par0_10, par0_11, par0_12, par0_13, par0_14, par0_15;  

    reg [31:0]        in1_0, in1_1, in1_2, in1_3, in1_4, in1_5, in1_6, in1_7, in1_8, in1_9, in1_10, in1_11, in1_12, in1_13, in1_14, in1_15;         
    reg [31:0]        par1_0, par1_1, par1_2, par1_3, par1_4, par1_5, par1_6, par1_7, par1_8, par1_9, par1_10, par1_11, par1_12, par1_13, par1_14, par1_15;   

    reg [31:0]        in2_0, in2_1, in2_2, in2_3, in2_4, in2_5, in2_6, in2_7, in2_8, in2_9, in2_10, in2_11, in2_12, in2_13, in2_14, in2_15;        
    reg [31:0]        par2_0, par2_1, par2_2, par2_3, par2_4, par2_5, par2_6, par2_7, par2_8, par2_9, par2_10, par2_11, par2_12, par2_13, par2_14, par2_15;    

    reg [31:0]        in3_0, in3_1, in3_2, in3_3, in3_4, in3_5, in3_6, in3_7, in3_8, in3_9, in3_10, in3_11, in3_12, in3_13, in3_14, in3_15;         
    reg [31:0]        par3_0, par3_1, par3_2, par3_3, par3_4, par3_5, par3_6, par3_7, par3_8, par3_9, par3_10, par3_11, par3_12, par3_13, par3_14, par3_15; 
    reg [2:0]         col_index;  
                        //each signal for one column           
    reg [7:0]         sel_cu;                                                    
    reg [7:0]         sel_cu_go_back;   //each signal for one column  
    reg [7:0]         sel_adder;          
    reg [3:0]         is_save_cu_out;          
    
                        //control output model(one row PE or one column PE or one PE or all PE)
    reg [1:0]         sum_row_pe;              
    reg [1:0]         sum_column_pe;         

    wire [31:0]       scalar_output0, scalar_output1, scalar_output2, scalar_output3; 
    wire [31:0]       out0_0, out0_1, out0_2, out0_3, out0_4, out0_5, out0_6, out0_7, out0_8, out0_9, out0_10, out0_11, out0_12, out0_13, out0_14, out0_15;
    wire [31:0]       out1_0, out1_1, out1_2, out1_3, out1_4, out1_5, out1_6, out1_7, out1_8, out1_9, out1_10, out1_11, out1_12, out1_13, out1_14, out1_15;
    wire [31:0]       out2_0, out2_1, out2_2, out2_3, out2_4, out2_5, out2_6, out2_7, out2_8, out2_9, out2_10, out2_11, out2_12, out2_13, out2_14, out2_15;
    wire [31:0]       out3_0, out3_1, out3_2, out3_3, out3_4, out3_5, out3_6, out3_7, out3_8, out3_9, out3_10, out3_11, out3_12, out3_13, out3_14, out3_15;

    PE_array pe_array (
        .clk(clk),
        .rst(rst),
        .In0_0(in0_0), .In0_1(in0_1), .In0_2(in0_2), .In0_3(in0_3), .In0_4(in0_4), .In0_5(in0_5), .In0_6(in0_6), .In0_7(in0_7), .In0_8(in0_8), .In0_9(in0_9), .In0_10(in0_10), .In0_11(in0_11), .In0_12(in0_12), .In0_13(in0_13), .In0_14(in0_14), .In0_15(in0_15),
        .Par0_0(par0_0), .Par0_1(par0_1), .Par0_2(par0_2), .Par0_3(par0_3), .Par0_4(par0_4), .Par0_5(par0_5), .Par0_6(par0_6), .Par0_7(par0_7), .Par0_8(par0_8), .Par0_9(par0_9), .Par0_10(par0_10), .Par0_11(par0_11), .Par0_12(par0_12), .Par0_13(par0_13), .Par0_14(par0_14), .Par0_15(par0_15),
        .In1_0(in1_0), .In1_1(in1_1), .In1_2(in1_2), .In1_3(in1_3), .In1_4(in1_4), .In1_5(in1_5), .In1_6(in1_6), .In1_7(in1_7), .In1_8(in1_8), .In1_9(in1_9), .In1_10(in1_10), .In1_11(in1_11), .In1_12(in1_12), .In1_13(in1_13), .In1_14(in1_14), .In1_15(in1_15),
        .Par1_0(par1_0), .Par1_1(par1_1), .Par1_2(par1_2), .Par1_3(par1_3), .Par1_4(par1_4), .Par1_5(par1_5), .Par1_6(par1_6), .Par1_7(par1_7), .Par1_8(par1_8), .Par1_9(par1_9), .Par1_10(par1_10), .Par1_11(par1_11), .Par1_12(par1_12), .Par1_13(par1_13), .Par1_14(par1_14), .Par1_15(par1_15),
        .In2_0(in2_0), .In2_1(in2_1), .In2_2(in2_2), .In2_3(in2_3), .In2_4(in2_4), .In2_5(in2_5), .In2_6(in2_6), .In2_7(in2_7), .In2_8(in2_8), .In2_9(in2_9), .In2_10(in2_10), .In2_11(in2_11), .In2_12(in2_12), .In2_13(in2_13), .In2_14(in2_14), .In2_15(in2_15),
        .Par2_0(par2_0), .Par2_1(par2_1), .Par2_2(par2_2), .Par2_3(par2_3), .Par2_4(par2_4), .Par2_5(par2_5), .Par2_6(par2_6), .Par2_7(par2_7), .Par2_8(par2_8), .Par2_9(par2_9), .Par2_10(par2_10), .Par2_11(par2_11), .Par2_12(par2_12), .Par2_13(par2_13), .Par2_14(par2_14), .Par2_15(par2_15),
        .In3_0(in3_0), .In3_1(in3_1), .In3_2(in3_2), .In3_3(in3_3), .In3_4(in3_4), .In3_5(in3_5), .In3_6(in3_6), .In3_7(in3_7), .In3_8(in3_8), .In3_9(in3_9), .In3_10(in3_10), .In3_11(in3_11), .In3_12(in3_12), .In3_13(in3_13), .In3_14(in3_14), .In3_15(in3_15),
        .Par3_0(par3_0), .Par3_1(par3_1), .Par3_2(par3_2), .Par3_3(par3_3), .Par3_4(par3_4), .Par3_5(par3_5), .Par3_6(par3_6), .Par3_7(par3_7), .Par3_8(par3_8), .Par3_9(par3_9), .Par3_10(par3_10), .Par3_11(par3_11), .Par3_12(par3_12), .Par3_13(par3_13), .Par3_14(par3_14), .Par3_15(par3_15),
        .Col_index(col_index),
        .Sel_cu(sel_cu),
        .Sel_cu_go_back(sel_cu_go_back),
        .Sel_adder(sel_adder), 
        .Is_save_cu_out(is_save_cu_out),
        .Sum_row_pe(sum_row_pe),
        .Sum_column_pe(sum_column_pe),
        .Scalar_output0(scalar_output0), .Scalar_output1(scalar_output1), .Scalar_output2(scalar_output2), .Scalar_output3(scalar_output3),
        .Out0_0(out0_0), .Out0_1(out0_1), .Out0_2(out0_2), .Out0_3(out0_3), .Out0_4(out0_4), .Out0_5(out0_5), .Out0_6(out0_6), .Out0_7(out0_7), .Out0_8(out0_8), .Out0_9(out0_9), .Out0_10(out0_10), .Out0_11(out0_11), .Out0_12(out0_12), .Out0_13(out0_13), .Out0_14(out0_14), .Out0_15(out0_15),
        .Out1_0(out1_0), .Out1_1(out1_1), .Out1_2(out1_2), .Out1_3(out1_3), .Out1_4(out1_4), .Out1_5(out1_5), .Out1_6(out1_6), .Out1_7(out1_7), .Out1_8(out1_8), .Out1_9(out1_9), .Out1_10(out1_10), .Out1_11(out1_11), .Out1_12(out1_12), .Out1_13(out1_13), .Out1_14(out1_14), .Out1_15(out1_15),
        .Out2_0(out2_0), .Out2_1(out2_1), .Out2_2(out2_2), .Out2_3(out2_3), .Out2_4(out2_4), .Out2_5(out2_5), .Out2_6(out2_6), .Out2_7(out2_7), .Out2_8(out2_8), .Out2_9(out2_9), .Out2_10(out2_10), .Out2_11(out2_11), .Out2_12(out2_12), .Out2_13(out2_13), .Out2_14(out2_14), .Out2_15(out2_15),
        .Out3_0(out3_0), .Out3_1(out3_1), .Out3_2(out3_2), .Out3_3(out3_3), .Out3_4(out3_4), .Out3_5(out3_5), .Out3_6(out3_6), .Out3_7(out3_7), .Out3_8(out3_8), .Out3_9(out3_9), .Out3_10(out3_10), .Out3_11(out3_11), .Out3_12(out3_12), .Out3_13(out3_13), .Out3_14(out3_14), .Out3_15(out3_15)
    );

    initial begin
        $fsdbDumpfile("tb.fsdb");
        $fsdbDumpvars(0);
        $fsdbDumpMDA();
        clk = 0;
        rst = 1;
        forever begin
            #5 clk = ~clk;
        end
    end

    reg[31:0]   input_data[7:0][63:0];
    reg[31:0]   par_data[7:0][63:0];

    initial begin
        // 从文件中读取输入数据
        $readmemh("input_data.txt", input_data);
        $readmemh("parametor_data.txt", par_data);
        #10
            sum_row_pe <= 2'b01;    //row select single PE  
        #10
            sum_column_pe <= 2'b10;  //column select sum of column PE
        for (integer i = 0; i < 8; i = i + 1)begin
            #10
            //控制信号清零，这样再次赋值才会生效
            sel_cu <= 8'b0;   
            #5
            sel_cu_go_back <= 8'b0;  
            #5
            sel_adder <= 8'b0;    
            #5
            col_index <= i[2:0];
            //row 1 PE's data
            in0_0 = input_data[i][0];
            in0_1 = input_data[i][1];
            in0_2 = input_data[i][2];
            in0_3 = input_data[i][3];
            in0_4 = input_data[i][4];
            in0_5 = input_data[i][5];
            in0_6 = input_data[i][6];
            in0_7 = input_data[i][7];
            in0_8 = input_data[i][8];
            in0_9 = input_data[i][9];
            in0_10 = input_data[i][10];
            in0_11 = input_data[i][11];
            in0_12 = input_data[i][12];
            in0_13 = input_data[i][13];
            in0_14 = input_data[i][14];
            in0_15 = input_data[i][15];
                        
            #10
            par0_0 = par_data[i][0];
            par0_1 = par_data[i][1];
            par0_2 = par_data[i][2];
            par0_3 = par_data[i][3];
            par0_4 = par_data[i][4];
            par0_5 = par_data[i][5];
            par0_6 = par_data[i][6];
            par0_7 = par_data[i][7];
            par0_8 = par_data[i][8];
            par0_9 = par_data[i][9];
            par0_10 = par_data[i][10];
            par0_11 = par_data[i][11];
            par0_12 = par_data[i][12];
            par0_13 = par_data[i][13];
            par0_14 = par_data[i][14];
            par0_15 = par_data[i][15];

            // row 2 PE's data
            #10
            in1_0 = input_data[i][16];
            in1_1 = input_data[i][17];
            in1_2 = input_data[i][18];
            in1_3 = input_data[i][19];
            in1_4 = input_data[i][20];
            in1_5 = input_data[i][21];
            in1_6 = input_data[i][22];
            in1_7 = input_data[i][23];
            in1_8 = input_data[i][24];
            in1_9 = input_data[i][25];
            in1_10 = input_data[i][26];
            in1_11 = input_data[i][27];
            in1_12 = input_data[i][28];
            in1_13 = input_data[i][29];
            in1_14 = input_data[i][30];
            in1_15 = input_data[i][31];

            #10
            par1_0 = par_data[i][16];
            par1_1 = par_data[i][17];
            par1_2 = par_data[i][18];
            par1_3 = par_data[i][19];
            par1_4 = par_data[i][20];
            par1_5 = par_data[i][21];
            par1_6 = par_data[i][22];
            par1_7 = par_data[i][23];
            par1_8 = par_data[i][24];
            par1_9 = par_data[i][25];
            par1_10 = par_data[i][26];
            par1_11 = par_data[i][27];
            par1_12 = par_data[i][28];
            par1_13 = par_data[i][29];
            par1_14 = par_data[i][30];
            par1_15 = par_data[i][31];

            //row 3 PE's data
            #10
            in2_0 = input_data[i][32];
            in2_1 = input_data[i][33];
            in2_2 = input_data[i][34];
            in2_3 = input_data[i][35];
            in2_4 = input_data[i][36];
            in2_5 = input_data[i][37];
            in2_6 = input_data[i][38];
            in2_7 = input_data[i][39];
            in2_8 = input_data[i][40];
            in2_9 = input_data[i][41];
            in2_10 = input_data[i][42];
            in2_11 = input_data[i][43];
            in2_12 = input_data[i][44];
            in2_13 = input_data[i][45];
            in2_14 = input_data[i][46];
            in2_15 = input_data[i][47];

            #10
            par2_0 = par_data[i][32];
            par2_1 = par_data[i][33];
            par2_2 = par_data[i][34];
            par2_3 = par_data[i][35];
            par2_4 = par_data[i][36];
            par2_5 = par_data[i][37];
            par2_6 = par_data[i][38];
            par2_7 = par_data[i][39];
            par2_8 = par_data[i][40];
            par2_9 = par_data[i][41];
            par2_10 = par_data[i][42];
            par2_11 = par_data[i][43];
            par2_12 = par_data[i][44];
            par2_13 = par_data[i][45];
            par2_14 = par_data[i][46];
            par2_15 = par_data[i][47];

            //row 4 PE's data
            #10
            in3_0 = input_data[i][48];
            in3_1 = input_data[i][49];
            in3_2 = input_data[i][50];
            in3_3 = input_data[i][51];
            in3_4 = input_data[i][52];
            in3_5 = input_data[i][53];
            in3_6 = input_data[i][54];
            in3_7 = input_data[i][55];
            in3_8 = input_data[i][56];
            in3_9 = input_data[i][57];
            in3_10 = input_data[i][58];
            in3_11 = input_data[i][59];
            in3_12 = input_data[i][60];
            in3_13 = input_data[i][61];
            in3_14 = input_data[i][62];
            in3_15 = input_data[i][63];

            #10
            par3_0 = par_data[i][48];
            par3_1 = par_data[i][49];
            par3_2 = par_data[i][50];
            par3_3 = par_data[i][51];
            par3_4 = par_data[i][52];
            par3_5 = par_data[i][53];
            par3_6 = par_data[i][54];
            par3_7 = par_data[i][55];
            par3_8 = par_data[i][56];
            par3_9 = par_data[i][57];
            par3_10 = par_data[i][58];
            par3_11 = par_data[i][59];
            par3_12 = par_data[i][60];
            par3_13 = par_data[i][61];
            par3_14 = par_data[i][62];
            par3_15 = par_data[i][63];

            #10
            sel_cu <= 8'b11111111;   //add
            #10
            sel_cu_go_back <= 8'b10101010;  // go next
            #10
            sel_adder <= 8'b01010101;     //go next 
        end
            
        #200;
            //控制信号清零，这样再次赋值才会生效
            sel_cu <= 8'b0;   
            sel_cu_go_back <= 8'b0;  
            sel_adder <= 8'b0;     
        #10
            //再次重新传数据
            $readmemh("input_data.txt", input_data);
            $readmemh("parametor_data.txt", par_data);
            for (integer i = 0; i < 8; i = i + 1)begin
                #10
                //控制信号清零，这样再次赋值才会生效
                sel_cu <= 8'b0;   
                #5
                sel_cu_go_back <= 8'b0;  
                #5
                sel_adder <= 8'b0;    
                #5
                col_index <= i[2:0];
                //row 1 PE's data
                in0_0 <= input_data[i][0];
                in0_1 <= input_data[i][1];
                in0_2 <= input_data[i][2];
                in0_3 <= input_data[i][3];
                in0_4 <= input_data[i][4];
                in0_5 <= input_data[i][5];
                in0_6 <= input_data[i][6];
                in0_7 <= input_data[i][7];
                in0_8 <= input_data[i][8];
                in0_9 <= input_data[i][9];
                in0_10 <= input_data[i][10];
                in0_11 <= input_data[i][11];
                in0_12 <= input_data[i][12];
                in0_13 <= input_data[i][13];
                in0_14 <= input_data[i][14];
                in0_15 <= input_data[i][15];
                            
                par0_0 <= par_data[i][0];
                par0_1 <= par_data[i][1];
                par0_2 <= par_data[i][2];
                par0_3 <= par_data[i][3];
                par0_4 <= par_data[i][4];
                par0_5 <= par_data[i][5];
                par0_6 <= par_data[i][6];
                par0_7 <= par_data[i][7];
                par0_8 <= par_data[i][8];
                par0_9 <= par_data[i][9];
                par0_10 <= par_data[i][10];
                par0_11 <= par_data[i][11];
                par0_12 <= par_data[i][12];
                par0_13 <= par_data[i][13];
                par0_14 <= par_data[i][14];
                par0_15 <= par_data[i][15];

                // row 2 PE's data
                #10
                in1_0 <= input_data[i][16];
                in1_1 <= input_data[i][17];
                in1_2 <= input_data[i][18];
                in1_3 <= input_data[i][19];
                in1_4 <= input_data[i][20];
                in1_5 <= input_data[i][21];
                in1_6 <= input_data[i][22];
                in1_7 <= input_data[i][23];
                in1_8 <= input_data[i][24];
                in1_9 <= input_data[i][25];
                in1_10 <= input_data[i][26];
                in1_11 <= input_data[i][27];
                in1_12 <= input_data[i][28];
                in1_13 <= input_data[i][29];
                in1_14 <= input_data[i][30];
                in1_15 <= input_data[i][31];

                par1_0 <= par_data[i][16];
                par1_1 <= par_data[i][17];
                par1_2 <= par_data[i][18];
                par1_3 <= par_data[i][19];
                par1_4 <= par_data[i][20];
                par1_5 <= par_data[i][21];
                par1_6 <= par_data[i][22];
                par1_7 <= par_data[i][23];
                par1_8 <= par_data[i][24];
                par1_9 <= par_data[i][25];
                par1_10 <= par_data[i][26];
                par1_11 <= par_data[i][27];
                par1_12 <= par_data[i][28];
                par1_13 <= par_data[i][29];
                par1_14 <= par_data[i][30];
                par1_15 <= par_data[i][31];

                //row 3 PE's data
                #10
                in2_0 <= input_data[i][32];
                in2_1 <= input_data[i][33];
                in2_2 <= input_data[i][34];
                in2_3 <= input_data[i][35];
                in2_4 <= input_data[i][36];
                in2_5 <= input_data[i][37];
                in2_6 <= input_data[i][38];
                in2_7 <= input_data[i][39];
                in2_8 <= input_data[i][40];
                in2_9 <= input_data[i][41];
                in2_10 <= input_data[i][42];
                in2_11 <= input_data[i][43];
                in2_12 <= input_data[i][44];
                in2_13 <= input_data[i][45];
                in2_14 <= input_data[i][46];
                in2_15 <= input_data[i][47];

                par2_0 <= par_data[i][32];
                par2_1 <= par_data[i][33];
                par2_2 <= par_data[i][34];
                par2_3 <= par_data[i][35];
                par2_4 <= par_data[i][36];
                par2_5 <= par_data[i][37];
                par2_6 <= par_data[i][38];
                par2_7 <= par_data[i][39];
                par2_8 <= par_data[i][40];
                par2_9 <= par_data[i][41];
                par2_10 <= par_data[i][42];
                par2_11 <= par_data[i][43];
                par2_12 <= par_data[i][44];
                par2_13 <= par_data[i][45];
                par2_14 <= par_data[i][46];
                par2_15 <= par_data[i][47];

                //row 4 PE's data
                #10
                in3_0 <= input_data[i][48];
                in3_1 <= input_data[i][49];
                in3_2 <= input_data[i][50];
                in3_3 <= input_data[i][51];
                in3_4 <= input_data[i][52];
                in3_5 <= input_data[i][53];
                in3_6 <= input_data[i][54];
                in3_7 <= input_data[i][55];
                in3_8 <= input_data[i][56];
                in3_9 <= input_data[i][57];
                in3_10 <= input_data[i][58];
                in3_11 <= input_data[i][59];
                in3_12 <= input_data[i][60];
                in3_13 <= input_data[i][61];
                in3_14 <= input_data[i][62];
                in3_15 <= input_data[i][63];

                par3_0 <= par_data[i][48];
                par3_1 <= par_data[i][49];
                par3_2 <= par_data[i][50];
                par3_3 <= par_data[i][51];
                par3_4 <= par_data[i][52];
                par3_5 <= par_data[i][53];
                par3_6 <= par_data[i][54];
                par3_7 <= par_data[i][55];
                par3_8 <= par_data[i][56];
                par3_9 <= par_data[i][57];
                par3_10 <= par_data[i][58];
                par3_11 <= par_data[i][59];
                par3_12 <= par_data[i][60];
                par3_13 <= par_data[i][61];
                par3_14 <= par_data[i][62];
                par3_15 <= par_data[i][63];

                #10
                sel_cu <= 8'b10101010;   //multiple
                #10
                sel_cu_go_back <= 8'b10101010;  // go next
                #10
                sel_adder <= 8'b10101010;     //sum of all
            end
        #100
        $finish; // 完成仿真
    end

endmodule
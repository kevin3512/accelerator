`timescale 1ns/1ns

module PE_array_tb;
  // Declare signals
  reg clk;
  reg rst;
  reg [31:0] Input_data[3:0][127:0];
  reg [31:0] Par_data[3:0][127:0];
  reg [1:0] Sel_cu[31:0];
  reg [1:0] Sel_cu_go_back[31:0];
  reg [1:0] Sel_adder[31:0];
  reg Is_save_cu_out[31:0];
  reg [1:0]   sel_row_pe;
  reg [1:0]   sel_column_pe;
  wire [31:0] scalar_output;
  wire [31:0] array_output[15:0];

  // Instantiate the PE_array module
  PE_array pe_array (
    .clk(clk),
    .rst(rst),
    .Input_data(Input_data),
    .Par_data(Par_data),
    .Sel_cu(Sel_cu),
    .Sel_cu_go_back(Sel_cu_go_back),
    .Sel_adder(Sel_adder),
    .Is_save_cu_out(Is_save_cu_out),
    .Sel_row_pe(2'b10), // Set PE_array row selection to 00 for array output
    .Sel_column_pe(2'b10), // Set PE_array column selection to 00 for array output
    .scalar_output(scalar_output),
    .array_output(array_output)
  );

  // Initialize signals
  initial begin
    clk = 0;
    rst = 0;
    // Initialize your input data, PE selection signals, and any other inputs here
    // For example:
    // Input_data[0][0] = 32'h12345678;
    // Sel_cu[0] = 2'b01;
    // ...
    // Simulate clock
    forever begin
      #5 clk = ~clk;
    end
  end

  // Display the outputs
//   always @(posedge clk) begin
//     // Display scalar_output
//     $display("Scalar Output: %h", scalar_output);
//     // Display array_output
//     $display("Array Output:");
//     for (integer i = 0; i < 16; i = i + 1) begin
//       $display("array_output[%0d] = %h", i, array_output[i]);
//     end
//   end

  // Simulate reset and input changes
  initial begin
    $fsdbDumpfile("tb.fsdb");
    $fsdbDumpvars(0);
    $fsdbDumpMDA();
    #10 rst = 1;
    // Perform some operations with the PE_array
    // Update inputs, etc.
    // 从文件中读取输入数据
    $readmemh("input_data.txt", Input_data);
    $readmemh("parametor_data.txt", Par_data);
    #10
        sel_row_pe <= 2'b01;    //row select sum of PE  
    #10
        sel_column_pe <= 2'b01;  //column select single PE
    for (integer i = 0; i < 32; i = i +1) begin
        #5
            Sel_cu[i] <= 2'b10;   //add
        #5
            Sel_cu_go_back[i] <= 2'b10;  // go next
        #5
            Sel_adder[i] <= 2'b01;     //go next 
    end
    #50 
        rst = 0;
    // Continue simulation or finish as needed
    #100 $finish;
  end

endmodule

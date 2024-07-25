`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 15.05.2024 18:43:20
// Design Name: 
// Module Name: BinaryToBCD
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////

// " double dabble " algorithm

module BinaryToBCD(Ip_Bin, op_BCD);

input [13:0] Ip_Bin;
output [19:0] op_BCD;

reg [3:0] ones;
reg [3:0] tens;
reg [3:0] hundreds;
reg [3:0] thousands;
reg [3:0] ten_thousands;

integer i;

always @(*) begin
    ones      = 4'd0;
    tens      = 4'd0;
    hundreds  = 4'd0;
    thousands = 4'd0;
    ten_thousands = 4'd0;
    
    for (i = 0; i < 14; i = i + 1) begin
        if (ones >= 4'd5) ones = ones + 4'd3;
        if (tens >= 4'd5) tens = tens + 4'd3;
        if (hundreds >= 4'd5) hundreds = hundreds + 4'd3;
        if (thousands >= 4'd5) thousands = thousands + 4'd3;
        
        ten_thousands = {ten_thousands[2:0], thousands[3]};
        thousands = {thousands[2:0], hundreds[3]};
        hundreds = {hundreds[2:0], tens[3]};
        tens = {tens[2:0], ones[3]};
        ones = {ones[2:0], Ip_Bin[13-i]};
    end   
end

assign op_BCD = {ten_thousands, thousands, hundreds, tens, ones};

endmodule

`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 16.05.2024 00:28:27
// Design Name: 
// Module Name: SevenSegment_Control
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

module clk_divider(clk, reset, clk_10kHz);
input clk, reset;
output reg clk_10kHz;

// for req frequency count till 100MHz/(2*desired freq) - 1
// have to count till 4999 and then flip the clk_10kHz

reg [12:0] counter;

// controlling the counter to count till 4999
always @(posedge clk) begin
    if(reset)
        counter <= 13'd0;
    else if(counter < 4999)
        counter <= counter + 1'b1;
    else 
        counter <= 13'd0;
end

// instantiating a clk_10kHz generator
always @(posedge clk)begin
    if(reset)
        clk_10kHz = 1'b0;
    else if(counter == 4999)
        clk_10kHz = ~clk_10kHz;
    else
        clk_10kHz = clk_10kHz;
end
endmodule


// refresh_counter : decides which digit is to be on
module refresh_counter (clk_10kHz, reset, refresh_count);
input clk_10kHz, reset;
output reg [2:0] refresh_count;

// refresh_count controlls which anode to be on and which digit is to be displayed
always @(posedge clk_10kHz) begin
    if(reset)
        refresh_count <= 3'd0;
    else if(refresh_count < 3'd4)
        refresh_count <= refresh_count + 1'b1;
    else
        refresh_count <= 3'd0;
end
endmodule


// Instantiation of "anode_control" based on refreshCount
module anode_Control (refreshCount, anodeControl);
input [2:0] refreshCount;
output reg [6:0] anodeControl;

always @(*) begin
    case(refreshCount)
        3'b000 : anodeControl = 8'b11111110;
        3'b001 : anodeControl = 8'b11111101;
        3'b010 : anodeControl = 8'b11111011;
        3'b011 : anodeControl = 8'b11110111;
        3'b100 : anodeControl = 8'b11101111;
        
        default: anodeControl = 8'b11111111;
    endcase
end

endmodule

// Instantiation of BCD control : which digit is to be passed based on refreshCount
module BCD_Control (ones, tens, hundreds, thousands, ten_thousands, refreshCount, Op_Digit);
input [3:0] ones;
input [3:0] tens;
input [3:0] hundreds;
input [3:0] thousands;
input [3:0] ten_thousands;
input [2:0] refreshCount;

output reg [3:0] Op_Digit;

always @(*) begin
    case(refreshCount)
        3'd0 : Op_Digit = ones;
        3'd1 : Op_Digit = tens;
        3'd2 : Op_Digit = hundreds;
        3'd3 : Op_Digit = thousands;
        3'd4 : Op_Digit = ten_thousands;
    endcase
end
endmodule

// Instantiation of BCD to Cathode module : 
module BCD_to_Cathode (ip_digit, cathode);
input [3:0] ip_digit;
output reg [6:0] cathode;

always @(*) begin
    case(ip_digit)
        4'd0 : cathode = 7'b0000001;
        4'd1 : cathode = 7'b1001111;
        4'd2 : cathode = 7'b0010010;
        4'd3 : cathode = 7'b0000110;
        4'd4 : cathode = 7'b1001100;
        4'd5 : cathode = 7'b0100100;
        4'd6 : cathode = 7'b0100000;
        4'd7 : cathode = 7'b0001111;
        4'd8 : cathode = 7'b0000000;
        4'd9 : cathode = 7'b0000100;
        4'd10: cathode = 7'b1000010;    // for the letter 'd'
        4'd11: cathode = 7'b1100010;    // for the letter 'o'
        4'd12: cathode = 7'b1101010;    // for the letter 'n'
        4'd13: cathode = 7'b1110010;    // for the letter 'c' (as e is not possible)
        
    endcase
end
endmodule

// Instantiation of Top level module
module SevenSegment_Control(clk, reset, ip_BCD, anode_control, cathode_control);
input clk, reset;
input [19:0] ip_BCD;
output [7:0] anode_control;     // defines which 7 segment display is On
output [6:0] cathode_control;   // defines a,b,c,d,e,f,g

wire clock_10kHz;
wire [2:0] refreshCount;
wire [3:0] Digit_sel;

clk_divider ck (.clk(clk), .reset(reset), .clk_10kHz(clock_10kHz));

refresh_counter rC (.clk_10kHz(clock_10kHz), .reset(reset), .refresh_count(refreshCount));

anode_Control aC (.refreshCount(refreshCount), .anodeControl(anode_control));

BCD_Control bC(.ones(ip_BCD[3:0]), .tens(ip_BCD[7:4]), .hundreds(ip_BCD[11:8]), .thousands(ip_BCD[15:12]),
                   .ten_thousands(ip_BCD[19:16]), .refreshCount(refreshCount), .Op_Digit(Digit_sel));
                   
BCD_to_Cathode cath_ctrl (.ip_digit(Digit_sel), .cathode(cathode_control));
endmodule

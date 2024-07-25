`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 15.05.2024 18:39:45
// Design Name: 
// Module Name: Voting_Machine
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


// moudule for verifying if a valid vote or not : button pressed > or = 1sec is a valid vote

module buttonControl(clk, reset, candidate, vote_given, valid_vote);
input clk, reset;
input candidate, vote_given;
output reg valid_vote;

reg [30:0] counter;

// can use 27 bit counter but greater also no problem (so using 31 bit counter)

always @(posedge clk)
begin
    if(reset)
        counter <= 31'd0;
    else begin
        if((candidate && vote_given) && counter < 100000001)
            counter <= counter + 1;
        else if(!vote_given | !candidate)
            counter <= 31'd0;
    end   
end


// requirement: I need only one "valid_vote pulse" if the button if pressed for >=1 sec
//
always @(posedge clk)
begin
    if(reset)
        valid_vote <= 1'b0;
    else if(counter == 100000000)           // counter will be 100000000 for only 1 clk cycle (coz ending is 100000001)
        valid_vote <= 1'b1;
    else
        valid_vote <= 1'b0;
end
endmodule


// Instatiating the Vote Logger module: 
module Vote_Counter(clk, reset, mode, cand1_vote_valid, cand2_vote_valid, cand3_vote_valid, cand4_vote_valid, 
                                cand5_vote_valid, cand6_vote_valid, cand7_vote_valid, cand8_vote_valid,
                                cand1_total, cand2_total, cand3_total, cand4_total, cand5_total, cand6_total,
                                cand7_total, cand8_total);

input clk, reset;
input [4:0] mode;           // when mode != 5'd25 only the vote logger should count
input cand1_vote_valid;
input cand2_vote_valid;
input cand3_vote_valid;
input cand4_vote_valid;
input cand5_vote_valid;
input cand6_vote_valid;
input cand7_vote_valid;
input cand8_vote_valid;

// goal : ability to count a total of 9999 votes per individual candidate

output reg [13:0] cand1_total;
output reg [13:0] cand2_total;
output reg [13:0] cand3_total;
output reg [13:0] cand4_total;
output reg [13:0] cand5_total;
output reg [13:0] cand6_total;
output reg [13:0] cand7_total;
output reg [13:0] cand8_total;


always @(posedge clk)
begin
    if(reset) begin
        cand1_total <= 14'd0;
        cand2_total <= 14'd0;
        cand3_total <= 14'd0;
        cand4_total <= 14'd0;
        cand5_total <= 14'd0;
        cand6_total <= 14'd0;
        cand7_total <= 14'd0;
        cand8_total <= 14'd0;
    end
    
    else begin
        if(cand1_vote_valid && mode != 5'd25)
            cand1_total <= cand1_total + 1;
        else if(cand2_vote_valid && mode != 5'd25)
            cand2_total <= cand2_total + 1;
        else if(cand3_vote_valid && mode != 5'd25)
            cand3_total <= cand3_total + 1;
        else if(cand4_vote_valid && mode != 5'd25)
            cand4_total <= cand4_total + 1;
        else if(cand5_vote_valid && mode != 5'd25)
            cand5_total <= cand5_total + 1;
        else if(cand6_vote_valid && mode != 5'd25)
            cand6_total <= cand6_total + 1;
        else if(cand7_vote_valid && mode != 5'd25)
            cand7_total <= cand7_total + 1;
        else if(cand8_vote_valid && mode != 5'd25)
            cand8_total <= cand8_total + 1;
    end  
end
endmodule

// Instatiating the mode control module : as a password (to vote/ to check total votes casted for each candidate)
module modeControl(clk, reset, mode, valid_vote, cand1, cand2, cand3, cand4, 
                   cand5, cand6, cand7, cand8, cand1_total, cand2_total, cand3_total, 
                   cand4_total, cand5_total, cand6_total, cand7_total, cand8_total, leds);
input clk, reset;
input cand1, cand2, cand3, cand4, cand5, cand6, cand7, cand8;
input [4:0] mode;
input valid_vote;
input [9:0] cand1_total, cand2_total, cand3_total, cand4_total, 
            cand5_total, cand6_total, cand7_total, cand8_total;
output reg [19:0] leds;

reg [31:0] counter;

/* logic: valid_vote anyhow will be on for only 1 clk pulse, so for one successful vote, the leds should glow for 1s
          and then should be off. */ 
          
always @(posedge clk)
begin
    if(reset)
        counter <= 31'd0;
    else if(valid_vote)
        counter <= counter + 1;
    else if(counter != 0 && counter < 100000001)
        counter <= counter + 1;
    else
        counter <= 31'd0;
end

always @(posedge clk)
begin
    if(mode != 5'd25 && counter > 0)        // voting mode : mode == any other than 25
        leds <= 20'b00011010101111001101;
    else if(mode != 5'd25) 
        leds <= 20'd0;
    else if(mode == 5'd25) begin            // result mode: mode signal acting as password so that all cannot access
        if(cand1)
            leds <= cand1_total;
        else if(cand2)
            leds <= cand2_total;
        else if(cand3)
            leds <= cand3_total;
        else if(cand4)
            leds <= cand4_total;
        else if(cand5)
            leds <= cand5_total;
        else if(cand6)
            leds <= cand6_total;
        else if(cand7)
            leds <= cand7_total;
        else if(cand8)
            leds <= cand8_total;
    end   
end
endmodule

// Instantiating Top Level Module
module Voting_Machine(clk, reset, mode, cand1, cand2, cand3, cand4, cand5, cand6, cand7, cand8, 
                                        button, anode, cathode);
input clk, reset;
input [4:0] mode;
input cand1, cand2, cand3, cand4, cand5, cand6, cand7, cand8;
input button;
output [7:0] anode;
output [6:0] cathode;

wire [19:0] total_votes;

wire valid_vote1, valid_vote2, valid_vote3, valid_vote4, valid_vote5, valid_vote6, valid_vote7, valid_vote8;

// buttonControl logic for each candidate
buttonControl b1 (.clk(clk), .reset(reset), 
                  .candidate(cand1), .vote_given(button), .valid_vote(valid_vote1));
buttonControl b2 (.clk(clk), .reset(reset), 
                  .candidate(cand2), .vote_given(button), .valid_vote(valid_vote2));                 
buttonControl b3 (.clk(clk), .reset(reset), 
                  .candidate(cand3), .vote_given(button), .valid_vote(valid_vote3));
buttonControl b4 (.clk(clk), .reset(reset), 
                  .candidate(cand4), .vote_given(button), .valid_vote(valid_vote4));
buttonControl b5 (.clk(clk), .reset(reset), 
                  .candidate(cand5), .vote_given(button), .valid_vote(valid_vote5));
buttonControl b6 (.clk(clk), .reset(reset), 
                  .candidate(cand6), .vote_given(button), .valid_vote(valid_vote6));
buttonControl b7 (.clk(clk), .reset(reset), 
                  .candidate(cand7), .vote_given(button), .valid_vote(valid_vote7));                 
buttonControl b8 (.clk(clk), .reset(reset), 
                  .candidate(cand8), .vote_given(button), .valid_vote(valid_vote8));
                                    
// VoteLogger for all candidates
wire [13:0] cand1_total, cand2_total, cand3_total, cand4_total, 
           cand5_total, cand6_total, cand7_total, cand8_total;
           
           
Vote_Counter Vc (.clk(clk), .reset(reset), .mode(mode), .cand1_vote_valid(valid_vote1), .cand2_vote_valid(valid_vote2), 
                 .cand3_vote_valid(valid_vote3), .cand4_vote_valid(valid_vote4), .cand5_vote_valid(valid_vote5), 
                 .cand6_vote_valid(valid_vote6), .cand7_vote_valid(valid_vote7), .cand8_vote_valid(valid_vote8), 
                 .cand1_total(cand1_total), .cand2_total(cand2_total), .cand3_total(cand3_total), .cand4_total(cand4_total), 
                 .cand5_total(cand5_total), .cand6_total(cand6_total), .cand7_total(cand7_total), .cand8_total(cand8_total));

wire [19:0] cand1_BCD, cand2_BCD, cand3_BCD, cand4_BCD, cand5_BCD, cand6_BCD, cand7_BCD, cand8_BCD;
               
BinaryToBCD c1 (cand1_total, cand1_BCD);
BinaryToBCD c2 (cand2_total, cand2_BCD);
BinaryToBCD c3 (cand3_total, cand3_BCD);
BinaryToBCD c4 (cand4_total, cand4_BCD);
BinaryToBCD c5 (cand5_total, cand5_BCD);
BinaryToBCD c6 (cand6_total, cand6_BCD);
BinaryToBCD c7 (cand7_total, cand7_BCD);
BinaryToBCD c8 (cand8_total, cand8_BCD);

wire valid_vote_x = valid_vote1 | valid_vote2 | valid_vote3 | valid_vote4;
wire valid_vote_y = valid_vote5 | valid_vote6 | valid_vote7 | valid_vote8;

wire valid_vote = valid_vote_x | valid_vote_y;

modeControl m (.clk(clk), .reset(reset), .mode(mode), .valid_vote(valid_vote), .cand1(cand1), .cand2(cand2),
               .cand3(cand3), .cand4(cand4), .cand5(cand5), .cand6(cand6), .cand7(cand7), .cand8(cand8), 
               .cand1_total(cand1_BCD), .cand2_total(cand2_BCD), .cand3_total(cand3_BCD), 
               .cand4_total(cand4_BCD), .cand5_total(cand5_BCD), .cand6_total(cand6_BCD), 
               .cand7_total(cand7_BCD), .cand8_total(cand8_BCD), .leds(total_votes));
               
// Now interfacing the seven segment display with the total number of votes

SevenSegment_Control s_ctrl (.clk(clk), .reset(reset), .ip_BCD(total_votes),
                             .anode_control(anode), .cathode_control(cathode));
                 
endmodule


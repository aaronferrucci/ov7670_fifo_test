////////////////////////////////////////////////////////////////////////////
// Copyright 2019 Intel Corporation. 
//
// This reference design file is subject licensed to you by the terms and 
// conditions of the applicable License Terms and Conditions for Hardware 
// Reference Designs and/or Design Examples (either as signed by you or 
// found at https://www.altera.com/common/legal/leg-license_agreement.html ).  
//
// As stated in the license, you agree to only use this reference design 
// solely in conjunction with Intel FPGAs or Intel CPLDs.  
//
// THE REFERENCE DESIGN IS PROVIDED "AS IS" WITHOUT ANY EXPRESS OR IMPLIED
// WARRANTY OF ANY KIND INCLUDING WARRANTIES OF MERCHANTABILITY, 
// NONINFRINGEMENT, OR FITNESS FOR A PARTICULAR PURPOSE. Intel does not 
// warrant or assume responsibility for the accuracy or completeness of any
// information, links or other items within the Reference Design and any 
// accompanying materials.
//
// In the event that you do not agree with such terms and conditions, do not
// use the reference design file.
////////////////////////////////////////////////////////////////////////////

`default_nettype none
module ov7670_test_top(
  input wire MAX10_CLK1_50,

  output wire [7:0] HEX0,
  output wire [7:0] HEX1,
  output wire [7:0] HEX2,
  output wire [7:0] HEX3,
  output wire [7:0] HEX4,
  output wire [7:0] HEX5,
  output wire [9:0]LEDR
);

  logic [(10 + 8*6) - 1:0] count;
  always @(posedge MAX10_CLK1_50)
    count <= count + 1'b1;
	  
  // LEDR is active high; HEX digits are active low. 
  localparam MASK = {10'b0, { 8*6 {1'b1}}};
  assign {LEDR, HEX0, HEX1, HEX2, HEX3, HEX4, HEX5} = count ^ MASK;
endmodule

`default_nettype wire

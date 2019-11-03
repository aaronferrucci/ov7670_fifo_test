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
module ov7670_fifo_test_top(
  input wire MAX10_CLK1_50,

  input wire cam_sioc,      // GPIO_12
  input wire cam_siod,      // GPIO_35
  input wire cam_vsync,     // GPIO_0
  input wire cam_href,      // GPIO_33
  input wire cam_str,       // GPIO_28

  input wire [7:0] cam_data, // GPIO_16,GPIO_31,GPIO_18,GPIO_27,GPIO_20,GPIO_25,GPIO_24,GPIO_23
  output wire cam_reset_n,   // GPIO_26
  output wire cam_pwdn,      // GPIO_21
  output wire cam_rclk,      // GPIO_19
  output wire cam_we,        // GPIO_30
  output wire cam_oe_n,      // GPIO_15
  output wire cam_wrst_n,    // GPIO_32
  output wire cam_rrst_n,    // GPIO_13

  // GPIO is broken out as individual bits, for individual control.
  input GPIO_1,
  input GPIO_2,
  input GPIO_3,
  input GPIO_4,
  input GPIO_5,
  input GPIO_6,
  input GPIO_7,
  input GPIO_8,
  input GPIO_9,
  input GPIO_10,
  input GPIO_11,
  input GPIO_14,
  input GPIO_17,
  input GPIO_22,
  input GPIO_29,
  input GPIO_34,

  output wire [7:0] HEX0,
  output wire [7:0] HEX1,
  output wire [7:0] HEX2,
  output wire [7:0] HEX3,
  output wire [7:0] HEX4,
  output wire [7:0] HEX5,
  output wire [9:0]LEDR
);

  localparam COUNT_LIMIT = 25_000_000;
  localparam COUNTER_W = $clog2(COUNT_LIMIT);
  logic [COUNTER_W - 1:0] count;
  logic blip = '0;

  logic clk25;
  logic locked;
  logic reset_n;
  pll25 pll25_inst(
    .inclk0 (MAX10_CLK1_50),
    .c0 (clk25),
    .locked (locked)
  );

  alt_reset_delay pll_delay(
    .clk (clk25),
    .ready_in (locked),
    .ready_out (reset_n)
  );

  always @(posedge clk25 or negedge reset_n) begin
    if (~reset_n) begin
      count <= '0;
      blip <= '0;
    end
    else begin
      if (count >= COUNT_LIMIT - 1) begin
        count <= '0;
        blip <= ~blip;
      end
      else begin
        count <= count + 1'b1;
      end
    end
  end
	  
  assign cam_reset_n = reset_n;
  assign cam_pwdn = ~reset_n; 
  assign cam_rclk = clk25;
  assign cam_we = 1'b1;

  assign cam_oe_n = 1'b0;
  assign cam_wrst_n = 1'b1;
  assign cam_rrst_n = 1'b1;

  // 7-segment map
  // +--0--+
  // |	   |
  // 5	   1
  // |	   |
  // +--6--+
  // |	   |
  // 4 	   2
  // |	   |
  // +--3--+  7

  // HEX digits are active low
  localparam MASK = {10'b0, { 8*6 {1'b1}}};
  assign HEX5 = ~8'h5C; // o
  assign HEX4 = ~8'h1C; // uh... v
  assign HEX3 = ~8'h07; // 7
  assign HEX2 = ~8'h7D; // 6
  assign HEX1 = ~8'h07; // 7
  assign HEX0 = ~(8'h3f | {blip, 7'b0}); // 0

  // LEDR is active high
  assign LEDR = {cam_data[7:0], cam_href, cam_vsync};
endmodule

`default_nettype wire

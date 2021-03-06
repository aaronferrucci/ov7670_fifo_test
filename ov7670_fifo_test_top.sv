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
  output reg cam_wrst_n,     // GPIO_32
  output reg cam_rrst_n,     // GPIO_13

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

  localparam CAM_RESET_W = 5;
  reg [CAM_RESET_W-1:0] cam_wrst_n_counter;
  always @(posedge clk25 or negedge reset_n) begin
    if (~reset_n) begin
      cam_wrst_n <= 1'b0;
      cam_wrst_n_counter <= '0;
    end
    else begin
      if (sync_vsync) begin
        if (~cam_wrst_n_counter[CAM_RESET_W-1]) begin
          // reset, and increment until counter MSB is set
          cam_wrst_n <= 1'b0;
          cam_wrst_n_counter <= cam_wrst_n_counter + 1'b1;
        end
        else begin
          // count reached set MSB, release reset
          cam_wrst_n <= 1'b1;
        end
      end
      else begin
        // clear counter for next vsync assertion
        cam_wrst_n_counter <= '0;
      end
    end
  end

  reg d1_sync_href;
  wire sync_href_f = d1_sync_href & ~sync_href; // falling edge
  always @(posedge clk25 or negedge reset_n) begin
    if (~reset_n) begin
      cam_rrst_n <= '0;
      d1_sync_href <= '0;
    end
    else begin
      d1_sync_href <= sync_href;
      if (~wrote && sync_vsync)
        cam_rrst_n <= '0;
      if (sync_href_f)
        cam_rrst_n <= '1;
    end
  end

  reg [15:0] addr;
  reg wren;
  reg wrote;
  always @(posedge clk25 or negedge reset_n) begin
    if (~reset_n) begin
      addr <= '0;
      wren <= '0;
      wrote <= '0;
    end
    else begin
      if (wren)
        addr <= addr + 1'b1;
      if (&addr) begin
        wren <= '0;
      end
      else if (~wrote && sync_href_f) begin
        wren <= '1;
        wrote <= '1;
      end
    end
  end

  wire [7:0] pixel_data;
  pixel_buffer the_pixels(
    .address (addr),
    .clock (clk25),
    .data (cam_data),
    .wren (wren),
    .q (pixel_data)
  );

  // synchronize camera sync outputs into this clock domain
  localparam SYNC_STAGES = 2;
  wire sync_vsync, sync_href;
  reg [SYNC_STAGES-1:0] vsync_stage;
  reg [SYNC_STAGES-1:0] href_stage;

  always @(posedge clk25 or negedge reset_n) begin
    if (~reset_n) begin
      vsync_stage <= '0;
      href_stage <= '0;
    end
    else begin
      vsync_stage <= {vsync_stage[SYNC_STAGES-2:0], cam_vsync};
      href_stage <= {href_stage[SYNC_STAGES-2:0], cam_href};
    end
  end

  assign sync_vsync = vsync_stage[SYNC_STAGES-1];
  assign sync_href = href_stage[SYNC_STAGES-1];

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
  assign LEDR = {cam_data[7:0], sync_href, sync_vsync};
endmodule

`default_nettype wire

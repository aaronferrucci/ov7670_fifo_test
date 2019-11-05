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

`timescale 1 ps / 1 ps

// DESCRIPTION
//
// This is a more elaborate version of aclr_filter, typically used for 
// bringing up SERDES pins or PLLs. When the input ready condition is 
// not met the output is immediately driven to not ready. When the input
// ready becomes true the output will become ready after a programmable delay.
//

// CONFIDENCE
// This is used very liberally in Altera test and demo designs
//

module alt_reset_delay #(
	parameter CNTR_BITS = 16
)
(
	input clk,
	input ready_in,
	output ready_out
);

reg [2:0] rs_meta = 3'b0 /* synthesis preserve dont_replicate */
/* synthesis ALTERA_ATTRIBUTE = "-name SDC_STATEMENT \"set_false_path -from [get_fanins -async *reset_delay*rs_meta\[*\]] -to [get_keepers *reset_delay*rs_meta\[*\]]\" " */;

always @(posedge clk or negedge ready_in) begin
	if (!ready_in) rs_meta <= 3'b000;
	else rs_meta <= {rs_meta[1:0],1'b1};
end
wire ready_sync = rs_meta[2];

reg [CNTR_BITS-1:0] cntr = {CNTR_BITS{1'b0}} /* synthesis preserve */;
assign ready_out = cntr[CNTR_BITS-1];
always @(posedge clk or negedge ready_sync) begin
	if (!ready_sync) cntr <= {CNTR_BITS{1'b0}};
	else if (!ready_out) cntr <= cntr + 1'b1;
end

endmodule


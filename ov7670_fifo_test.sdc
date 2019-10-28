############################################################################
# Copyright 2019 Intel Corporation. 
#
# This reference design file is subject licensed to you by the terms and 
# conditions of the applicable License Terms and Conditions for Hardware 
# Reference Designs and/or Design Examples (either as signed by you or 
# found at https://www.altera.com/common/legal/leg-license_agreement.html ).  
#
# As stated in the license, you agree to only use this reference design 
# solely in conjunction with Intel FPGAs or Intel CPLDs.  
#
# THE REFERENCE DESIGN IS PROVIDED "AS IS" WITHOUT ANY EXPRESS OR IMPLIED
# WARRANTY OF ANY KIND INCLUDING WARRANTIES OF MERCHANTABILITY, 
# NONINFRINGEMENT, OR FITNESS FOR A PARTICULAR PURPOSE. Intel does not 
# warrant or assume responsibility for the accuracy or completeness of any
# information, links or other items within the Reference Design and any 
# accompanying materials.
#
# In the event that you do not agree with such terms and conditions, do not
# use the reference design file.
############################################################################

#**************************************************************
# Create Clock
#**************************************************************
create_clock -period "50.0 MHz" [get_ports MAX10_CLK1_50]

#**************************************************************
# Create Generated Clock
#**************************************************************
derive_pll_clocks



#**************************************************************
# Set Clock Latency
#**************************************************************



#**************************************************************
# Set Clock Uncertainty
#**************************************************************
derive_clock_uncertainty



#**************************************************************
# Set Input Delay
#**************************************************************



#**************************************************************
# Set Output Delay
#**************************************************************



#**************************************************************
# Set Clock Groups
#**************************************************************



#**************************************************************
# Set False Path
#**************************************************************



#**************************************************************
# Set Multicycle Path
#**************************************************************



#**************************************************************
# Set Maximum Delay
#**************************************************************



#**************************************************************
# Set Minimum Delay
#**************************************************************



#**************************************************************
# Set Input Transition
#**************************************************************



#**************************************************************
# Set Load
#**************************************************************




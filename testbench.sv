`timescale 1ns / 1ps
`include "uvm_macros.svh"
import uvm_pkg::*;
`include "multiplicador_32_bits_FP_IEEE.sv"
`include "interface.sv"
`include "sequence_item.sv"
`include "sequence.sv"
`include "monitor.sv"
`include "driver.sv"
`include "scoreboard.sv"
`include "agent.sv"
`include "ambiente.sv"
`include "test.sv"

module tb;
  	import uvm_pkg::*;
  	reg clk;

  	always #10 clk =~ clk;
  	des_if _if(clk);

  	top DUT (.clk(clk),
               		.fp_X(_if.in1),
			.in2(_if.in2),
               		.out(_if.out));
  	initial begin
    		clk <= 0;
    		uvm_config_db#(virtual des_if)::set(null,"uvm_test_top","des_vif",_if);
    		run_test("base_test");
  	end
endmodule

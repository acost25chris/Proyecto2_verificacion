//`timescale 1ns/1ps
`include "uvm_macros.svh"
import uvm_pkg::*;
`include "multiplicador_32_bits_FP_IEEE.sv"
`include "interface.sv"
`include "sequence_item.sv"
`include "sequencer.sv"
`include "monitor.sv"
`include "driver.sv"
`include "scoreboard.sv"
`include "agente.sv"
`include "ambiente.sv"
`include "test.sv"

module tb;
  	reg clk;

  	always #10 clk =~ clk;
  	des_if _if(clk);

  	top DUT (.clk(clk),
			.r_mode(_if.r_mode),
               		.fp_X(_if.fp_X),
			.fp_Y(_if.fp_Y),
               		.fp_Z(_if.fp_Z),
			.ovrf(_if.ovrf),
			.udrf(_if.udrf));
  	initial begin
    		clk <= 0;
    		uvm_config_db#(virtual des_if)::set(null,"uvm_test_top","des_vif",_if);
    		run_test("base_test");
  	end
endmodule

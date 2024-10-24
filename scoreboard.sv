class scoreboard extends uvm_scoreboard;
  	`uvm_component_utils(scoreboard)

  	function new(string name="scoreboard", uvm_component parent=null);
    		super.new(name, parent);
 	endfunction

  	bit [8:0] expected_sum;
  	uvm_analysis_imp #(Item, scoreboard) m_analysis_imp;

  	virtual function void build_phase(uvm_phase phase);
    		super.build_phase(phase);
    		m_analysis_imp = new("m_analysis_imp", this);
  	endfunction

  	virtual function void write(Item item);
		expected_sum <= item.in1 + item.in2;
    		`uvm_info("SCBD", $sformatf("in1=%0d in2=%0d DUT_out=%0d expected_out=%0d", item.in1, item.in2, item.out, expected_sum), UVM_LOW)

    		if (item.out != expected_sum) begin
      			`uvm_error("SCBD", $sformatf("ERROR: DUT=%0d expected=%0d", item.out, expected_sum))
    		end else begin
      			`uvm_info("SCBD", $sformatf("PASS: DUT=%0d expected=%0d", item.out, expected_sum), UVM_HIGH)
    		end
  	endfunction

endclass
    


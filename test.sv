class base_test extends uvm_test;
  	`uvm_component_utils(base_test)
  
  	function new(string name = "base_test",uvm_component parent=null);
    		super.new(name,parent);
  	endfunction
  
  	env e0;
  	num_sum_seq  seq;
  	virtual des_if  vif;

  	virtual function void build_phase(uvm_phase phase);
    		super.build_phase(phase);

    		e0 = env::type_id::create("e0",this);

    		if(!uvm_config_db#(virtual des_if)::get(this, "", "des_vif",vif))
      			`uvm_fatal("TEST","Did not get vif")
    		uvm_config_db#(virtual des_if)::set(this, "e0.a0.*","des_vif",vif);
    

    		seq = num_sum_seq::type_id::create("seq");
    		seq.randomize();
  	endfunction

  	virtual task run_phase(uvm_phase phase);
    		phase.raise_objection(this);
    		apply_reset();
    		seq.start(e0.a0.s0);
    		#200;
    		phase.drop_objection(this);
  	endtask

  	virtual task apply_reset();
    		vif.rstn <= 1;
    		vif.in1 <= 0;
		vif.in2 <= 0;
    		repeat(5) @(posedge vif.clk);
    		vif.rstn <=0;
    		repeat(10) @(posedge vif.clk);
  	endtask
endclass
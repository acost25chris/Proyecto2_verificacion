class sequencer extends uvm_driver #(Item);
 	`uvm_component_utils(driver)
  	
	function new(string name= "driver", uvm_component parent = null);
    		super.new(name,parent);
  	endfunction

 	 virtual adder_if vif;
		
  	virtual function void build_phase(uvm_phase phase);
    		super.build_phase(phase);
    			if(!uvm_config_db#(virtual des_if)::get(this,"","des_vif", vif))
      				`uvm_fatal("DRV", "Could not get vif");
  		endfunction

  	virtual task run_phase(uvm_phase phase);
    		super.run_phase(phase);
	    	forever begin
	      		Item item;
	      		`uvm_info("DRV", $sformatf("Wait for item from sequencer"), UVM_HIGH);
	      		seq_item_port.get_next_item(item);
	      		drive_item(m_item);
	      		seq_item_port.item_done();
	    	end
	endtask


  	virtual task drive_item(Item item);
    		@(vif.cb);
      			vif.cb.in <= item.in;
  	endtask
endclass
       


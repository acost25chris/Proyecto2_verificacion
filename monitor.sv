class monitor extends uvm_monitor;
	`uvm_component_utils(monitor)
  	function new(string name="monitor",uvm_component parent=null);
    		super.new(name,parent);
  	endfunction

  	uvm_analysis_port #(Item) mon_analysis_port;
  	virtual des_if vif;

  	virtual function void build_phase(uvm_phase phase);
    		super.build_phase(phase);
    		if(!uvm_config_db#(virtual des_if)::get(this,"","des_vif",vif))
      			`uvm_fatal("MON","Could not get vif")
    			mon_analysis_port = new("mon_analysis_port", this);
 		endfunction

  	virtual task run_phase(uvm_phase phase);
    		super.run_phase(phase);
    		forever begin
      		@(vif.cb);
        		if(!vif.rstn) begin
		  		Item item = Item::type_id::create("item");
		  		item.in1 = vif.in1;
				item.in2 = vif.in2;
		  		item.out = vif.cb.out;
		  		mon_analysis_port.write(item);
		  		`uvm_info("MON",$sformatf("SAW item %s", item.convert2str()),UVM_HIGH);
        		end
    		end
  	endtask
endclass

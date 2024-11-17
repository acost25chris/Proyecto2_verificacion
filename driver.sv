class driver extends uvm_driver #(Item);
	`uvm_component_utils(driver)
	int count;
	function new(string name= "driver", uvm_component parent = null);
		super.new(name,parent);
	endfunction

	virtual des_if vif;

	virtual function void build_phase(uvm_phase phase);
		  super.build_phase(phase);
		  if(!uvm_config_db#(virtual des_if)::get(this,"","des_vif", vif))
		  	`uvm_fatal("DRV", "Could not get vif");
	endfunction

	virtual task run_phase(uvm_phase phase);
		  super.run_phase(phase);
		  forever begin
			    Item m_item;
			    `uvm_info("DRV", $sformatf("Wait for item from sequencer"), UVM_HIGH);
			    seq_item_port.get_next_item(m_item);
			    drive_item(m_item);
			    seq_item_port.item_done();
		  end
	endtask


	virtual task drive_item(Item m_item);

		//asserciones para comprobar que los datos enviados sean validos y no tenga un estado indefinido
			assert(m_item.fp_X[31:0] !== 'x)
			else `uvm_error("DRV", "fp_X value is undefined");
			assert(m_item.fp_Y[31:0] !== 'x)
			else `uvm_error("DRV", "fp_y value is undefined");
			assert(m_item.r_mode[2:0] !== 'x)
			else `uvm_error("DRV", "r_mode value is undefined");
		//--------------------------------------------------------------------------------------------

		count = 0;
		while(count < m_item.delay)begin
	    		count = count+1;
			if(count == m_item.delay)begin // Revisa hasta que el contador "count" sea igual al delay en m_item
				@(vif.cb);
	      				vif.cb.fp_Y <= m_item.fp_Y;
					vif.cb.fp_X <= m_item.fp_X;
					vif.cb.r_mode <= m_item.r_mode;
			end
		end
	  endtask
endclass


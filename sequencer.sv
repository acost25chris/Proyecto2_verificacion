class gen_item_seq extends uvm_sequence;
  	`uvm_object_utils(gen_item_seq);
  
  	function new(string name="gen_item_seq");
    		super.new(name);
  	endfunction


  	rand int num;

  	constraint c1{soft num inside {[10:30]};}

  	virtual task body();
		//X transacciones randome, incluyendo numeros maximos y minimos
		Item m_item = Item::type_id::create("m_item");
    		for(int i = 0; i<num;i++)begin
      			start_item(m_item);
      			m_item.randomize();
      			`uvm_info("SEQ",$sformatf("Generate new item: %s", m_item.convert2str()),UVM_HIGH);
      			finish_item(m_item);
    		end
    		`uvm_info("SEQ",$sformatf("Done generation of %0d items", num),UVM_LOW);
		
		// Multiplicador es infinito
      		start_item(m_item);
      		m_item.randomize();
		m_item.fp_Y = {1'b1, 8'hFF, 23'h0};
      		`uvm_info("SEQ",$sformatf("Generate new item: %s", m_item.convert2str()),UVM_HIGH);
      		finish_item(m_item);

		// Multiplicador es cero
      		start_item(m_item);
      		m_item.randomize();
		m_item.fp_Y = {1'b1, 8'h00, 23'h0};
      		`uvm_info("SEQ",$sformatf("Generate new item: %s", m_item.convert2str()),UVM_HIGH);
      		finish_item(m_item);

		// 0x0 
		start_item(m_item);
      		m_item.randomize();
		m_item.fp_X = {1'b1, 8'h00, 23'h0};
		m_item.fp_Y = {1'b1, 8'h00, 23'h0};
      		`uvm_info("SEQ",$sformatf("Generate new item: %s", m_item.convert2str()),UVM_HIGH);
      		finish_item(m_item);

		// Mltiplicacion invalida ( Inf x Inf )
		start_item(m_item);
      		m_item.randomize();
		m_item.fp_X = {1'b1, 8'hFF, 23'h0};
		m_item.fp_Y = {1'b1, 8'hFF, 23'h0};
      		`uvm_info("SEQ",$sformatf("Generate new item: %s", m_item.convert2str()),UVM_HIGH);
      		finish_item(m_item);
  	endtask

endclass
       


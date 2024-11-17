class gen_item_seq extends uvm_sequence;
  	`uvm_object_utils(gen_item_seq);
  
  	function new(string name="gen_item_seq");
    		super.new(name);
  	endfunction


  	rand int num;

  	constraint c1{soft num inside {[30:60]};} // Constraint para evitar un numero muy grande o pequeno de transacciones

  	virtual task body();
		// num transacciones randome
		Item m_item = Item::type_id::create("m_item");
    		for(int i = 0; i<num;i++)begin
      			start_item(m_item);
      			m_item.randomize();
      			`uvm_info("SEQ",$sformatf("Generate new item: %s", m_item.convert2str()),UVM_HIGH);
      			finish_item(m_item);
    		end
    		`uvm_info("SEQ",$sformatf("Done generation of %0d items", num),UVM_LOW);
		
		// transaccion: Multiplicador es infinito
		$display("X = inf");
      		start_item(m_item);
      		m_item.randomize();
		m_item.fp_Y = {1'b1, 8'hFF, 23'h0};
      		`uvm_info("SEQ",$sformatf("Generate new item: %s", m_item.convert2str()),UVM_HIGH);
      		finish_item(m_item);

		// transaccion: Multiplicador es cero
		$display("X = 0");
      		start_item(m_item);
      		m_item.randomize();
		m_item.fp_Y = {1'b1, 8'h00, 23'h0};
      		`uvm_info("SEQ",$sformatf("Generate new item: %s", m_item.convert2str()),UVM_HIGH);
      		finish_item(m_item);

		// transaccion: 0x0 
		$display("0 x 0");
		start_item(m_item);
      		m_item.randomize();
		m_item.fp_X = {1'b1, 8'h00, 23'h0};
		m_item.fp_Y = {1'b1, 8'h00, 23'h0};
      		`uvm_info("SEQ",$sformatf("Generate new item: %s", m_item.convert2str()),UVM_HIGH);
      		finish_item(m_item);

		// transaccion: Mltiplicacion invalida ( Inf x Inf )
		$display("Inf x inf");
		start_item(m_item);
      		m_item.randomize();
		m_item.fp_X = {1'b1, 8'hFF, 23'h0};
		m_item.fp_Y = {1'b1, 8'hFF, 23'h0};
      		`uvm_info("SEQ",$sformatf("Generate new item: %s", m_item.convert2str()),UVM_HIGH);
      		finish_item(m_item);

      		// transaccion: NaN
		$display("NaN");
		start_item(m_item);
      		m_item.randomize();
		m_item.fp_X = {1'b1, 8'hFF, 23'h0};
		m_item.fp_Y = {1'b1, 8'h00, 23'h0};
      		`uvm_info("SEQ",$sformatf("Generate new item: %s", m_item.convert2str()),UVM_HIGH);
      		finish_item(m_item);

		start_item(m_item);
      		m_item.randomize();
		m_item.fp_X = {1'b1, 8'h00, 23'h0};
		m_item.fp_Y = {1'b1, 8'hFF, 23'h0};
      		`uvm_info("SEQ",$sformatf("Generate new item: %s", m_item.convert2str()),UVM_HIGH);
      		finish_item(m_item);
  	endtask

endclass
       


class Item extends uvm_sequence_item;
  	rand bit [7:0] in1, in2;
  	bit [8:0] out;

	`uvm_object_utils_begin(Item)
		`uvm_field_int(in1,UVM_DEFAULT)
		`uvm_field_int(in2,UVM_DEFAULT)
		`uvm_field_int(out,UVM_DEFAULT)
	`uvm_object_utils_end

  	function new(string name = "Item");
    		super.new(name);
  	endfunction

	virtual function string convert2str();
    		return $sformatf("in1=%0d, in2=%0d, out=%0d",in1, in2, out);
  	endfunction
endclass


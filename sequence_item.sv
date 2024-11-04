class Item extends uvm_sequence_item;
	bit [2:0] r_mode;
  	randc bit [31:0] fp_X, fp_Y;
  	bit [31:0] fp_Z;
	bit [31:0] fp_esperado;
	bit ovrf, udrf;

	`uvm_object_utils_begin(Item)
		`uvm_field_int(r_mode,UVM_DEFAULT)
		`uvm_field_int(fp_X,UVM_DEFAULT)
		`uvm_field_int(fp_Y,UVM_DEFAULT)
		`uvm_field_int(fp_Z,UVM_DEFAULT)
		`uvm_field_int(ovrf,UVM_DEFAULT)
		`uvm_field_int(udrf,UVM_DEFAULT)
	`uvm_object_utils_end

	//constraint

  	function new(string name = "Item");
    		super.new(name);
  	endfunction

	virtual function string convert2str();
    		return $sformatf("in1=%0d, in2=%0d, out=%0d",fp_X, fp_Y, fp_Z);
  	endfunction
endclass


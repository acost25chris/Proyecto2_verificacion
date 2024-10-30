class scoreboard extends uvm_scoreboard;
  	`uvm_component_utils(scoreboard)
	// Descomposición de los operandos en signo, exponente y mantisa
	bit sign_X, sign_Y, sign_result;
	logic [7:0]  exp_X, exp_Y, exp_result;
	logic [23:0] mantissa_X, mantissa_Y;
	logic [44:0] mantissa_product;
	logic [23:0] mantissa_final;
	bit guard, round, sticky;
	bit [31:0] expecd_result;

  	function new(string name="scoreboard", uvm_component parent=null);
    		super.new(name, parent);
 	endfunction

  	uvm_analysis_imp #(Item, scoreboard) m_analysis_imp;

  	virtual function void build_phase(uvm_phase phase);
    		super.build_phase(phase);
    		m_analysis_imp = new("m_analysis_imp", this);
  	endfunction

  	virtual function void write(Item item);
		expected_mul(item);
    		`uvm_info("SCBD", $sformatf("in1=%0d in2=%0d DUT_out=%0d round mode=%0d", item.fp_X, item.fp_Y, item.fp_Z, item.r_mode), UVM_LOW)

    		if (item.fp_Z != expecd_result) begin
      			`uvm_error("SCBD", $sformatf("ERROR: DUT=%0d expected=%0d", item.fp_Z, expecd_result))
    		end else begin
			$display("Pasoooooooooooo");
      			`uvm_info("SCBD", $sformatf("PASS: DUT=%0d expected=%0d", item.fp_Z, expecd_result), UVM_HIGH)
    		end
  	endfunction
	
	virtual function void expected_mul(Item item);

		// Extraer el signo, el exponente y la mantisa de los operandos
		sign_X = item.fp_X[31];
		sign_Y = item.fp_Y[31];
		exp_X = item.fp_X[30:23]; 
		exp_Y = item.fp_Y[30:23];
		mantissa_X = {1'b1, item.fp_X[22:0]}; // Añadir bit implícito 1 en la mantisa
		mantissa_Y = {1'b1, item.fp_Y[22:0]};

		// Calcular el signo del resultado (XOR entre los signos)
		sign_result = sign_X ^ sign_Y;

		// Sumar los exponentes y ajustarlos
		exp_result = (exp_X + exp_Y) - 127; 

		// Multiplicar las mantisas usando una multiplicación extendida de 24x24 bits
		mantissa_product = mantissa_X * mantissa_Y;

		// Normalización de la mantisa
		//if (mantissa_product[47] == 1) begin
			//mantissa_product = mantissa_product >> 1; // Desplazar a la derecha
			//exp_result = exp_result + 1; // Ajustar el exponente
		//end

		// Extraer los bits de redondeo (guard, round y sticky)
		round = mantissa_product[24];
		guard = mantissa_product[25];
		sticky = mantissa_product[26];

		// Aplicar el redondeo según el modo seleccionado
		case (item.r_mode)
			3'b000: begin // Redondeo al par más cercano (round to nearest, ties to even)
		      		if (round==0) begin
					mantissa_final = mantissa_product[23:0];
		      		end else begin
					if(round && sticky && guard) begin
						mantissa_final = mantissa_product[23:0] + 1;
					end else begin
						mantissa_final = mantissa_product[23:0];
					end
				end
			end
		      
		    	3'b001: begin // Redondeo hacia cero (round towards zero)
		      		mantissa_final = mantissa_product[23:0];
			end
		    
		    	3'b010: begin // Redondeo hacia -8 (round towards -infinity)
		      		if (sign_result == 1) begin
					mantissa_final = mantissa_product[23:0] + 1;
		      		end else begin
					mantissa_final = mantissa_product[23:0];
				end
			end
		    
		    	3'b011: begin // Redondeo hacia +8 (round towards +infinity)
		    		if (sign_result == 0) begin
					mantissa_final = mantissa_product[23:0] + 1;
		      		end else begin
					mantissa_final = mantissa_product[23:0];
				end
			end

			3'b100: begin
				if (round == 1) begin
        				mantissa_final = mantissa_product[23:0] + 1;
      				end else begin
        				mantissa_final = mantissa_product[23:0];
				end
			end
		    
		   	default: begin // Si no se especifica, usar redondeo al par más cercano
				mantissa_final = mantissa_product[23:0];
			end
		endcase

		  // Empaquetar el resultado final en IEEE-754
		  expecd_result = {sign_result, exp_result[7:0], mantissa_final};

	endfunction

endclass
    


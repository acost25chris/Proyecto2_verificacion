class scoreboard extends uvm_scoreboard;
    	`uvm_component_utils(scoreboard)

    	bit 		sign_X, sign_Y, sign_result;
    	logic [7:0] 	exp_X, exp_Y, exp_result;
    	logic [23:0] 	mantissa_X, mantissa_Y;
    	logic [47:0] 	mantissa_product; // Mantener 48 bits para el producto
    	logic [22:0] 	mantissa_final;
    	bit 		guard, round, sticky;
    	bit [31:0] 	expected_result;
		Item 		scoreboard_DB[$];
		Item		item_aux;
		int		csv_file;
		bit		flag = 0; 
		//variable para la assercion
		real tolerance = 1e-5;
		//-------------------------

    	function new(string name="scoreboard", uvm_component parent=null);
        	super.new(name, parent);
    	endfunction

    	uvm_analysis_imp #(Item, scoreboard) m_analysis_imp;

    	virtual function void build_phase(uvm_phase phase);
        	super.build_phase(phase);
        	m_analysis_imp = new("m_analysis_imp", this);
    	endfunction

    	virtual function void write(Item item);
		expected_result = 0;
        	expected_mul(item);
		if(flag == 1) begin
        		`uvm_info("SCBD", $sformatf("in1=%0d in2=%0d DUT_out=%0d round mode=%0d", item.fp_X, item.fp_Y, item.fp_Z, item.r_mode), UVM_LOW)
		end else begin
			flag = 1;
		end

		//assercion para confirma que el dato recibido es similar al dato esperado
		assert((item.fp_Z- expected_result)<tolerance)
			else `uvm_error("MISMATCH", "Producto en DUT no coincide con el valor esperado.");
		//-----------------------------------------------------------------------

        	if (item.fp_Z != expected_result) begin
            		`uvm_error("SCBD", $sformatf("ERROR: DUT=%0b expected=%0b", item.fp_Z, expected_result))
        	end else begin
            		`uvm_info("SCBD", $sformatf("PASS: DUT=%0d expected=%0d", item.fp_Z, expected_result), UVM_HIGH)
        	end
	
		scoreboard_DB.push_back(item); //Guarda el item recibido del monitor
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

		// Sumar los exponentes y ajustar el sesgo
		exp_result = (exp_X + exp_Y) - 127; 

		// Multiplicar las mantisas usando una multiplicación extendida de 24x24 bits
		mantissa_product = mantissa_X * mantissa_Y;
		//$display("Mantiza product %b",mantissa_product);

		// Normalización de la mantisa
		if(mantissa_product[47] == 1) begin
		    	mantissa_product = mantissa_product >> 1; // Desplazar a la derecha
		    	exp_result = exp_result + 1; // Ajustar el exponente
		end

		//Se revisan los casos especiales (0, infinito y NaN)
		//X con valor de infinito o 0, Y con valor de 0 o infinito
		if(((item.fp_X[30:0] == 31'b1111111100000000000000000000000) && (item.fp_Y[30:0] == 31'b0)) || ((item.fp_X[30:0] == 31'b0) && (item.fp_Y[30:0] == 31'b1111111100000000000000000000000))) begin
			item.fp_esperado = {(item.fp_X[31] ^ item.fp_Y[31]), 31'b1111111110000000000000000000000};
			expected_result = {(item.fp_X[31] ^ item.fp_Y[31]), 31'b1111111110000000000000000000000};

		// X o Y con valor de 0
		end else if ((item.fp_X[30:0] == 31'b0) || (item.fp_Y[30:0] == 31'b0)) begin
                	item.fp_esperado = {(item.fp_X[31] ^ item.fp_Y[31]), 8'h00, 23'h0};
			expected_result = {(item.fp_X[31] ^ item.fp_Y[31]), 8'h00, 23'h0};
		
		// X o Y con valor de infinito
            	end else if((item.fp_X[30:0] == 31'b1111111100000000000000000000000) || (item.fp_Y[30:0] == 31'b1111111100000000000000000000000)) begin
			item.fp_esperado = {(item.fp_X[31] ^ item.fp_Y[31]), 8'hFF, 23'h0};
			expected_result = {(item.fp_X[31] ^ item.fp_Y[31]), 8'hFF, 23'h0};

		// X o Y con valor de NaN
		end else if((item.fp_X[30:0] == 31'b1111111110000000000000000000000) || (item.fp_Y[30:0] == 31'b1111111110000000000000000000000)) begin
			item.fp_esperado = {(item.fp_X[31] ^ item.fp_Y[31]), 9'b1, 22'b0};
			expected_result = {(item.fp_X[31] ^ item.fp_Y[31]), 9'b1, 22'b0};

		end else begin


			// Extraer los bits de redondeo (guard, round y sticky)
			round = mantissa_product[22];
			guard = mantissa_product[21];
			sticky = |mantissa_product[20:0]; // Sticky es 1 si cualquier bit en los bits bajos está activo

			// Aplicar el redondeo según el modo seleccionado
			case (item.r_mode)
			3'b000: begin // Redondeo al par más cercano (round to nearest, ties to even)
		        	if (round && (guard || sticky)) begin
		            		mantissa_final = mantissa_product[45:23] + 1;
		        	end else begin
		            		mantissa_final = mantissa_product[45:23];
		        	end
		    	end

		    	3'b001: begin // Redondeo hacia cero (round towards zero)
				mantissa_final = mantissa_product[45:23];
			end

		    	3'b010: begin // Redondeo hacia -infinito
				if (sign_result == 1) begin
				   	mantissa_final = mantissa_product[45:23] + 1;
				end else begin
					mantissa_final = mantissa_product[45:23];
				end
			end

		    	3'b011: begin // Redondeo hacia +infinito
		        	if (sign_result == 0) begin
		            		mantissa_final = mantissa_product[45:23] + 1;
		        	end else begin
		            		mantissa_final = mantissa_product[45:23];
		        	end
		    	end

		    	3'b100: begin // Redondeo a más cercano, fuera de cero 
				if (round == 1) begin
		            		mantissa_final = mantissa_product[45:23] + 1;
		        	end else begin
		            		mantissa_final = mantissa_product[45:23];
		        	end
		    	end

		    	default: begin // Si no se especifica, usar redondeo al par más cercano
		        	mantissa_final = mantissa_product[45:23];
		    	end
		endcase

		// Empaquetar el resultado final en IEEE-754
		if (item.ovrf == 1) begin // Overflow, resultado es infinito
		    	expected_result = {sign_result, 8'hFF, 23'h0};
			item.fp_esperado = expected_result;
		
		end else if (item.udrf == 1) begin // Underflow, resultado es cero
		    	expected_result = {sign_result, 8'h00, 23'h0};
			item.fp_esperado = expected_result;

		end else begin // El resultado esperado es el resultado de la multiplicacion final
		    	expected_result = {sign_result, exp_result[7:0], mantissa_final};
			item.fp_esperado = expected_result;
		end
	endfunction
	
	virtual function void documento_csv();
		$display("[%0t] Generando reporte CSV", $time);
		csv_file = $fopen("Reporte_scoreboard.csv", "w");
		if (csv_file == 0) begin
			$display("Error: No se pudo abrir el archivo CSV para escritura.");
			return;
		end
		
		// Encabezado del documento CSV con alineación
		$fwrite(csv_file, "%-15s %-10s %-10s %-15s %-15s %-10s %-10s\n", 
			"Rounding mode", "Dato X", "Data Y", "Resultado DUT", "Resultado esperado", "Overflow", "Underflow");

		// Escribe cada registro con un ancho de columna alineado
		foreach (scoreboard_DB[i]) begin
			item_aux = scoreboard_DB[i];
			$fwrite(csv_file, "%-15b %-10h %-10h %-15h %-18h %-10b %-10b\n",
				item_aux.r_mode,
				item_aux.fp_X,
				item_aux.fp_Y,
				item_aux.fp_Z,
				item_aux.fp_esperado,
				item_aux.ovrf,
				item_aux.udrf
			);
		end

		// Cierra el archivo
		$fclose(csv_file);
		$display("Reporte CSV generado exitosamente.");
	endfunction

endclass

    


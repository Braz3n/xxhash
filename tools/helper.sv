package helper;
    function automatic void parse_csv_line_u32 (ref int data[], string input_string);
        // Parses a CSV string of 32-bit integers into a dynamic array
        // Dynamic array is returned via reference
        int head = 0;
        int tail = 0;
        data = new [0];
        
        while (tail < input_string.len()) begin
            if (input_string[tail] == "," || input_string[tail] == "\n" || tail == input_string.len()-1) begin
                data = new [data.size() + 1](data);
                if (tail == input_string.len()-1)
                    // Add an offset to catch the last character of a line with no newline character
                    tail += 1;
                data[data.size()-1] = input_string.substr(head, tail - 1).atoi();

                tail += 1;
                head = tail;
            end else begin
                tail += 1;
            end
        end
    endfunction

    function automatic logic unsigned [63:0] atou64 (string input_string);
        // Convert an integer string into a 63-bit integer
        logic unsigned [63:0] running_total = 0;

        for (int i=0; i<input_string.len(); i++) begin
            if (input_string[i] < 48 || input_string[i] > 57)  // Magic numbers here are ascii codes for 0 and 9
                break;  // Break if the character isn't an ascii integer character
            running_total *= 10;
            running_total += input_string[i] - 48;  // Subtract 48 to convert from ascii to decimal integers
        end

        return running_total;
    endfunction

    function automatic void parse_csv_line_u64 (ref logic unsigned [63:0] data[], string input_string);
        // Parses a CSV string of 32-bit integers into a dynamic array
        // Dynamic array is returned via reference
        int head = 0;
        int tail = 0;
        data = new [0];
        
        while (tail < input_string.len()) begin
            if (input_string[tail] == "," || input_string[tail] == "\n" || tail == input_string.len()-1) begin
                data = new [data.size() + 1](data);
                if (tail == input_string.len()-1)
                    // Add an offset to catch the last character of a line with no newline character
                    tail += 1;
                data[data.size()-1] = atou64(input_string.substr(head, tail-1));

                tail += 1;
                head = tail;
            end else begin
                tail += 1;
            end
        end
    endfunction

endpackage
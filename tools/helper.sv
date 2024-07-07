package helper;
    function automatic void parse_csv_line (ref int data[], string input_string);
        // Parses a CSV string of 32-bit integers into a dynamic array
        // Dynamic array is returned via reference
        int parsed_integer = 0;
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

endpackage
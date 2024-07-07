module xxhash32 #(
    localparam WORD_SIZE = 32,
    localparam STATE_COUNT = 4,
    localparam BUFFER_COUNT = 4  // Must be equal to state count
)(
    input logic clk,
    input logic add_to_hash,
    input logic request_hash,
    input logic seed_in,
    input logic [WORD_SIZE-1:0] input_bytes,
    output logic hash_ready,
    output logic [WORD_SIZE-1:0] output_hash
);
    localparam int unsigned Prime1 = 32'd2654435761;
    localparam int unsigned Prime2 = 32'd2246822519;
    localparam int unsigned Prime3 = 32'd3266489917;
    localparam int unsigned Prime4 = 32'd668265263;
    localparam int unsigned Prime5 = 32'd374761393;

    logic [WORD_SIZE-1:0] state_array [STATE_COUNT-1:0];
    logic [WORD_SIZE-1:0] buffer_array [1:0][BUFFER_COUNT-1:0];
    logic input_buffer_flag = 0;
    int   input_buffer_head = 0;
    logic input_buffer_full = 0;
    logic [63:0] bytes_processed = 0;
    logic [WORD_SIZE-1:0] result;
    assign output_hash = result;

    function automatic logic [WORD_SIZE-1:0] rotate_left(logic [WORD_SIZE-1:0] in, logic [7:0] bits);
        // rotate_left = (in << bits) | (bits >> (WORD_SIZE - bits));
        rotate_left = (in << bits) | (in >> (WORD_SIZE - bits));
    endfunction

    always_ff @(posedge clk) begin
        if (seed_in) begin
            // Seed the hash state
            state_array[0] = input_bytes + Prime1 + Prime2;
            state_array[1] = input_bytes + Prime2;
            state_array[2] = input_bytes;
            state_array[3] = input_bytes - Prime1;
            bytes_processed = 0;
            hash_ready = 0;
            input_buffer_head = 0;
            input_buffer_full = 0;
        end else begin
            if (add_to_hash & ~request_hash) begin
                buffer_array[input_buffer_flag][input_buffer_head] = input_bytes;
                if (input_buffer_head == BUFFER_COUNT - 1) begin
                    input_buffer_head = 0;
                    input_buffer_flag = ~input_buffer_flag;
                    input_buffer_full = 1;
                end else begin
                    input_buffer_head += 1;
                    input_buffer_full = 0;
                end;
            end else begin
                input_buffer_full = 0;
            end;
        end;
    end;

    always_ff @(posedge clk) begin
        if (input_buffer_full == 1) begin
            for (int i = 0; i < STATE_COUNT; i++) begin
                state_array[i] = rotate_left(state_array[i] + buffer_array[~input_buffer_flag][i] * Prime2, 13) * Prime1;
            end;
            bytes_processed += WORD_SIZE / 8 * STATE_COUNT;
        end;
    end;

    always_ff @(posedge clk) begin
        if (request_hash && ~add_to_hash) begin
            result = bytes_processed + WORD_SIZE / 8 * input_buffer_head;
            if (bytes_processed >= 16) begin
                result += rotate_left(state_array[0],  1) +
                          rotate_left(state_array[1],  7) +
                          rotate_left(state_array[2], 12) +
                          rotate_left(state_array[3], 18);
            end else begin
                result += state_array[2] + Prime5;
            end;

            if (input_buffer_head != 0) begin
                // There's leftover data in the buffer
                for (int i = 0; i < input_buffer_head; i++) begin
                    result = rotate_left(result + buffer_array[input_buffer_flag][i] * Prime3, 17) * Prime4;
                end;
            end;

            // In the original implementation there was a step for handling single bytes, 
            // This implementation only deals in whole words, however.

            result ^= result >> 15;
            result *= Prime2;
            result ^= result >> 13;
            result *= Prime3;
            result ^= result >> 16;
            hash_ready = 1;
        end;
    end;

endmodule
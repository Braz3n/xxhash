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
    int processing_buffer_index = 0;
    logic processing_buffer = 0;
    logic [63:0] bytes_received = 0;
    logic [WORD_SIZE-1:0] result;
    assign output_hash = result;

    function automatic logic [WORD_SIZE-1:0] rotate_left(logic [WORD_SIZE-1:0] in, logic [7:0] bits);
        rotate_left = (in << bits) | (in >> (WORD_SIZE - bits));
    endfunction

    always_ff @(posedge clk) begin
        input_buffer_full = 0;
        if (seed_in) begin
            // Seed the hash state
            state_array[0] = input_bytes + Prime1 + Prime2;
            state_array[1] = input_bytes + Prime2;
            state_array[2] = input_bytes;
            state_array[3] = input_bytes - Prime1;
            bytes_received = 0;
            hash_ready = 0;
            input_buffer_head = 0;
        end else if (add_to_hash) begin
            buffer_array[input_buffer_flag][input_buffer_head] = input_bytes;
            bytes_received += WORD_SIZE / 8;
            if (input_buffer_head == BUFFER_COUNT - 1) begin
                input_buffer_head = 0;
                input_buffer_flag = ~input_buffer_flag;
                input_buffer_full = 1;
            end else begin
                input_buffer_head += 1;
            end
        end
    end;

    always_ff @(posedge clk) begin
        if (input_buffer_full == 1) begin
            processing_buffer = 1;
            processing_buffer_index = 0;
        end

        if (processing_buffer && processing_buffer_index < BUFFER_COUNT) begin
            state_array[processing_buffer_index] = rotate_left(
                    state_array[processing_buffer_index] + 
                    buffer_array[~input_buffer_flag][processing_buffer_index] * 
                    Prime2, 13
                ) * Prime1;
            processing_buffer_index++;
        end else begin
            processing_buffer = 0;
            processing_buffer_index = 0;
        end
    end;

    always_ff @(posedge clk) begin
        if (request_hash && ~add_to_hash && ~processing_buffer) begin
            result = bytes_received;
            if (bytes_received >= 16) begin
                result += rotate_left(state_array[0],  1) +
                          rotate_left(state_array[1],  7) +
                          rotate_left(state_array[2], 12) +
                          rotate_left(state_array[3], 18);
            end else begin
                result += state_array[2] + Prime5;
            end;

            if (input_buffer_head > 0)  // Index 0 is populated
                result = rotate_left(result + buffer_array[input_buffer_flag][0] * Prime3, 17) * Prime4;
            if (input_buffer_head > 1)  // Index 1 is populated
                result = rotate_left(result + buffer_array[input_buffer_flag][1] * Prime3, 17) * Prime4;
            if (input_buffer_head > 2)  // Index 2 is populated
                result = rotate_left(result + buffer_array[input_buffer_flag][2] * Prime3, 17) * Prime4;
            // Index 3 is never populated at this stage of the algorithm. If the 3rd item is populated, then
            // the whole buffer would have been processed.

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
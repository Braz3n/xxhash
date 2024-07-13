module xxhash64 #(
    localparam WORD_SIZE = 64,
    localparam STATE_COUNT = 4,
    localparam BUFFER_COUNT = 4  // Must be equal to state count
)(
    input logic clk,
    input logic add_to_hash,
    input logic request_hash,
    input logic seed_in,
    input logic unsigned [WORD_SIZE-1:0] input_bytes,
    output logic hash_ready,
    output logic unsigned [WORD_SIZE-1:0] output_hash
);
    localparam logic unsigned [WORD_SIZE-1:0] Prime1 = 64'd11400714785074694791;
    localparam logic unsigned [WORD_SIZE-1:0] Prime2 = 64'd14029467366897019727;
    localparam logic unsigned [WORD_SIZE-1:0] Prime3 = 64'd1609587929392839161;
    localparam logic unsigned [WORD_SIZE-1:0] Prime4 = 64'd9650029242287828579;
    localparam logic unsigned [WORD_SIZE-1:0] Prime5 = 64'd2870177450012600261;

    logic [WORD_SIZE-1:0] state_array [STATE_COUNT-1:0];
    logic [WORD_SIZE-1:0] buffer_array [1:0][BUFFER_COUNT-1:0];
    logic input_buffer_flag = 0;
    int   input_buffer_head = 0;
    logic input_buffer_full = 0;
    int processing_buffer_index = 0;
    logic processing_buffer = 0;
    logic [63:0] bytes_received = 0;
    logic unsigned [WORD_SIZE-1:0] result;
    assign output_hash = result;

    function automatic logic [WORD_SIZE-1:0] rotate_left(logic [WORD_SIZE-1:0] in, logic [7:0] bits);
        rotate_left = (in << bits) | (in >> (WORD_SIZE - bits));
    endfunction

    function automatic logic [WORD_SIZE-1:0] process_single([WORD_SIZE-1:0] previous, [WORD_SIZE-1:0] in);
        process_single = rotate_left(previous + in * Prime2, 31) * Prime1;
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
            state_array[processing_buffer_index] = process_single(state_array[processing_buffer_index], buffer_array[~input_buffer_flag][processing_buffer_index]);
            processing_buffer_index++;
        end else begin
            processing_buffer = 0;
            processing_buffer_index = 0;
        end
    end;

    always_ff @(posedge clk) begin
        if (request_hash && ~add_to_hash && ~processing_buffer) begin
            if (bytes_received >= 32) begin
                result = rotate_left(state_array[0],  1) +
                         rotate_left(state_array[1],  7) +
                         rotate_left(state_array[2], 12) +
                         rotate_left(state_array[3], 18);
                result = (result ^ process_single(0, state_array[0])) * Prime1 + Prime4;
                result = (result ^ process_single(0, state_array[1])) * Prime1 + Prime4;
                result = (result ^ process_single(0, state_array[2])) * Prime1 + Prime4;
                result = (result ^ process_single(0, state_array[3])) * Prime1 + Prime4;
            end else begin
                result = state_array[2] + Prime5;
            end;

            result += bytes_received;

            if (input_buffer_head > 0)  // Index 0 is populated
                result = rotate_left(result ^ process_single(0, buffer_array[input_buffer_flag][0]), 27) * Prime1 + Prime4;
            if (input_buffer_head > 1)  // Index 1 is populated
                result = rotate_left(result ^ process_single(0, buffer_array[input_buffer_flag][1]), 27) * Prime1 + Prime4;
            if (input_buffer_head > 2)  // Index 2 is populated
                result = rotate_left(result ^ process_single(0, buffer_array[input_buffer_flag][2]), 27) * Prime1 + Prime4;
            // Index 3 is never populated at this stage of the algorithm. If the 3rd item is populated, then
            // the whole buffer would have been processed.

            // In the original implementation there was a step for handling sub-words. 
            // This implementation only deals in whole words, however.

            result ^= result >> 33;
            result *= Prime2;
            result ^= result >> 29;
            result *= Prime3;
            result ^= result >> 32;
            hash_ready = 1;
        end;
    end;

endmodule
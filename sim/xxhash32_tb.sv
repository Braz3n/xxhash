include "helper.sv";

module xxhash32_tb;

    import helper::*;

    // Constants
    localparam WORD_SIZE = 32;
    localparam STATE_COUNT = 4;

    // Signals
    logic clk;
    logic add_to_hash;
    logic request_hash;
    logic seed_in;
    logic [WORD_SIZE-1:0] input_bytes;
    logic hash_ready;
    logic [WORD_SIZE-1:0] output_hash;

    // Instantiate the module under test
    xxhash32 dut (
        .clk(clk),
        .add_to_hash(add_to_hash),
        .request_hash(request_hash),
        .seed_in(seed_in),
        .input_bytes(input_bytes),
        .hash_ready(hash_ready),
        .output_hash(output_hash)
    );

    // Clock generation
    always begin
        clk = 0;
        #5;  // Adjust delay based on your clock period
        clk = 1;
        #5;  // Adjust delay based on your clock period
    end

    initial begin
        int fd;
        string csv_line;
        int parse_index;
        int output_integer;
        int csv_ints[];
        int test_cases;
        int seed;
        int input_word_count;
        int expected_output;
        int res;

        fd = $fopen("./reference/reference_dump.txt", "r");
        if (fd) $display("Reference dump opened successfully");
        else $fatal("Failed to open reference dump");

        res = $fgets(csv_line, fd);
        parse_csv_line(csv_ints, csv_line);
        test_cases = csv_ints[0];
        $display("Running %0d test cases", test_cases);

        for (int test_idx = 0; test_idx < test_cases; test_idx++) begin
            $display("    Running test case %0d", test_cases);

            // Fetch and parse the test case
            res = $fgets(csv_line, fd);
            parse_csv_line(csv_ints, csv_line);
            seed = csv_ints[0];
            input_word_count = csv_ints[1];
            expected_output = csv_ints[csv_ints.size()-1];
            $display("        Seed 0x%0X", seed);
            $display("        Input Word Count %0d", input_word_count);
            $display("        Expected output 0x%0X", expected_output);

            #10;

            add_to_hash = 0;
            request_hash = 0;
            seed_in = 1;

            input_bytes = seed;  // First item is the seed

            #10;

            add_to_hash = 1;
            request_hash = 0;
            seed_in = 0;

            // Feed in the data to hash
            for (int i=0;i<input_word_count;i++) begin
                input_bytes = csv_ints[i + 2];  // Offset by 2 to index into the array correctly
                #10;
            end
            add_to_hash = 0;
            request_hash = 1;
            seed_in = 0;

            #10;
            #10;
            // Verify the output of the module
            assert(output_hash == expected_output);

        end
        $display("All Test Cases OK");
        $finish;
    end

endmodule

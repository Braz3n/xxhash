#include <cstdlib>
#include <ctime>
#include <array>
#include <fstream>
#include "stdio.h"
#include "xxhash32.h"

constexpr uint32_t SAMPLE_COUNT_MASK = 15;

void generate_reference_sample() {
    std::ofstream fp;
    fp.open("reference_dump.txt", std::ofstream::out | std::ofstream::trunc);
    constexpr uint32_t test_case_count = 10;
    std::srand(std::time(nullptr));
    fp << test_case_count << std::endl;
    for (uint32_t test_case=0; test_case<test_case_count; test_case++) {
        constexpr uint32_t max_words = 0x7;
        uint32_t seed = std::rand();
        uint32_t word_count = std::rand() & max_words; 
        XXHash32 hasher(seed);
        fp << seed << "," << word_count;
        for (uint32_t word_idx=0; word_idx<word_count; word_idx++) {
            uint32_t word = std::rand();
            hasher.add(&word, 4);
            fp << "," << word;
        }
        uint32_t hash = hasher.hash();
        fp << "," << hash << std::endl;
    }
}

int main() {
    uint32_t seed = 1;
    uint32_t bytes[] = {0xdeadbeef, 0xcafef00d, 0xca11ab1e, 0x0ddba11, 0xf0017001};

    // uint32_t hash = XXHash32::hash(bytes, 4, seed);

    XXHash32 hasher(seed);
    hasher.add(bytes, 5 * sizeof(uint32_t));
    uint32_t hash = hasher.hash();

    printf("Hash Output: 0x%X\n", hash);

    generate_reference_sample();

    return 0;
}
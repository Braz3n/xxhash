#include <cstdlib>
#include <ctime>
#include <array>
#include <fstream>
#include "stdio.h"
#include "xxhash32.h"
#include "xxhash64.h"

constexpr uint32_t SAMPLE_COUNT_MASK = 127;

void generate_reference_sample_32bit() {
    std::ofstream fp;
    fp.open("reference_dump_xxhash32.txt", std::ofstream::out | std::ofstream::trunc);
    constexpr uint32_t test_case_count = 10;
    std::srand(std::time(nullptr));
    fp << test_case_count << std::endl;
    for (uint32_t test_case=0; test_case<test_case_count; test_case++) {
        uint32_t seed = std::rand();
        uint32_t word_count = std::rand() & SAMPLE_COUNT_MASK; 
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

void generate_reference_sample_64bit() {
    std::ofstream fp;
    fp.open("reference_dump_xxhash64.txt", std::ofstream::out | std::ofstream::trunc);
    constexpr uint32_t test_case_count = 10;
    std::srand(std::time(nullptr));
    // std::srand(0);
    fp << test_case_count << std::endl;
    for (uint32_t test_case=0; test_case<test_case_count; test_case++) {
        uint32_t seed = std::rand();
        // uint32_t seed = 1;
        uint32_t word_count = std::rand() & SAMPLE_COUNT_MASK; 
        // uint32_t word_count = 1; 
        XXHash64 hasher(seed);
        fp << seed << "," << word_count;
        for (uint32_t word_idx=0; word_idx<word_count; word_idx++) {
            uint64_t word = static_cast<uint64_t>(std::rand()) << 32 | std::rand();
            hasher.add(&word, 8);
            fp << "," << word;
        }
        uint64_t hash = hasher.hash();
        fp << "," << hash << std::endl;
    }
}

int main() {
    generate_reference_sample_32bit();
    generate_reference_sample_64bit();

    return 0;
}
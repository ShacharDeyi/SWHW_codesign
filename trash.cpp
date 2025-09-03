#include <cstddef>
#include <cstdint>
#include <vector>

const size_t size = 21*1024*1024; // 100 MB
std::vector<uint8_t> dummy(size);
volatile uint64_t sum = 0;

int main() {
    for (size_t i = 0; i < size; ++i)
        sum += dummy[i];  // Access all bytes to force load into cache
    return 0;
}

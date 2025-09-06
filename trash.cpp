#include <cstddef>
#include <cstdint>
#include <vector>

const size_t size = 21*1024*1024; // 21 MB as seen in the virtual machine
std::vector<uint8_t> arr(size); //allocate
volatile uint64_t sum = 0; // prevent optimization

int main() {
    //this loop is just to make sure the memory is used
    for (size_t i = 0; i < size; ++i)
        sum += arr[i];  
    return 0;
}

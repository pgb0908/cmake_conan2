#include <iostream>
#include "fmt/format.h"

int main() {
    int a = 42;
    auto data = fmt::format("hello {}", a);

    std::cout << data<< std::endl;
    return 0;
}

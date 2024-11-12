find_package(fmt REQUIRED)

add_executable(conan2_start main.cpp)
target_link_libraries(conan2_start fmt::fmt)

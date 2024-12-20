

include(${CMAKE_BINARY_DIR}/conan/build/Release/generators/conan_toolchain.cmake)
find_package(Protobuf REQUIRED)
find_program(PROTOC_EXECUTABLE protoc PATHS ${CMAKE_PROGRAM_PATH}
        NO_DEFAULT_PATH
        REQUIRED
        DOC "Path to protoc executable"
)
message(STATUS "Using protobuf ${Protobuf_VERSION}")
message(STATUS "CMAKE_PROGRAM_PATH: ${CMAKE_PROGRAM_PATH}")


#set(PROTOC_EXECUTABLE ${protobuf_INCLUDE_DIRS}/../bin/protoc)
message(STATUS "PROTOBUF_PROTOC_EXECUTABLE: ${PROTOBUF_PROTOC_EXECUTABLE}")
message(STATUS "Protobuf Libraries2: ${Protobuf_INCLUDE_DIRS}")

# protoc 버전 확인
execute_process(
        COMMAND ${PROTOC_EXECUTABLE} --version
        OUTPUT_VARIABLE PROTOC_VERSION
        OUTPUT_STRIP_TRAILING_WHITESPACE
)



# protoc 버전을 출력
message(STATUS "Protobuf Compiler Version: ${PROTOC_VERSION}")


# Find gRPC installation
# Looks for gRPCConfig.cmake file installed by gRPC's cmake installation.
find_package(gRPC CONFIG REQUIRED)
message(STATUS "Using gRPC ${gRPC_VERSION}")

set(_GRPC_GRPCPP gRPC::grpc++)
if(CMAKE_CROSSCOMPILING)
    find_program(_GRPC_CPP_PLUGIN_EXECUTABLE grpc_cpp_plugin)
else()
    set(_GRPC_CPP_PLUGIN_EXECUTABLE $<TARGET_FILE:gRPC::grpc_cpp_plugin>)
endif()

set(ROOT_DIR ${CMAKE_CURRENT_SOURCE_DIR})




# Get proto files
set (proto_name greetings)
get_filename_component(proto "proto/${proto_name}.proto" ABSOLUTE)
get_filename_component(proto_dir "${proto}" DIRECTORY)

set(CURRENT_DIR ${ROOT_DIR})
include_directories(${CURRENT_DIR}/proto)


# Generate source files
set(proto_srcs "${CURRENT_DIR}/${proto_name}.pb.cc")
set(proto_hdrs "${CURRENT_DIR}/${proto_name}.pb.h")
set(grpc_srcs "${CURRENT_DIR}/${proto_name}.grpc.pb.cc")
set(grpc_hdrs "${CURRENT_DIR}/${proto_name}.grpc.pb.h")
add_custom_command(
        OUTPUT "${proto_srcs}" "${proto_hdrs}" "${grpc_srcs}" "${grpc_hdrs}"
        COMMAND
        ${PROTOC_EXECUTABLE} ARGS "--grpc_out=${CURRENT_DIR}"
        "--cpp_out=${CURRENT_DIR}" "--proto_path=${proto_dir}"
        "--plugin=protoc-gen-grpc=${_GRPC_CPP_PLUGIN_EXECUTABLE}"
        "${proto}"
        DEPENDS "${proto}"
)

include_directories(CURRENT_DIR)
add_library(target STATIC
        ${proto_srcs}
        ${grpc_srcs}
)

target_link_libraries(target PRIVATE ${_REFLECTION} ${_GRPC_GRPCPP} ${_PROTOBUF_LIBPROTOBUF})
target_include_directories(target PRIVATE ${proto_hdrs} ${grpc_hdrs})

add_subdirectory(server)
add_subdirectory(client)
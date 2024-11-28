add_executable(grpc_server Server.cpp)

target_link_libraries(grpc_server  grpc::grpc
        target
)
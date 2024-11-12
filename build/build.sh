#!/bin/bash

CURRENT_DIR=$(pwd)

cmake .. -DCMAKE_PROJECT_TOP_LEVEL_INCLUDES="conan_provider.cmake" -DCONAN_COMMAND="${CURRENT_DIR}/../conan/conan"
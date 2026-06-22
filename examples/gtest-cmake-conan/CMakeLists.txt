cmake_minimum_required(VERSION 3.25)
project(gtest_cmake_conan LANGUAGES CXX)

set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_CXX_EXTENSIONS OFF)

set(SAMPLE_SANITIZER "address-undefined" CACHE STRING
  "Sanitizer mode: none, address, thread, undefined, memory, address-undefined")
set_property(CACHE SAMPLE_SANITIZER PROPERTY STRINGS
  none address thread undefined memory address-undefined)

function(enable_sample_sanitizer target_name)
  string(TOLOWER "${SAMPLE_SANITIZER}" sanitizer)
  if(sanitizer STREQUAL "" OR sanitizer STREQUAL "none")
    return()
  endif()

  if(NOT CMAKE_CXX_COMPILER_ID MATCHES "GNU|Clang")
    message(WARNING "Sanitizer flags are not configured for ${CMAKE_CXX_COMPILER_ID}")
    return()
  endif()

  set(compile_flags -fno-omit-frame-pointer)
  set(link_flags)

  if(sanitizer STREQUAL "address")
    list(APPEND compile_flags -fsanitize=address)
    list(APPEND link_flags -fsanitize=address)
  elseif(sanitizer STREQUAL "thread")
    list(APPEND compile_flags -fsanitize=thread)
    list(APPEND link_flags -fsanitize=thread)
  elseif(sanitizer STREQUAL "undefined")
    list(APPEND compile_flags -fsanitize=undefined)
    list(APPEND link_flags -fsanitize=undefined)
  elseif(sanitizer STREQUAL "memory")
    if(NOT CMAKE_CXX_COMPILER_ID MATCHES "Clang")
      message(FATAL_ERROR "MemorySanitizer requires Clang")
    endif()
    list(APPEND compile_flags
      -fsanitize=memory
      -fsanitize-memory-track-origins=2
      -fno-optimize-sibling-calls
    )
    list(APPEND link_flags
      -fsanitize=memory
      -fsanitize-memory-track-origins=2
    )
  elseif(sanitizer STREQUAL "address-undefined")
    list(APPEND compile_flags -fsanitize=address,undefined)
    list(APPEND link_flags -fsanitize=address,undefined)
  else()
    message(FATAL_ERROR "Unsupported SAMPLE_SANITIZER=${SAMPLE_SANITIZER}")
  endif()

  string(REGEX REPLACE "[^A-Za-z0-9]" "_" sanitizer_macro "${sanitizer}")
  string(TOUPPER "${sanitizer_macro}" sanitizer_macro)
  target_compile_options(${target_name} PRIVATE ${compile_flags})
  target_link_options(${target_name} PRIVATE ${link_flags})
  target_compile_definitions(${target_name} PRIVATE
    SAMPLE_SANITIZER_ENABLED=1
    "SAMPLE_SANITIZER_${sanitizer_macro}=1"
  )
endfunction()

find_package(GTest REQUIRED)
find_package(Protobuf REQUIRED)
enable_testing()

set(PROTO_ROOT "${CMAKE_CURRENT_SOURCE_DIR}/../../proto")
set(PERSON_PROTO "${PROTO_ROOT}/demo/v1/person.proto")
set(GENERATED_PROTO_DIR "${CMAKE_CURRENT_BINARY_DIR}/generated")

add_library(person_proto
  "${PERSON_PROTO}"
)
target_include_directories(person_proto PUBLIC "${GENERATED_PROTO_DIR}")
target_link_libraries(person_proto PUBLIC protobuf::libprotobuf)
protobuf_generate(
  TARGET person_proto
  LANGUAGE cpp
  IMPORT_DIRS "${PROTO_ROOT}"
  PROTOC_OUT_DIR "${GENERATED_PROTO_DIR}"
)
enable_sample_sanitizer(person_proto)

add_executable(sample_test
  test/sample_test.cpp
)
target_link_libraries(sample_test PRIVATE GTest::gtest_main person_proto)
enable_sample_sanitizer(sample_test)

include(GoogleTest)
gtest_discover_tests(sample_test)

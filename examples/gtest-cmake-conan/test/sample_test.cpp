#include <gtest/gtest.h>

#include "demo/v1/person.pb.h"

#include <iostream>
#include <string>
#include <vector>

#if defined(__has_feature)
#if __has_feature(address_sanitizer)
#define SAMPLE_HAS_ADDRESS_SANITIZER 1
#endif
#endif

#if defined(__SANITIZE_ADDRESS__)
#define SAMPLE_HAS_ADDRESS_SANITIZER 1
#endif

#if defined(__has_feature)
#if __has_feature(thread_sanitizer)
#define SAMPLE_HAS_THREAD_SANITIZER 1
#endif
#if __has_feature(memory_sanitizer)
#define SAMPLE_HAS_MEMORY_SANITIZER 1
#endif
#endif

#if defined(__SANITIZE_THREAD__)
#define SAMPLE_HAS_THREAD_SANITIZER 1
#endif

#ifndef SAMPLE_HAS_ADDRESS_SANITIZER
#define SAMPLE_HAS_ADDRESS_SANITIZER 0
#endif

#ifndef SAMPLE_HAS_THREAD_SANITIZER
#define SAMPLE_HAS_THREAD_SANITIZER 0
#endif

#ifndef SAMPLE_HAS_MEMORY_SANITIZER
#define SAMPLE_HAS_MEMORY_SANITIZER 0
#endif

namespace {

int add(int lhs, int rhs) {
  return lhs + rhs;
}

int sumValues(const std::vector<int>& values) {
  int total = 0;
  for (int value : values) {
    total += value;
  }
  return total;
}

std::string makePersonTextProto() {
  demo::v1::Person person;
  person.set_name("Ada Lovelace");
  person.set_id(1001);
  person.add_skills("cmake");
  person.add_skills("conan");
  person.add_skills("protobuf");
  return person.DebugString();
}

}  // namespace

TEST(AdditionTest, AddsPositiveNumbers) {
  EXPECT_EQ(add(2, 3), 5);
}

TEST(AdditionTest, AddsNegativeNumbers) {
  EXPECT_EQ(add(-2, -3), -5);
}

TEST(ProtobufPrintTest, PrintsPerson) {
  const std::string text = makePersonTextProto();
  std::cout << text << '\n';
  EXPECT_NE(text.find("Ada Lovelace"), std::string::npos);
  EXPECT_NE(text.find("protobuf"), std::string::npos);
}

TEST(SanitizerTest, RunsWithSelectedSanitizer) {
#if defined(SAMPLE_SANITIZER_ADDRESS) || defined(SAMPLE_SANITIZER_ADDRESS_UNDEFINED)
  EXPECT_EQ(SAMPLE_HAS_ADDRESS_SANITIZER, 1);
#endif
#if defined(SAMPLE_SANITIZER_THREAD)
  EXPECT_EQ(SAMPLE_HAS_THREAD_SANITIZER, 1);
#endif
#if defined(SAMPLE_SANITIZER_MEMORY)
  EXPECT_EQ(SAMPLE_HAS_MEMORY_SANITIZER, 1);
#endif
  const std::vector<int> values = {1, 2, 3, 4};
  EXPECT_EQ(sumValues(values), 10);
}

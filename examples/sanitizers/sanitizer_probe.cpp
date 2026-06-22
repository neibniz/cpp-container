#include <climits>
#include <thread>

#if defined(__has_feature)
#if __has_feature(address_sanitizer)
#define SAMPLE_HAS_ADDRESS_SANITIZER 1
#endif
#if __has_feature(thread_sanitizer)
#define SAMPLE_HAS_THREAD_SANITIZER 1
#endif
#if __has_feature(memory_sanitizer)
#define SAMPLE_HAS_MEMORY_SANITIZER 1
#endif
#endif

#if defined(__SANITIZE_ADDRESS__)
#define SAMPLE_HAS_ADDRESS_SANITIZER 1
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

#if defined(SAMPLE_EXPECT_ADDRESS) && SAMPLE_HAS_ADDRESS_SANITIZER != 1
#error "AddressSanitizer instrumentation is not enabled"
#endif

#if defined(SAMPLE_EXPECT_THREAD) && SAMPLE_HAS_THREAD_SANITIZER != 1
#error "ThreadSanitizer instrumentation is not enabled"
#endif

#if defined(SAMPLE_EXPECT_MEMORY) && SAMPLE_HAS_MEMORY_SANITIZER != 1
#error "MemorySanitizer instrumentation is not enabled"
#endif

namespace {

volatile int runtime_value = 1;
int shared_counter = 0;

int cleanRun() {
  int values[] = {1, 2, 3, 4};
  int total = 0;
  for (int value : values) {
    total += value;
  }
  return total == 10 ? 0 : 1;
}

__attribute__((noinline)) int triggerAddressSanitizer() {
  volatile int index = 4;
  int* values = new int[4]{1, 2, 3, 4};
  int result = values[index];
  delete[] values;
  return result;
}

__attribute__((noinline)) int triggerUndefinedBehaviorSanitizer() {
  volatile int max = INT_MAX;
  return max + runtime_value;
}

void incrementSharedCounter() {
  for (int index = 0; index < 100000; ++index) {
    ++shared_counter;
  }
}

int triggerThreadSanitizer() {
  std::thread first(incrementSharedCounter);
  std::thread second(incrementSharedCounter);
  first.join();
  second.join();
  return shared_counter;
}

__attribute__((noinline)) int triggerMemorySanitizer() {
  int value;
  return value;
}

}  // namespace

int main() {
#if defined(SAMPLE_TRIGGER_ADDRESS)
  return triggerAddressSanitizer();
#elif defined(SAMPLE_TRIGGER_THREAD)
  return triggerThreadSanitizer() == 0 ? 1 : 0;
#elif defined(SAMPLE_TRIGGER_UNDEFINED)
  return triggerUndefinedBehaviorSanitizer();
#elif defined(SAMPLE_TRIGGER_MEMORY)
  return triggerMemorySanitizer();
#else
  return cleanRun();
#endif
}

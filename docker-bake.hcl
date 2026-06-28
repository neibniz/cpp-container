variable "IMAGE_PREFIX" {
  default = ""
}

variable "VERSION" {
  default = "local"
}

variable "PLATFORMS" {
  default = ["linux/amd64", "linux/arm64"]
}

variable "LOCAL_PLATFORM" {
  default = "linux/amd64"
}

group "default" {
  targets = [
    "gcc-build",
    "clang-build",
    "gcc-dev",
    "clang-dev",
    "gcc-runtime",
    "clang-runtime",
    "bazel-build",
    "bazel-dev",
  ]
}

group "local" {
  targets = [
    "gcc-build-local",
    "clang-build-local",
    "gcc-dev-local",
    "clang-dev-local",
    "gcc-runtime-local",
    "clang-runtime-local",
    "bazel-build-local",
    "bazel-dev-local",
  ]
}

target "_common" {
  context = "."
  dockerfile = "Dockerfile"
  platforms = PLATFORMS
}

target "_local" {
  output = ["type=docker"]
  platforms = [LOCAL_PLATFORM]
}

target "gcc-build" {
  inherits = ["_common"]
  target = "gcc-build"
  tags = ["${IMAGE_PREFIX}gcc-build:${VERSION}"]
}

target "gcc-build-local" {
  inherits = ["gcc-build", "_local"]
}

target "clang-build" {
  inherits = ["_common"]
  target = "clang-build"
  tags = ["${IMAGE_PREFIX}clang-build:${VERSION}"]
}

target "clang-build-local" {
  inherits = ["clang-build", "_local"]
}

target "gcc-dev" {
  inherits = ["_common"]
  target = "gcc-dev"
  tags = ["${IMAGE_PREFIX}gcc-dev:${VERSION}"]
}

target "gcc-dev-local" {
  inherits = ["gcc-dev", "_local"]
}

target "clang-dev" {
  inherits = ["_common"]
  target = "clang-dev"
  tags = ["${IMAGE_PREFIX}clang-dev:${VERSION}"]
}

target "clang-dev-local" {
  inherits = ["clang-dev", "_local"]
}

target "gcc-runtime" {
  inherits = ["_common"]
  target = "gcc-runtime"
  tags = ["${IMAGE_PREFIX}gcc-runtime:${VERSION}"]
}

target "gcc-runtime-local" {
  inherits = ["gcc-runtime", "_local"]
}

target "clang-runtime" {
  inherits = ["_common"]
  target = "clang-runtime"
  tags = ["${IMAGE_PREFIX}clang-runtime:${VERSION}"]
}

target "clang-runtime-local" {
  inherits = ["clang-runtime", "_local"]
}

target "bazel-build" {
  inherits = ["_common"]
  target = "bazel-build"
  tags = ["${IMAGE_PREFIX}bazel-build:${VERSION}"]
}

target "bazel-build-local" {
  inherits = ["bazel-build", "_local"]
}

target "bazel-dev" {
  inherits = ["_common"]
  target = "bazel-dev"
  tags = ["${IMAGE_PREFIX}bazel-dev:${VERSION}"]
}

target "bazel-dev-local" {
  inherits = ["bazel-dev", "_local"]
}

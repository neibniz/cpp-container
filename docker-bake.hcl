variable "IMAGE" {
  default = "cpp-container"
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
  tags = ["${IMAGE}:gcc-build-${VERSION}"]
}

target "gcc-build-local" {
  inherits = ["gcc-build", "_local"]
}

target "clang-build" {
  inherits = ["_common"]
  target = "clang-build"
  tags = ["${IMAGE}:clang-build-${VERSION}"]
}

target "clang-build-local" {
  inherits = ["clang-build", "_local"]
}

target "gcc-dev" {
  inherits = ["_common"]
  target = "gcc-dev"
  tags = ["${IMAGE}:gcc-dev-${VERSION}"]
}

target "gcc-dev-local" {
  inherits = ["gcc-dev", "_local"]
}

target "clang-dev" {
  inherits = ["_common"]
  target = "clang-dev"
  tags = ["${IMAGE}:clang-dev-${VERSION}"]
}

target "clang-dev-local" {
  inherits = ["clang-dev", "_local"]
}

target "gcc-runtime" {
  inherits = ["_common"]
  target = "gcc-runtime"
  tags = ["${IMAGE}:gcc-runtime-${VERSION}"]
}

target "gcc-runtime-local" {
  inherits = ["gcc-runtime", "_local"]
}

target "clang-runtime" {
  inherits = ["_common"]
  target = "clang-runtime"
  tags = ["${IMAGE}:clang-runtime-${VERSION}"]
}

target "clang-runtime-local" {
  inherits = ["clang-runtime", "_local"]
}

# syntax=docker/dockerfile:1.7

ARG DEBIAN_VERSION=trixie-slim

FROM debian:${DEBIAN_VERSION} AS common
SHELL ["/bin/bash", "-o", "pipefail", "-c"]

ARG TARGETARCH
ARG CMAKE_VERSION=4.3.4
ARG UV_VERSION=0.11.23
ARG PYTHON_VERSION=3.14
ARG CONAN_VERSION=2.29.1
ARG BAZELISK_VERSION=1.29.0
ARG BAZEL_VERSION=9.1.1
ARG BUF_VERSION=1.71.0
ARG BUILDIFIER_VERSION=8.5.1
ARG PREFETCH_BAZEL=1
ARG CMAKE_AMD64_SHA256=ca6f08ccbd5e6b0a9068d33317d0d1aff7278d08cccaed4529b8fbead7942a68
ARG CMAKE_ARM64_SHA256=56a8014a8f28b8ff9cbe2c6fa8beebc028ac5b1987195d122b847fb486dc5282
ARG UV_AMD64_SHA256=e12c4cda2fe8c305510a78380a88f2c32a27e90cdcd123cefd2873388f0ebb5f
ARG UV_ARM64_SHA256=1873a77350f6621279ae1a0d2227f2bd8b67131598f14a7eb0ba2215d3da2c98
ARG BAZELISK_AMD64_SHA256=5a408715e932c0250d28bd84555f12edbf70117de42f9181691c736eacc4a992
ARG BAZELISK_ARM64_SHA256=e20e8b0f4f240091b7a55bf17b9398bd4f40ee70ae0208dff95dd4c445fb4010
ARG BUF_AMD64_SHA256=d3de2838c68a5759ca276884254bc70df4e4ad185d6ed5f65f327b6ce6363eab
ARG BUF_ARM64_SHA256=041c15f3a8c4bd6cf36285d7a9ef290cd3e2536ef3bfd3de64d1f70cc5144c6e
ARG BUILDIFIER_AMD64_SHA256=887377fc64d23a850f4d18a077b5db05b19913f4b99b270d193f3c7334b5a9a7
ARG BUILDIFIER_ARM64_SHA256=947bf6700d708026b2057b09bea09abbc3cafc15d9ecea35bb3885c4b09ccd04

ENV DEBIAN_FRONTEND=noninteractive \
    UV_PYTHON_INSTALL_DIR=/opt/uv/python \
    UV_TOOL_DIR=/opt/uv/tools \
    UV_TOOL_BIN_DIR=/usr/local/bin \
    BAZELISK_HOME=/opt/bazelisk \
    USE_BAZEL_FALLBACK_VERSION=${BAZEL_VERSION} \
    PATH=/opt/cmake/bin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin

COPY docker/scripts/common.sh \
     docker/scripts/install-base-packages.sh \
     docker/scripts/install-cmake.sh \
     docker/scripts/install-uv.sh \
     docker/scripts/install-python-conan.sh \
     docker/scripts/install-bazelisk.sh \
     docker/scripts/install-buf.sh \
     /tmp/cpp-container-scripts/
RUN bash /tmp/cpp-container-scripts/install-base-packages.sh \
 && bash /tmp/cpp-container-scripts/install-cmake.sh \
 && bash /tmp/cpp-container-scripts/install-uv.sh \
 && bash /tmp/cpp-container-scripts/install-python-conan.sh \
 && bash /tmp/cpp-container-scripts/install-bazelisk.sh \
 && bash /tmp/cpp-container-scripts/install-buf.sh \
 && rm -rf /tmp/cpp-container-scripts

FROM common AS gcc-build
SHELL ["/bin/bash", "-o", "pipefail", "-c"]
ARG GCC_MAJOR=14
COPY docker/scripts/common.sh \
     docker/scripts/install-gcc-toolchain.sh \
     docker/scripts/install-debug-tools.sh \
     /tmp/cpp-container-scripts/
RUN bash /tmp/cpp-container-scripts/install-gcc-toolchain.sh \
 && DEBUG_TOOLCHAIN=gcc bash /tmp/cpp-container-scripts/install-debug-tools.sh \
 && rm -rf /tmp/cpp-container-scripts
ENV CC=gcc CXX=g++
WORKDIR /workspace

FROM common AS clang-build
SHELL ["/bin/bash", "-o", "pipefail", "-c"]
ARG GCC_MAJOR=14
ARG LLVM_MAJOR=19
COPY docker/scripts/common.sh \
     docker/scripts/install-clang-toolchain.sh \
     docker/scripts/install-debug-tools.sh \
     /tmp/cpp-container-scripts/
RUN bash /tmp/cpp-container-scripts/install-clang-toolchain.sh \
 && DEBUG_TOOLCHAIN=clang bash /tmp/cpp-container-scripts/install-debug-tools.sh \
 && rm -rf /tmp/cpp-container-scripts
ENV CC=clang CXX=clang++
WORKDIR /workspace

FROM gcc-build AS gcc-dev
SHELL ["/bin/bash", "-o", "pipefail", "-c"]
ARG DEV_USER=dev
ARG DEV_UID=1000
ARG DEV_GID=1000
ARG DEV_SUDO=1
ARG LLVM_MAJOR=19
ENV DEV_TOOLCHAIN=gcc
COPY docker/scripts/common.sh \
     docker/scripts/install-clangd.sh \
     docker/scripts/install-buildifier.sh \
     docker/scripts/setup-dev-user.sh \
     docker/scripts/setup-sshd.sh \
     /tmp/cpp-container-scripts/
COPY docker/entrypoint-dev.sh /usr/local/bin/entrypoint-dev
COPY docker/profile/dev-aliases.sh /etc/profile.d/dev-aliases.sh
COPY docker/profile/gcc-env.sh /etc/profile.d/toolchain-env.sh
RUN bash /tmp/cpp-container-scripts/install-buildifier.sh \
 && bash /tmp/cpp-container-scripts/install-clangd.sh \
 && bash /tmp/cpp-container-scripts/setup-dev-user.sh \
 && bash /tmp/cpp-container-scripts/setup-sshd.sh \
 && chmod 0755 /usr/local/bin/entrypoint-dev /etc/profile.d/dev-aliases.sh /etc/profile.d/toolchain-env.sh \
 && rm -rf /tmp/cpp-container-scripts
EXPOSE 22
WORKDIR /workspace
ENTRYPOINT ["/usr/local/bin/entrypoint-dev"]

FROM clang-build AS clang-dev
SHELL ["/bin/bash", "-o", "pipefail", "-c"]
ARG DEV_USER=dev
ARG DEV_UID=1000
ARG DEV_GID=1000
ARG DEV_SUDO=1
ARG LLVM_MAJOR=19
ENV DEV_TOOLCHAIN=clang
COPY docker/scripts/common.sh \
     docker/scripts/install-clangd.sh \
     docker/scripts/install-buildifier.sh \
     docker/scripts/setup-dev-user.sh \
     docker/scripts/setup-sshd.sh \
     /tmp/cpp-container-scripts/
COPY docker/entrypoint-dev.sh /usr/local/bin/entrypoint-dev
COPY docker/profile/dev-aliases.sh /etc/profile.d/dev-aliases.sh
COPY docker/profile/clang-env.sh /etc/profile.d/toolchain-env.sh
RUN bash /tmp/cpp-container-scripts/install-buildifier.sh \
 && bash /tmp/cpp-container-scripts/install-clangd.sh \
 && bash /tmp/cpp-container-scripts/setup-dev-user.sh \
 && bash /tmp/cpp-container-scripts/setup-sshd.sh \
 && chmod 0755 /usr/local/bin/entrypoint-dev /etc/profile.d/dev-aliases.sh /etc/profile.d/toolchain-env.sh \
 && rm -rf /tmp/cpp-container-scripts
EXPOSE 22
WORKDIR /workspace
ENTRYPOINT ["/usr/local/bin/entrypoint-dev"]

FROM debian:${DEBIAN_VERSION} AS gcc-runtime
SHELL ["/bin/bash", "-o", "pipefail", "-c"]
ENV DEBIAN_FRONTEND=noninteractive
RUN apt-get update \
 && apt-get install -y --no-install-recommends ca-certificates libatomic1 libgcc-s1 libgomp1 libstdc++6 \
 && rm -rf /var/lib/apt/lists/*
WORKDIR /app
CMD ["/bin/sh"]

FROM debian:${DEBIAN_VERSION} AS clang-runtime
SHELL ["/bin/bash", "-o", "pipefail", "-c"]
ENV DEBIAN_FRONTEND=noninteractive
RUN apt-get update \
 && apt-get install -y --no-install-recommends ca-certificates libatomic1 libgcc-s1 libgomp1 libstdc++6 \
 && rm -rf /var/lib/apt/lists/*
WORKDIR /app
CMD ["/bin/sh"]

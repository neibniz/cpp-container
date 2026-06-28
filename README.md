# C/C++ Container Images

This repository builds C/C++ development, build, and runtime images for GCC and
Clang. The images support `linux/amd64` and `linux/arm64`.

## Image Targets

| Target | Purpose |
| --- | --- |
| `gcc-build` | GCC build image with Git, Make, CMake, Ninja, uv, Python, Conan 2, Bazel, buf, GCC/G++, GDB, and perf |
| `clang-build` | Clang build image with Git, Make, CMake, Ninja, uv, Python, Conan 2, Bazel, buf, Clang, LLDB, and perf |
| `gcc-dev` | GCC development image with SSH, aliases, sudo, Buildifier, clangd, GDB, and perf |
| `clang-dev` | Clang development image with SSH, aliases, sudo, Buildifier, clangd, LLDB, and perf |
| `gcc-runtime` | Minimal runtime image for GCC/libstdc++ binaries, including libatomic and OpenMP runtime libraries |
| `clang-runtime` | Minimal runtime image for Clang binaries using libstdc++, including libatomic and OpenMP runtime libraries |
| `bazel-build` | Minimal Bazel runner image for hermetic toolchain validation; includes Bazelisk, buf, and Buildifier, but no GCC or Clang compiler |
| `bazel-dev` | Bazel development image with SSH, aliases, sudo, clangd, buf, and Buildifier, but no GCC or Clang compiler |

## Versions

| Tool | Version |
| --- | --- |
| Base image | `debian:trixie-slim` |
| GCC/G++ | Debian `gcc-14` / `g++-14` |
| Clang/LLDB | Debian `clang-19` / `lldb-19` |
| clangd | Debian `clangd-19`, development images only |
| CMake | `4.3.4` |
| uv | `0.11.23` |
| Python | `3.14`, installed by uv |
| Conan | `2.29.1`, installed by uv |
| Bazel | Bazelisk `1.29.0`, project Bazel `.bazelversion` `9.1.1` |
| buf | `1.71.0` |
| Buildifier | `8.5.1`, development and Bazel runner images |

Downloaded CMake, uv, Bazelisk, buf, and Buildifier release assets are verified
with pinned SHA-256 checksums during image builds.

## Build Locally

Build a native image:

```bash
docker build --target gcc-dev -t gcc-dev:local .
```

Build multi-platform images:

```bash
docker buildx build \
  --platform linux/amd64,linux/arm64 \
  --target gcc-dev \
  -t gcc-dev:local .
```

Build with Bake:

```bash
docker buildx bake gcc-dev-local
```

The `*-local` Bake targets build one platform and load the image into the local
Docker engine with names like `gcc-dev:local` and `clang-build:local`. They
default to `linux/amd64`; set `LOCAL_PLATFORM=linux/arm64` on ARM hosts. The
non-local Bake targets build the full `linux/amd64` and `linux/arm64` manifest
set for pushing. Set `VERSION=<tag-or-sha>` when you want a non-local version
tag, and `IMAGE_PREFIX=ghcr.io/<owner>/` when you want registry-qualified names.

## Development SSH Access

The development images create a `dev` user and run `sshd` by default.

```bash
docker run -d \
  --name cpp-dev \
  -p 2222:22 \
  -v "$PWD":/workspace \
  -v "$HOME/.ssh/authorized_keys":/home/dev/.ssh/authorized_keys:ro \
  gcc-dev:local
```

Connect with:

```bash
ssh -p 2222 dev@localhost
```

Password login is disabled by default. Use SSH keys.

## VS Code Dev Containers

The development images set `SHELL=/bin/bash` and load `/etc/profile.d/*.sh`
from `/etc/bash.bashrc`, `/root/.bashrc`, `/home/dev/.bashrc`, and
`/etc/skel/.bashrc`. This covers normal bash terminals and VS Code's bash shell
integration, including `bash --init-file ~/.bashrc`.

If your `devcontainer.json` overrides the integrated terminal shell, keep it on
bash for the image aliases:

```json
{
  "customizations": {
    "vscode": {
      "settings": {
        "terminal.integrated.defaultProfile.linux": "bash",
        "terminal.integrated.profiles.linux": {
          "bash": {
            "path": "/bin/bash"
          }
        }
      }
    }
  }
}
```

## Bazel Hermetic Runner Images

The `bazel-build` image is intentionally separate from `gcc-build` and
`clang-build`. It does not install `gcc`, `g++`, `clang`, or `clang++`, so Bazel
CI can detect accidental dependence on system compilers. It is intended for
Bazel-level hermetic C++ toolchains where compiler archives, sysroots, and
runtime libraries are declared by Bazel with fixed versions and checksums.

The `bazel-dev` image extends `bazel-build` with SSH, the `dev` user, aliases,
sudo, editor utilities, and `clangd` for language-server support. `clangd` is
for editor integration only; Bazel builds should still use explicit hermetic
toolchain configs.

Build and smoke-test the Bazel runner locally:

```bash
docker buildx bake bazel-build-local
docker run --rm -v "$PWD":/workspace -w /workspace bazel-build:local \
  bash -lc 'bazel --version && buf --version && buildifier --version && ! command -v gcc && ! command -v clang'
```

The repository includes `.bazelversion` to pin the Bazel version used by
Bazelisk. `.bazeliskrc` fails when no `.bazelversion` is present, and `.bazelrc`
requires the Bzlmod lockfile during builds. Full hermetic C++ compilation still
requires a Bazel `cc_toolchain` that declares the compiler, sysroot, linker, and
runtime libraries as Bazel inputs.

## GTest Examples

Run the CMake + Conan 2 example:

```bash
docker run --rm -v "$PWD":/workspace -w /workspace gcc-dev:local \
  bash examples/gtest-cmake-conan/build-test.sh
```

Run the Bazel example:

```bash
docker run --rm -v "$PWD":/workspace -w /workspace gcc-dev:local \
  bash examples/gtest-bazel/build-test.sh
```

Both examples run `buf lint` against `proto/` before building. They generate C++
from `proto/demo/v1/person.proto`, fill a `demo.v1.Person`, and print
`DebugString()` from the GTest binary. They build the test binary with
`SANITIZER=address-undefined` by default. Supported modes are:

| Mode | GCC | Clang |
| --- | --- | --- |
| `address` | yes | yes |
| `thread` | yes | yes |
| `undefined` | yes | yes |
| `address-undefined` | yes | yes |
| `memory` | no | yes |

Example:

```bash
docker run --rm -v "$PWD":/workspace -w /workspace clang-dev:local \
  bash -lc 'SANITIZER=thread bash examples/gtest-cmake-conan/build-test.sh'
```

For direct sanitizer runtime checks, run the standalone probe. It compiles a
clean binary and a binary expected to trigger each sanitizer:

```bash
docker run --rm -v "$PWD":/workspace -w /workspace clang-dev:local \
  bash examples/sanitizers/build-test.sh
```

The build and dev images include sanitizer runtime support. Runtime images stay
minimal and do not include sanitizer or libc++ packages by default.

## GHCR Publishing

GitHub Actions publishes all targets to:

```text
ghcr.io/<owner>/<target>:<short-sha>
ghcr.io/<owner>/<target>:<git-tag>
```

The workflow lowercases `ghcr.io/<owner>` before publishing so GHCR accepts
GitHub owners with uppercase letters. Target names become image names; versions
are tags.

For a commit build with short SHA `a1b2c3d4e5f6`, the workflow publishes:

```text
ghcr.io/example/gcc-build:a1b2c3d4e5f6
ghcr.io/example/clang-build:a1b2c3d4e5f6
ghcr.io/example/gcc-dev:a1b2c3d4e5f6
ghcr.io/example/clang-dev:a1b2c3d4e5f6
ghcr.io/example/gcc-runtime:a1b2c3d4e5f6
ghcr.io/example/clang-runtime:a1b2c3d4e5f6
ghcr.io/example/bazel-build:a1b2c3d4e5f6
ghcr.io/example/bazel-dev:a1b2c3d4e5f6
```

For tag `v1.0.0`, the same image names receive tag `v1.0.0`.

## perf Notes

The build and dev images include `linux-perf`, but container runtime permissions still
come from the host. You may need capabilities such as `PERFMON` or `SYS_ADMIN`
and a permissive host `perf_event_paranoid` setting.

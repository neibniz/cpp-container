#!/usr/bin/env bash

case "$-" in
  *i*) ;;
  *) return 0 2>/dev/null || exit 0 ;;
esac

alias ll='ls -alF'
alias la='ls -A'
alias l='ls -CF'
alias ..='cd ..'
alias ...='cd ../..'

alias grep='grep --color=auto'
alias df='df -h'
alias du='du -h'
alias free='free -h'

alias gs='git status'
alias ga='git add'
alias gc='git commit'
alias gco='git checkout'
alias gb='git branch'
alias gd='git diff'
alias gl='git log --oneline --graph --decorate'
alias gp='git pull'
alias gps='git push'

alias cmake-debug='cmake -S . -B build/debug -G Ninja -DCMAKE_BUILD_TYPE=Debug'
alias cmake-release='cmake -S . -B build/release -G Ninja -DCMAKE_BUILD_TYPE=Release'
alias ninja-debug='ninja -C build/debug'
alias ninja-release='ninja -C build/release'
alias ctest-debug='ctest --test-dir build/debug --output-on-failure'
alias ctest-release='ctest --test-dir build/release --output-on-failure'

alias py='python'
alias py3='python3'
alias conan-profile='conan profile detect --force'
alias bazel-version='bazel version'

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

alias b='bazel'
alias bb='bazel build'
alias bt='bazel test'
alias br='bazel run'
alias bq='bazel query'
alias bc='bazel clean'
alias bazel-version='bazel version'
alias buf-lint='buf lint'
alias buildifier-fix='buildifier -r .'

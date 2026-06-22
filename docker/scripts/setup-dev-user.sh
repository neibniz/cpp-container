#!/usr/bin/env bash
set -Eeuo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/common.sh"

: "${DEV_USER:=dev}"
: "${DEV_UID:=1000}"
: "${DEV_GID:=1000}"
: "${DEV_SUDO:=1}"

packages=(
  bash-completion
  less
  openssh-server
  procps
  sudo
  vim-tiny
)

apt_install "${packages[@]}"

if ! command -v vim >/dev/null 2>&1 && [[ -x /usr/bin/vim.tiny ]]; then
  ln -sf /usr/bin/vim.tiny /usr/local/bin/vim
fi

if ! getent group "${DEV_GID}" >/dev/null; then
  groupadd --gid "${DEV_GID}" "${DEV_USER}"
fi

group_name="$(getent group "${DEV_GID}" | cut -d: -f1)"
if ! id -u "${DEV_USER}" >/dev/null 2>&1; then
  useradd --uid "${DEV_UID}" --gid "${group_name}" --create-home --shell /bin/bash "${DEV_USER}"
fi

mkdir -p /workspace "/home/${DEV_USER}/.ssh"
touch "/home/${DEV_USER}/.ssh/authorized_keys"
chmod 0700 "/home/${DEV_USER}/.ssh"
chmod 0600 "/home/${DEV_USER}/.ssh/authorized_keys"
chown -R "${DEV_USER}:${group_name}" "/home/${DEV_USER}" /workspace

cat > "/home/${DEV_USER}/.bashrc" <<'EOF'
if [ -d /etc/profile.d ]; then
  for script in /etc/profile.d/*.sh; do
    [ -r "$script" ] && . "$script"
  done
fi
EOF

cat > "/home/${DEV_USER}/.bash_profile" <<'EOF'
if [ -r ~/.bashrc ]; then
  . ~/.bashrc
fi
EOF
chown "${DEV_USER}:${group_name}" "/home/${DEV_USER}/.bashrc" "/home/${DEV_USER}/.bash_profile"

if [[ "${DEV_SUDO}" == "1" ]]; then
  printf '%s ALL=(ALL) NOPASSWD:ALL\n' "${DEV_USER}" > "/etc/sudoers.d/${DEV_USER}"
  chmod 0440 "/etc/sudoers.d/${DEV_USER}"
fi

clean_caches

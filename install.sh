#!/usr/bin/env bash
# Symlink agents/ and skills/ from this repo into ~/.claude/.
# Usage: ./install.sh [--uninstall]

set -euo pipefail

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CLAUDE_DIR="${HOME}/.claude"
MODE="install"

if [[ "${1:-}" == "--uninstall" ]]; then
  MODE="uninstall"
fi

link_dir() {
  local src_subdir="$1"
  local dest_dir="${CLAUDE_DIR}/${src_subdir}"
  mkdir -p "${dest_dir}"

  # Symlink every entry (file or directory) at the top of src_subdir into dest_dir.
  shopt -s nullglob dotglob
  for entry in "${REPO_DIR}/${src_subdir}"/*; do
    local name
    name="$(basename "${entry}")"
    local target="${dest_dir}/${name}"

    if [[ "${MODE}" == "uninstall" ]]; then
      # Only remove if it points into this repo — never touch unrelated files.
      if [[ -L "${target}" ]] && [[ "$(readlink "${target}")" == "${entry}" ]]; then
        rm "${target}"
        echo "removed  ${target}"
      fi
      continue
    fi

    if [[ -e "${target}" ]] || [[ -L "${target}" ]]; then
      if [[ -L "${target}" ]] && [[ "$(readlink "${target}")" == "${entry}" ]]; then
        echo "ok       ${target}"
        continue
      fi
      echo "skip     ${target} (exists and is not our symlink)" >&2
      continue
    fi

    ln -s "${entry}" "${target}"
    echo "linked   ${target} -> ${entry}"
  done
  shopt -u nullglob dotglob
}

link_dir agents
link_dir skills

echo
if [[ "${MODE}" == "install" ]]; then
  echo "Done. Restart Claude Code (or /agents) to pick up changes."
else
  echo "Uninstall complete."
fi

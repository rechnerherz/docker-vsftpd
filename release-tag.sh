#!/usr/bin/env bash
set -e

prompt() {
  echo -n "$1"
  while true; do
    read -r -p " [Y/n/q] " choice
    case "$choice" in
      y|Y|"") return 0 ;;
      n|N) return 1 ;;
      q|Q) echo "Abort."; exit 0 ;;
      *) echo -n "Invalid response." ;;
    esac
  done
}

dir=$( cd "$(dirname "${BASH_SOURCE[0]}")" ; pwd -P )

read -r -e -p "Version number (major.minor.patch(-note)): " version

if ! [[ "$version" =~ ^[0-9]+\.[0-9]+\.[0-9](-[0-9a-z])?$ ]]; then
  echo "Version should be major.minor.patch(-note)"
  exit 1
fi

tag="v$version"

if prompt "Add tag $tag?"; then
  git tag -am "$tag" "$tag"
fi

#!/bin/sh

set -eu

REPOSITORY="ventstream/ventstream-releases"
INSTALL_DIR="${VENTSTREAMCTL_INSTALL_DIR:-$HOME/.local/bin}"
REQUESTED_VERSION="${VENTSTREAMCTL_VERSION:-latest}"

fail() {
  printf 'ventstreamctl installer: %s\n' "$*" >&2
  exit 1
}

command_exists() {
  command -v "$1" >/dev/null 2>&1
}

require_command() {
  command_exists "$1" || fail "required command not found: $1"
}

cleanup() {
  if [ -n "${TEMP_DIR:-}" ] && [ -d "$TEMP_DIR" ]; then
    rm -rf "$TEMP_DIR"
  fi
}

normalize_version() {
  value=$1
  value=${value#v}
  case "$value" in
    ''|*[!0-9.]*|.*|*.|*..*) fail "invalid version: $1" ;;
  esac

  component_count=$(printf '%s\n' "$value" | awk -F. '{print NF}')
  [ "$component_count" -eq 3 ] ||
    fail "version must use MAJOR.MINOR.PATCH format"

  printf '%s\n' "$value"
}

resolve_latest_version() {
  effective_url=$(
    curl --fail --silent --show-error --location \
      --retry 3 --retry-delay 1 --retry-all-errors \
      --output /dev/null --write-out '%{url_effective}' \
      "https://github.com/$REPOSITORY/releases/latest"
  ) || fail "could not resolve the latest release"

  tag=${effective_url##*/}
  [ "$tag" != "latest" ] || fail "the repository has no published release"
  normalize_version "$tag"
}

detect_target() {
  case "$(uname -s)" in
    Darwin) TARGET_OS=darwin ;;
    Linux) TARGET_OS=linux ;;
    *) fail "unsupported operating system: $(uname -s)" ;;
  esac

  case "$(uname -m)" in
    x86_64|amd64) TARGET_ARCH=amd64 ;;
    arm64|aarch64) TARGET_ARCH=arm64 ;;
    *) fail "unsupported architecture: $(uname -m)" ;;
  esac
}

download() {
  source_url=$1
  destination=$2
  curl --fail --silent --show-error --location \
    --retry 3 --retry-delay 1 --retry-all-errors \
    --proto '=https' --tlsv1.2 \
    --output "$destination" "$source_url"
}

verify_checksum() {
  expected=$(
    awk -v asset="$ASSET_NAME" '
      $2 == asset || $2 == "*" asset || $2 == "./" asset {
        print $1
        count++
      }
      END {
        if (count != 1) {
          exit 1
        }
      }
    ' "$CHECKSUM_FILE"
  ) || fail "SHA256SUMS does not contain exactly one checksum for $ASSET_NAME"

  case "$expected" in
    ????????????????????????????????????????????????????????????????) ;;
    *) fail "invalid SHA-256 value for $ASSET_NAME" ;;
  esac

  if command_exists sha256sum; then
    actual=$(sha256sum "$ARCHIVE_FILE" | awk '{print $1}')
  elif command_exists shasum; then
    actual=$(shasum -a 256 "$ARCHIVE_FILE" | awk '{print $1}')
  else
    fail "sha256sum or shasum is required to verify the download"
  fi

  [ "$actual" = "$expected" ] || fail "checksum verification failed for $ASSET_NAME"
}

verify_archive() {
  archive_entries=$(tar -tzf "$ARCHIVE_FILE") ||
    fail "could not inspect $ASSET_NAME"
  [ "$archive_entries" = "ventstreamctl" ] ||
    fail "$ASSET_NAME contains unexpected files"
}

install_binary() {
  tar -xzf "$ARCHIVE_FILE" -C "$TEMP_DIR" ventstreamctl ||
    fail "could not extract ventstreamctl"
  [ -f "$TEMP_DIR/ventstreamctl" ] ||
    fail "archive did not contain ventstreamctl"

  chmod 755 "$TEMP_DIR/ventstreamctl"
  reported_version=$("$TEMP_DIR/ventstreamctl" --version 2>/dev/null) ||
    fail "downloaded binary did not execute"
  case "$reported_version" in
    *"$VERSION"*) ;;
    *) fail "binary version did not match requested version $VERSION" ;;
  esac

  mkdir -p "$INSTALL_DIR"
  [ -d "$INSTALL_DIR" ] || fail "install path is not a directory: $INSTALL_DIR"
  [ -w "$INSTALL_DIR" ] || fail "install directory is not writable: $INSTALL_DIR"

  destination="$INSTALL_DIR/ventstreamctl"
  staged="$INSTALL_DIR/.ventstreamctl.new.$$"
  cp "$TEMP_DIR/ventstreamctl" "$staged"
  chmod 755 "$staged"
  mv -f "$staged" "$destination"

  printf 'Installed ventstreamctl %s to %s\n' "$VERSION" "$destination"
  case ":${PATH:-}:" in
    *":$INSTALL_DIR:"*) ;;
    *)
      printf 'Add %s to PATH before running ventstreamctl.\n' "$INSTALL_DIR"
      ;;
  esac
}

require_command curl
require_command tar
require_command awk
require_command uname
require_command mktemp

detect_target
if [ "$REQUESTED_VERSION" = "latest" ]; then
  VERSION=$(resolve_latest_version)
else
  VERSION=$(normalize_version "$REQUESTED_VERSION")
fi

TAG="v$VERSION"
ASSET_NAME="ventstreamctl-$VERSION-$TARGET_OS-$TARGET_ARCH.tar.gz"
RELEASE_URL="https://github.com/$REPOSITORY/releases/download/$TAG"

TEMP_DIR=$(mktemp -d "${TMPDIR:-/tmp}/ventstreamctl.XXXXXXXX") ||
  fail "could not create a temporary directory"
trap cleanup EXIT HUP INT TERM

ARCHIVE_FILE="$TEMP_DIR/$ASSET_NAME"
CHECKSUM_FILE="$TEMP_DIR/SHA256SUMS"

download "$RELEASE_URL/$ASSET_NAME" "$ARCHIVE_FILE" ||
  fail "could not download $ASSET_NAME"
download "$RELEASE_URL/SHA256SUMS" "$CHECKSUM_FILE" ||
  fail "could not download SHA256SUMS"

verify_checksum
verify_archive
install_binary

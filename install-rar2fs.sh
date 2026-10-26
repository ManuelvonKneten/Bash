#!/usr/bin/env bash
# Installiert rar2fs mit statisch eingebundener UnRAR-Bibliothek auf Debian.
set -Eeuo pipefail

RAR2FS_VERSION="${RAR2FS_VERSION:-1.29.4}"
UNRAR_VERSION="${UNRAR_VERSION:-6.0.3}"
UNRAR_SHA256="1def53392d879f9e304aa6eac1339cf41f9bce1111a2f5845071665738c4aca0"
BUILD_DIR=""

log() { printf '\n[rar2fs] %s\n' "$*"; }
fail() { printf '[rar2fs] FEHLER: %s\n' "$*" >&2; exit 1; }
cleanup() {
  if [[ -n "$BUILD_DIR" && -d "$BUILD_DIR" ]]; then
    rm -rf -- "$BUILD_DIR"
  fi
}
trap cleanup EXIT
trap 'printf "[rar2fs] Fehler in Zeile %s (Exit %s)\n" "$LINENO" "$?" >&2' ERR

[[ $EUID -eq 0 ]] || fail "Bitte mit sudo oder als root ausfuehren."
[[ -f /etc/os-release ]] || fail "Linux-Distribution konnte nicht erkannt werden."
# shellcheck disable=SC1091
source /etc/os-release
[[ "${ID:-}" == "debian" || " ${ID_LIKE:-} " == *" debian "* ]] || fail "Dieses Skript unterstuetzt Debian-basierte Systeme."
[[ "$RAR2FS_VERSION" =~ ^[0-9]+\.[0-9]+\.[0-9]+$ ]] || fail "Ungueltige rar2fs-Version."
[[ "$UNRAR_VERSION" =~ ^[0-9]+\.[0-9]+\.[0-9]+$ ]] || fail "Ungueltige UnRAR-Version."

log "Installiere Build-Abhaengigkeiten (FUSE 2 API) ..."
export DEBIAN_FRONTEND=noninteractive
apt-get update
apt-get install -y --no-install-recommends \
  build-essential ca-certificates curl libfuse-dev fuse3 pkg-config

BUILD_DIR="$(mktemp -d /tmp/rar2fs-build.XXXXXXXX)"
cd "$BUILD_DIR"

log "Lade UnRAR ${UNRAR_VERSION} ..."
curl --fail --location --retry 3 --proto '=https' --tlsv1.2 \
  "https://www.rarlab.com/rar/unrarsrc-${UNRAR_VERSION}.tar.gz" \
  --output unrar.tar.gz
if [[ "$UNRAR_VERSION" == "6.0.3" ]]; then
  printf '%s  %s\n' "$UNRAR_SHA256" unrar.tar.gz | sha256sum --check --status \
    || fail "UnRAR-Download hat die SHA256-Pruefung nicht bestanden."
else
  log "ACHTUNG: Fuer UnRAR ${UNRAR_VERSION} ist kein Hash hinterlegt."
fi
tar -xzf unrar.tar.gz
[[ -f unrar/makefile ]] || fail "UnRAR-Quellcode fehlt."

log "Kompiliere statische UnRAR-Bibliothek ..."
# UnRAR 6.0.3 erzeugt libunrar.so und libunrar.a mit dem Target "lib".
# Kein -j: Das Makefile nennt "clean" und Objektdateien als parallele Abhaengigkeiten.
make -C unrar lib
[[ -s unrar/libunrar.a ]] || fail "libunrar.a wurde nicht erzeugt."

log "Lade rar2fs ${RAR2FS_VERSION} ..."
curl --fail --location --retry 3 --proto '=https' --tlsv1.2 \
  "https://github.com/hasse69/rar2fs/releases/download/v${RAR2FS_VERSION}/rar2fs-${RAR2FS_VERSION}.tar.gz" \
  --output rar2fs.tar.gz
tar -xzf rar2fs.tar.gz
RAR2FS_SRC="$BUILD_DIR/rar2fs-${RAR2FS_VERSION}"
[[ -x "$RAR2FS_SRC/configure" ]] || fail "rar2fs-Quellcode oder configure fehlt."

log "Konfiguriere und kompiliere rar2fs ..."
cd "$RAR2FS_SRC"
./configure --prefix=/usr/local --with-unrar="$BUILD_DIR/unrar" --enable-static-unrar
make -j "$(nproc)"
make install

log "Installation abgeschlossen."
if [[ -x /usr/local/bin/rar2fs ]]; then
  /usr/local/bin/rar2fs --version || true
  printf 'Binary: /usr/local/bin/rar2fs\n'
else
  command -v rar2fs || fail "rar2fs wurde nicht im PATH gefunden."
fi
printf '\nBeispiel: rar2fs -o ro /pfad/zu/archiven /pfad/zum/mountpunkt\n'

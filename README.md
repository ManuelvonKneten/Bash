# Bash

A collection of useful Bash scripts for Linux — mainly for installation,
setup, and maintenance tasks that come up again and again.

## Scripts

### `install-rar2fs.sh`

Installs [rar2fs](https://github.com/hasse69/rar2fs) on Debian-based
systems, including a statically linked UnRAR library.

- Checks that the script is run as root and on a Debian-based distribution
- Installs the build dependencies (FUSE 2 API) via `apt-get`
- Downloads UnRAR and rar2fs in the requested versions, verifies the
  download via SHA256 (for the default version), and builds them together
  statically
- Installs the resulting `rar2fs` binary to `/usr/local/bin`

**Usage:**

```bash
sudo ./install-rar2fs.sh
```

Versions can be customized via environment variables:

```bash
sudo RAR2FS_VERSION=1.29.4 UNRAR_VERSION=6.0.3 ./install-rar2fs.sh
```

**Example after installation:**

```bash
rar2fs -o ro /path/to/archives /path/to/mountpoint
```

## Usage

Each script is self-contained and executable. Take a quick look at a
script before running it to understand what it does, especially when it
runs with `sudo`/root privileges.

## Contributing

New scripts simply get added to this repo as a new file, with a short
entry added to this README.

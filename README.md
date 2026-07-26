# VentStream releases

This repository is the official distribution point for `ventstreamctl`. It
contains installation tooling, release checksums, software bills of materials
(SBOMs), and immutable GitHub releases.

## Install

Install the latest CLI on macOS or Linux:

```sh
curl -fsSL https://raw.githubusercontent.com/ventstream/ventstream-releases/main/install.sh | sh
```

The installer writes to `$HOME/.local/bin` by default. It does not invoke
`sudo`, edit shell profiles, or send GitHub credentials.

Install a specific version:

```sh
curl -fsSL https://raw.githubusercontent.com/ventstream/ventstream-releases/main/install.sh |
  VENTSTREAMCTL_VERSION=0.2.8 sh
```

Choose another destination:

```sh
curl -fsSL https://raw.githubusercontent.com/ventstream/ventstream-releases/main/install.sh |
  VENTSTREAMCTL_INSTALL_DIR="$HOME/bin" sh
```

For a security-sensitive installation, inspect the script before running it:

```sh
curl -fsSLo install-ventstreamctl.sh \
  https://raw.githubusercontent.com/ventstream/ventstream-releases/main/install.sh
less install-ventstreamctl.sh
sh install-ventstreamctl.sh
rm install-ventstreamctl.sh
```

You can also pin both the installer source and binary version:

```sh
curl -fsSL \
  https://raw.githubusercontent.com/ventstream/ventstream-releases/v0.2.8/install.sh |
  VENTSTREAMCTL_VERSION=0.2.8 sh
```

Windows users can download the versioned AMD64 ZIP from
[GitHub Releases](https://github.com/ventstream/ventstream-releases/releases).

## Verification

The installer verifies the selected archive against the release's
`SHA256SUMS` before extraction. Published releases are immutable: GitHub locks
their tag and assets and generates a release attestation.

See [docs/verification.md](docs/verification.md) for manual verification.

Security issues must be reported as described in [SECURITY.md](SECURITY.md).

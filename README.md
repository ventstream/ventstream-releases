# VentStream releases

This repository is the public, binary-only distribution point for
`ventstreamctl`. It contains installation tooling, release checksums, software
bills of materials (SBOMs), and immutable GitHub releases.

The Fleet control-plane source remains private. The VentStream engine source is
available from [ventstream/ventstream](https://github.com/ventstream/ventstream).
Publishing a binary here does not grant a license to private source code.

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

Windows users can download the versioned AMD64 ZIP from
[GitHub Releases](https://github.com/ventstream/ventstream-releases/releases).

## Verification

The installer verifies the selected archive against the release's
`SHA256SUMS` before extraction. Published releases are immutable: GitHub locks
their tag and assets and generates a release attestation.

See [docs/verification.md](docs/verification.md) for manual verification.

## Scope

This repository deliberately contains no control-plane implementation,
deployment credentials, customer configuration, or private build reports.
Release promotion is documented in [docs/promotion.md](docs/promotion.md).

Security issues must be reported privately as described in
[SECURITY.md](SECURITY.md).

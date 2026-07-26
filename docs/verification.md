# Verify a release

Every release includes:

- Platform-specific `ventstreamctl` archives.
- An SPDX JSON SBOM for each archive.
- `SHA256SUMS` covering every uploaded distribution artifact and the release
  manifest.
- `release-manifest.json` recording the Fleet and engine revisions.
- A GitHub release attestation created when the immutable release is published.

## Verify a downloaded archive

Download the archive and `SHA256SUMS` from the same release. On macOS:

```sh
VERSION=0.2.8
ASSET="ventstreamctl-${VERSION}-darwin-arm64.tar.gz"
BASE="https://github.com/ventstream/ventstream-releases/releases/download/v${VERSION}"

curl -fsSLO "$BASE/$ASSET"
curl -fsSLO "$BASE/SHA256SUMS"
grep " $ASSET\$" SHA256SUMS | shasum -a 256 -c -
```

On Linux, replace the final command with:

```sh
grep " $ASSET\$" SHA256SUMS | sha256sum -c -
```

## Verify GitHub release integrity

With a current GitHub CLI:

```sh
gh release verify v0.2.8 --repo ventstream/ventstream-releases
gh release verify-asset v0.2.8 \
  ventstreamctl-0.2.8-darwin-arm64.tar.gz \
  --repo ventstream/ventstream-releases
```

The first command confirms the release is immutable and its attestation is
valid. The second confirms that the local archive exactly matches the attested
release asset.

## Inspect an SBOM

The SBOM file name matches its archive with `.spdx.json` in place of the archive
extension. It can be inspected directly as JSON or with an SPDX-compatible
scanner.

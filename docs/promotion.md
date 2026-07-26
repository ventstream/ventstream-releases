# Release promotion

`ventstream-releases` is a distribution boundary, not a build repository. The
private Fleet release remains the source of CLI binaries.

## Required promotion contract

For each version:

1. Fleet CI builds `ventstreamctl` for the supported targets.
2. Fleet CI tests the binaries and produces an SPDX JSON SBOM per target.
3. The private Fleet release is reviewed and published.
4. A promoter verifies the private release signature, attestation, version,
   commit, checksums, and required assets.
5. The promoter creates a draft release in this repository using the same
   semantic version.
6. Only the five CLI archives, their five SBOMs, a sanitized release manifest,
   and `SHA256SUMS` are attached.
7. The draft is checked for missing or unexpected assets.
8. The draft is published once. Repository release immutability then locks its
   tag and assets and creates the public release attestation.

Never copy control-plane images, Helm charts, customer data, credentials,
private vulnerability reports, or internal build logs into this repository.

## Automation boundary

Future private-to-public automation must use a GitHub App installation token
with access limited to:

- Read releases and metadata in the private Fleet repository.
- Create releases and upload assets in this repository.

Do not use a personal access token, long-lived organization secret, or a token
with source write access. The promotion workflow must use an environment,
version/tag validation, a fixed artifact allowlist, and immutable draft-first
publication.

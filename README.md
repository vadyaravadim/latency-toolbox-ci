# latency-toolbox-ci

The shared CI and release pipeline of the six RigPolice Latency Toolbox scripts:
[cpu-parking-disabler](https://github.com/vadyaravadim/cpu-parking-disabler),
[msi-mode-utility](https://github.com/vadyaravadim/msi-mode-utility),
[remove-hidden-devices](https://github.com/vadyaravadim/remove-hidden-devices),
[gamedvr-fso-disabler](https://github.com/vadyaravadim/gamedvr-fso-disabler),
[timer-resolution-utility](https://github.com/vadyaravadim/timer-resolution-utility) and
[interrupt-affinity-utility](https://github.com/vadyaravadim/interrupt-affinity-utility). Each of them calls
`.github/workflows/pipeline.yml` from two thin workflows,
pinned to the full SHA of a tagged commit here:

- `ci.yml`, on every push and pull request: PSScriptAnalyzer, the ASCII check, and Pester under Windows
  PowerShell 5.1, the runner's PowerShell and a pinned preview (skipped when the repository has no
  `*.Tests.ps1`), with `contents: read`.
- `release.yml`, run by hand on `main`: the same checks on the same commit, then the release - the version
  from the newest CHANGELOG section, checksums, build provenance, the PowerShell Gallery and, last, the
  GitHub Release that creates the tag. It grants `contents: write` (the release and its files), `id-token:
  write` (the Sigstore signature) and `attestations: write` (the attestation), and passes the secret
  `NUGET_API_KEY`, the PowerShell Gallery key, which each repository keeps in its `release` environment, open
  to `main` only.

`PSScriptAnalyzerSettings.psd1` is the family's settings file. Every repository keeps an identical copy,
and lint fails when its copy differs from the one at the pinned commit.

A change here reaches a repository only when its pin moves. Release a version here after `ci` is green
(`gh release create vX.Y.Z --target <commit> --title vX.Y.Z --notes "<what changed>"`), then bump the SHA in
both workflows of each repository together - lint fails while they differ; Dependabot proposes the bump
monthly. Do not rename this repository: every caller would break.

## The signer of every release

This repository's `pipeline.yml` signs the build provenance of every script release it builds, so the
signer to check is this workflow, not the script's repository:

```powershell
gh attestation verify .\<script>.ps1 -R vadyaravadim/<script> --signer-workflow vadyaravadim/latency-toolbox-ci/.github/workflows/pipeline.yml
```

Each script's `SECURITY.md` says which of its releases were built here and leads with the check that works
for all of them. What changed in each version is in [CHANGELOG.md](CHANGELOG.md); report a problem with
the pipeline as [SECURITY.md](SECURITY.md) describes.

## License

[MIT](LICENSE).

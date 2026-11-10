# latency-toolbox-ci

The shared CI and release pipeline of the six RigPolice Latency Toolbox scripts: cpu-parking-disabler,
msi-mode-utility, remove-hidden-devices, gamedvr-fso-disabler, timer-resolution-utility and
interrupt-affinity-utility. Each of them calls `.github/workflows/pipeline.yml` from two thin workflows,
pinned to the full SHA of a tagged commit here:

- `ci.yml`, on every push and pull request: PSScriptAnalyzer, the ASCII check, and Pester under Windows
  PowerShell 5.1, the runner's PowerShell and a pinned preview (skipped when the repository has no
  `*.Tests.ps1`).
- `release.yml`, run by hand on `main`: the same checks on the same commit, then the release - the version
  from the newest CHANGELOG section, checksums, build provenance, the PowerShell Gallery and, last, the
  GitHub Release that creates the tag.

`PSScriptAnalyzerSettings.psd1` is the family's settings file. Every repository keeps an identical copy,
and lint fails when its copy differs from the one at the pinned commit.

A change here reaches a repository only when its pin moves. Release a version here after `ci` is green
(`gh release create vX.Y.Z --target <commit> --title vX.Y.Z --notes "<what changed>"`), then bump the SHA in
both workflows of each repository together - lint fails while they differ; Dependabot proposes the bump
monthly. Do not rename this repository: every caller would break.

# Changelog

All notable changes to the shared pipeline are documented here. The format follows
[Keep a Changelog](https://keepachangelog.com/en/1.1.0/), and this project adheres to
[Semantic Versioning](https://semver.org/spec/v2.0.0.html). A version reaches a script
repository only when that repository moves its pin to it; each release body is its section here.

## [1.1.0] - 2026-11-11

### Added

- The release job runs in the calling repository's `release` environment, so `NUGET_API_KEY` can live
  there, open to `main` only. A release run from another branch stops at the environment before any step.
- The release stops on a version lower than one already released (the highest `v*` tag), as it already
  did on a version that is released.
- Each release attaches its provenance bundle as `<script>.ps1.sigstore.json`, so the signature can be
  checked from the file itself, and OpenSSF Scorecard counts the release as signed.
- The release publishes with PowerShellGet 2.2.5 from its PowerShell Gallery package, checked against a
  pinned SHA512 and imported by path, instead of whichever PowerShellGet the runner image ships.

### Changed

- `GH_TOKEN` reaches only the two release steps that call `gh`, and no checkout keeps the token.
- Every job has a time limit (5 to 20 minutes) instead of the 6-hour default.
- The preview PowerShell zip is checked against a SHA256 pinned next to its version, not against a hash
  file from the same release.
- `PSScriptAnalyzerSettings.psd1`: the reasons of two exclusions now match the scripts; the rules are
  unchanged, so each script repo copies the file with the pin bump.

## [1.0.2] - 2026-11-10

Pester and PSScriptAnalyzer now come from their PowerShell Gallery packages, checked against a pinned SHA512 and imported by path, instead of `Install-Module`, which spent a median 106 s per run installing Pester under Windows PowerShell 5.1. In cpu-parking-disabler and msi-mode-utility the 5.1 Pester job went from a median of about 140-158 s to 42-59 s, and a whole ci run from about 144-161 s to 48-64 s. Pester moves from 5.7.1 to 5.9.1, and a download the Gallery blocks is retried 3 times, 20 s apart. `PSScriptAnalyzerSettings.psd1` is unchanged: a caller only moves its pin.

## [1.0.1] - 2026-11-10

The release job now stops when gh cannot tell whether the version already has a GitHub release (a network or auth error), instead of reading that failure as no release.

## [1.0.0] - 2026-11-10

First version: the lint, ASCII and Pester gates and the release job of the six script repos, as cpu-parking-disabler ran them after H1 and H2.

[1.1.0]: https://github.com/vadyaravadim/latency-toolbox-ci/compare/v1.0.2...v1.1.0
[1.0.2]: https://github.com/vadyaravadim/latency-toolbox-ci/compare/v1.0.1...v1.0.2
[1.0.1]: https://github.com/vadyaravadim/latency-toolbox-ci/compare/v1.0.0...v1.0.1
[1.0.0]: https://github.com/vadyaravadim/latency-toolbox-ci/releases/tag/v1.0.0

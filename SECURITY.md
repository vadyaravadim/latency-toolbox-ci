# Security Policy

## Reporting a Vulnerability

Please report security issues **privately** via
[GitHub Security Advisories](https://github.com/vadyaravadim/latency-toolbox-ci/security/advisories/new)
— not through a public issue.

Expect a first response within 7 days. If a fix is warranted, it ships as a new
tagged version here and reaches each script when its pin moves.

## Supported Versions

Only the latest tag receives fixes. The script repositories pin a full commit SHA, so
a fix reaches a script only after its pin is bumped to the new version.

## Scope

This repository runs the lint, ASCII and Pester gates and the release job of the six
RigPolice Latency Toolbox scripts:
[cpu-parking-disabler](https://github.com/vadyaravadim/cpu-parking-disabler),
[msi-mode-utility](https://github.com/vadyaravadim/msi-mode-utility),
[remove-hidden-devices](https://github.com/vadyaravadim/remove-hidden-devices),
[gamedvr-fso-disabler](https://github.com/vadyaravadim/gamedvr-fso-disabler),
[timer-resolution-utility](https://github.com/vadyaravadim/timer-resolution-utility) and
[interrupt-affinity-utility](https://github.com/vadyaravadim/interrupt-affinity-utility).
Its `pipeline.yml` signs their build provenance.

In scope:

- A way to make a release tag, publish or attest a file that does not match the
  tagged source of the calling repository
- A way to run the release job without its gates passing on the same commit
- Exposing `NUGET_API_KEY` or a write token to a push or pull_request run, or the key to a release run from a
  branch other than `main`
- Checksums, provenance or the PowerShell Gallery package not matching the tagged
  source

Out of scope:

- What a script does on a machine - that belongs to the script's own SECURITY.md

# latency-toolbox-ci

The shared CI and release pipeline of the six RigPolice Latency Toolbox scripts (cpu-parking-disabler,
msi-mode-utility, remove-hidden-devices, gamedvr-fso-disabler, timer-resolution-utility,
interrupt-affinity-utility). Each calls `.github/workflows/pipeline.yml` from two thin workflows: `ci.yml`
(push and pull request, `contents: read`) and `release.yml` (dispatch; `contents`, `id-token` and
`attestations` write; passes `NUGET_API_KEY`). Both are pinned to the same full SHA of a tagged commit here,
with the version as a comment. This repo runs its own pipeline too (`ci.yml` calls `./.github/workflows/pipeline.yml`).

**Nothing - tag, release, Gallery version, attestation - is written before every gate passed on the same
commit.** The `release` job `needs:` `psanalyzer`, `ascii` and `pester` and runs only on `workflow_dispatch`.
"Check the Gallery key is passed" stays the FIRST release step, before attest: `NUGET_API_KEY` has to be
`required: false` because `ci.yml` calls the same file without it, so this step is what makes a missing
mapping fail before anything is written.

**The `release` job declares no `permissions`: it takes the caller's grant.** A job that asks for more than
the caller grants fails the run at startup, and the docs do not exempt a job skipped by `if`.

**The Pester job skips at step level when the repo has no `*.Tests.ps1`, never at job level.** A skipped job
would skip the release too (`needs:`). Pester itself exits 1 on zero test files.

**Inside `pipeline.yml` the `github` context, `GITHUB_REPOSITORY`, `GITHUB_SHA` and `actions/checkout`'s
defaults are the caller's.** Files of this repo come only from the second checkout at
`job.workflow_repository` / `job.workflow_sha` into the `CENTRAL_DIR` path. A `./` path would resolve against
the caller's workspace.

**The script is `<repo name>.ps1`, taken from `github.event.repository.name`.** No per-repo input exists.

**`PSScriptAnalyzerSettings.psd1` is the family file.** Each script repo keeps a byte-identical copy and the
lint job compares it with this repo's at the pinned commit, so a change here ships with a copy into all six.
Lint also fails unless every call of this repo in the caller's workflows pins the commit the run uses, so
`ci.yml` and `release.yml` are bumped together; Dependabot proposes it monthly.

**The Pester preview leg (`7.7.0-rc.1`) is `continue-on-error`: red without blocking.** Nothing bumps that
pin - move it by hand: to the final release when it ships, and once `windows-latest` itself ships that
version, on to the next preview, or drop the leg if there is none.

**Release a version here only after `ci` is green on that commit AND a script repo branch pinned to it has
passed `ci` and a branch dispatch of its `release.yml` reached "Release only from main".** Then
`gh release create vX.Y.Z --target <sha> --title vX.Y.Z --notes "<what changed>"`. Tags are immutable (tag
ruleset plus immutable releases): a mistake is fixed by the next version, never a retag.

**Never rename or delete this repository.** GitHub does not redirect a renamed reusable workflow, so every
caller breaks.

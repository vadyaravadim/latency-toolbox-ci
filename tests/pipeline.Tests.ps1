BeforeDiscovery {
    $script:versionCases = @(
        @{ Case = 'is lower than the highest released version'; Tags = @('v1.0.0', 'v1.1.0'); Version = '1.0.1'; TagAtHead = $false; Released = $false; Highest = 'v1.1.0' }
        @{ Case = 'is lower in numeric order (1.9.0 after 1.10.0)'; Tags = @('v1.10.0'); Version = '1.9.0'; TagAtHead = $false; Released = $false; Highest = 'v1.10.0' }
        @{ Case = 'is already tagged at another commit'; Tags = @('v1.1.0'); Version = '1.1.0'; TagAtHead = $false; Released = $false; Highest = '' }
        @{ Case = 'is higher than every released version'; Tags = @('v1.0.0', 'v1.1.0'); Version = '1.2.0'; TagAtHead = $false; Released = $true; Highest = '' }
        @{ Case = 'is higher in numeric order (1.10.0 after 1.9.0)'; Tags = @('v1.9.0'); Version = '1.10.0'; TagAtHead = $false; Released = $true; Highest = '' }
        @{ Case = 'is the first release'; Tags = @(); Version = '1.0.0'; TagAtHead = $false; Released = $true; Highest = '' }
        @{ Case = 'follows a data release whose tag is not a version'; Tags = @('v1.0.0', 'bench-data-parking-retest'); Version = '1.0.1'; TagAtHead = $false; Released = $true; Highest = '' }
        @{ Case = 'is re-run with its tag already on this commit'; Tags = @('v1.0.0'); Version = '1.1.0'; TagAtHead = $true; Released = $true; Highest = '' }
    )
}

BeforeAll {
    $script:pipelinePath = Join-Path $PSScriptRoot '..\.github\workflows\pipeline.yml'
    $script:bash = if ($env:OS -eq 'Windows_NT') { Join-Path $env:ProgramFiles 'Git\bin\bash.exe' } else { (Get-Command bash).Source }

    function Get-StepRunScript {
        param([string]$StepName)
        $lines = @(Get-Content -LiteralPath $pipelinePath)
        $nameAt = -1
        for ($i = 0; $i -lt $lines.Count; $i++) {
            if ($lines[$i] -match "^\s*- name: $([regex]::Escape($StepName))\s*$") { $nameAt = $i; break }
        }
        if ($nameAt -lt 0) { throw "pipeline.yml has no step named '$StepName'" }
        $runAt = -1
        for ($i = $nameAt + 1; $i -lt $lines.Count; $i++) {
            if ($lines[$i] -match '^\s*- name: ') { break }
            if ($lines[$i] -match '^(\s*)run: \|\s*$') { $runAt = $i; $runIndent = $Matches[1].Length; break }
        }
        if ($runAt -lt 0) { throw "step '$StepName' has no 'run: |' block" }
        $body = [System.Collections.Generic.List[string]]::new()
        for ($i = $runAt + 1; $i -lt $lines.Count; $i++) {
            $line = $lines[$i]
            if ($line.Trim() -and ($line.Length - $line.TrimStart().Length) -le $runIndent) { break }
            $body.Add($line)
        }
        $indent = ($body | Where-Object { $_.Trim() } | ForEach-Object { $_.Length - $_.TrimStart().Length } | Measure-Object -Minimum).Minimum
        ($body | ForEach-Object { if ($_.Length -ge $indent) { $_.Substring($indent) } else { '' } }) -join "`n"
    }

    function Invoke-VersionCheck {
        param([string[]]$Tags, [string]$Version, [bool]$TagAtHead)
        $repo = Join-Path $TestDrive ([guid]::NewGuid().ToString('N'))
        New-Item -ItemType Directory -Path $repo | Out-Null
        $saved = @{ VERSION = $env:VERSION; TAG = $env:TAG; GITHUB_SHA = $env:GITHUB_SHA }
        Push-Location $repo
        try {
            git -c init.defaultBranch=main init -q
            git -c user.name=test -c user.email=test@example.com commit -q --allow-empty -m first
            foreach ($tag in $Tags) { git tag $tag }
            git -c user.name=test -c user.email=test@example.com commit -q --allow-empty -m second
            if ($TagAtHead) { git tag "v$Version" }
            $env:VERSION = $Version
            $env:TAG = "v$Version"
            $env:GITHUB_SHA = (git rev-parse HEAD)
            $checkFile = Join-Path $repo 'check.sh'
            $text = "gh() { echo 'release not found'; return 1; }`n" + (Get-StepRunScript 'Check the version is not released yet') + "`n"
            [System.IO.File]::WriteAllText($checkFile, $text)
            $ErrorActionPreference = 'Continue'
            $output = & $bash ($checkFile -replace '\\', '/') 2>&1 | Out-String
            [pscustomobject]@{ ExitCode = $LASTEXITCODE; Output = $output }
        } finally {
            Pop-Location
            foreach ($name in $saved.Keys) {
                if ($null -eq $saved[$name]) { Remove-Item -Path "env:$name" -ErrorAction SilentlyContinue }
                else { Set-Item -Path "env:$name" -Value $saved[$name] }
            }
        }
    }
}

Describe 'release job: the version check' {
    It 'lets the release through only when the version <Case>' -ForEach $versionCases {
        $result = Invoke-VersionCheck -Tags $Tags -Version $Version -TagAtHead $TagAtHead
        if ($Released) {
            $result.ExitCode | Should -Be 0 -Because $result.Output
        } else {
            $result.ExitCode | Should -Not -Be 0 -Because $result.Output
            if ($Highest) { $result.Output | Should -Match ([regex]::Escape($Highest)) }
        }
    }
}

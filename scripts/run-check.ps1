param(
    [string]$Url = '',
    [string]$Repository = 'Noveron88/iphone-safari-harness'
)
$ErrorActionPreference = 'Stop'
$root = Split-Path -Parent $PSScriptRoot
if ($Url -and $Url -notmatch '^https://[^/\s]+(?:/[^\s]*)?$') {
    throw 'HTTPS URL kell. A helyi probaoldalhoz hagyd uresen a -Url parametert.'
}

$started = [DateTimeOffset]::UtcNow.AddSeconds(-10)
$args = @('workflow', 'run', 'iphone-safari.yml', '--repo', $Repository, '--ref', 'main')
if ($Url) { $args += @('-f', "url=$Url") }
& gh @args
if ($LASTEXITCODE -ne 0) { throw 'Nem sikerult elinditani a GitHub workflow-t.' }

$run = $null
for ($attempt = 0; $attempt -lt 24 -and -not $run; $attempt++) {
    Start-Sleep -Seconds 5
    $json = & gh run list --repo $Repository --workflow iphone-safari.yml --event workflow_dispatch --limit 10 --json databaseId,createdAt,status
    if ($LASTEXITCODE -ne 0) { throw 'Nem sikerult lekerdezni a futasokat.' }
    $run = @($json | ConvertFrom-Json | Where-Object { [DateTimeOffset]::Parse($_.createdAt) -ge $started } | Sort-Object createdAt -Descending)[0]
}
if (-not $run) { throw 'A futas nem jelent meg ket percen belul a GitHubon.' }

$id = [string]$run.databaseId
Write-Output "GitHub futas: $id"
& gh run watch $id --repo $Repository --compact --interval 15 --exit-status
if ($LASTEXITCODE -ne 0) { throw "A Safari futas sikertelen: $id" }

$dest = Join-Path $root "artifacts\run-$id"
New-Item -ItemType Directory -Force -Path $dest | Out-Null
& gh run download $id --repo $Repository --name iphone-safari --dir $dest
if ($LASTEXITCODE -ne 0) { throw "Nem sikerult letolteni a kepet: $id" }
Write-Output "Kepernyokep: $(Join-Path $dest 'screenshot.png')"
Write-Output "Riport: $(Join-Path $dest 'report.json')"

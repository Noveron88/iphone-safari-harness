$ErrorActionPreference = 'Stop'
$missing = @()
foreach ($name in @('git', 'gh', 'claude', 'node')) {
    $found = Get-Command $name -ErrorAction SilentlyContinue
    if ($null -eq $found) {
        $missing += $name
        Write-Output "$name : hianyzik"
    } else {
        Write-Output "$name : $($found.Source)"
    }
}
if ($missing.Count -gt 0) { throw "Hianyzo eszkozok: $($missing -join ', ')" }
& gh auth status *> $null
if ($LASTEXITCODE -ne 0) { throw 'GitHub bejelentkezes hianyzik. Futtasd: gh auth login' }
Write-Output 'GitHub bejelentkezes: rendben'
$root = Split-Path -Parent $PSScriptRoot
foreach ($relative in @('demo/index.html', '.github/workflows/iphone-safari.yml', 'scripts/capture-safari.sh', 'scripts/run-check.ps1', 'scripts/run-modelagency.ps1', 'bin/cloudflared.exe')) {
    if (-not (Test-Path -LiteralPath (Join-Path $root $relative))) { throw "Hianyzik: $relative" }
}
Write-Output 'A helyi csomag es az elofeltetelek rendben vannak.'

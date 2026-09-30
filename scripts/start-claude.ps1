param([string]$ProjectPath = 'C:\Users\adria\projects\Model-Agency')
$ErrorActionPreference = 'Stop'
$root = Split-Path -Parent $PSScriptRoot
if (-not (Test-Path -LiteralPath (Join-Path $ProjectPath 'AGENTS.md'))) {
    throw "Nem talalom a Model-Agency projektet: $ProjectPath"
}
Set-Location -LiteralPath $root
& claude --add-dir $ProjectPath

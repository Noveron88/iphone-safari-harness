param([string]$ProjectPath = 'C:\Users\adria\projects\Model-Agency')
$ErrorActionPreference = 'Stop'
if (-not (Test-Path -LiteralPath (Join-Path $ProjectPath 'scripts\test-server.ps1'))) {
    throw "Nem talalom a Model-Agency projektet: $ProjectPath"
}
if (-not (Test-Path -LiteralPath (Join-Path $ProjectPath '.env.local'))) {
    throw 'Nincs .env.local. A projekt tesztszervere enelkul nem indul.'
}
$line = Select-String -LiteralPath (Join-Path $ProjectPath '.env.local') -Pattern '^NEXT_PUBLIC_SUPABASE_URL=' | Select-Object -First 1
if (-not $line) { throw 'Nem talalom a Supabase URL-t a .env.local fajlban.' }
if ($line.Line -match 'mqocoxrhjmcwjaazifzy') { throw 'A projekt eles adatbazishoz kapcsolodik. Nem inditok publikus alagutat.' }
Write-Output 'Model-Agency projekt: rendben; nem az eles adatbazist hasznalja.'

param(
    [string]$ProjectPath = 'C:\Users\adria\projects\Model-Agency',
    [string]$Page = '/'
)
$ErrorActionPreference = 'Stop'
$root = Split-Path -Parent $PSScriptRoot
$cloudflared = Join-Path $root 'bin\cloudflared.exe'
if (-not (Test-Path -LiteralPath $cloudflared)) { throw 'Hianyzik a bin\cloudflared.exe.' }
if (-not $Page.StartsWith('/')) { throw 'A -Page parameter / jellel kezdodjon.' }
& (Join-Path $PSScriptRoot 'check-modelagency.ps1') -ProjectPath $ProjectPath

$port = 3140
$probe = 'http://127.0.0.1:3140/'
$logDir = Join-Path $root 'artifacts\local-preview'
New-Item -ItemType Directory -Force -Path $logDir | Out-Null
$server = $null
$tunnel = $null
try {
    if (Get-NetTCPConnection -LocalPort $port -State Listen -ErrorAction SilentlyContinue) {
        throw 'A 3140-es port mar foglalt. Allitsd le a rajta futo tesztszervert, majd inditsd ujra ezt a scriptet.'
    }
    else {
        $serverScript = Join-Path $ProjectPath 'scripts\test-server.ps1'
        $server = Start-Process -FilePath 'powershell.exe' -ArgumentList @('-NoProfile', '-ExecutionPolicy', 'Bypass', '-File', ('"' + $serverScript + '"')) -WindowStyle Hidden -PassThru -RedirectStandardOutput (Join-Path $logDir 'server.out.log') -RedirectStandardError (Join-Path $logDir 'server.err.log')
        for ($i = 0; $i -lt 60; $i++) {
            if ($server.HasExited) { throw 'A Model-Agency tesztszervere leallt. Nezd meg az artifacts\local-preview\server.err.log fajlt.' }
            try { $null = Invoke-WebRequest -Uri $probe -UseBasicParsing -TimeoutSec 2; break } catch { Start-Sleep -Seconds 2 }
        }
        if ($i -ge 60) { throw 'A Model-Agency tesztszervere nem indult el ket percen belul.' }
    }

    $tunnelLog = Join-Path $logDir 'tunnel.err.log'
    $tunnel = Start-Process -FilePath $cloudflared -ArgumentList @('tunnel', '--url', $probe, '--no-autoupdate') -WindowStyle Hidden -PassThru -RedirectStandardOutput (Join-Path $logDir 'tunnel.out.log') -RedirectStandardError $tunnelLog
    $base = $null
    for ($i = 0; $i -lt 60 -and -not $base; $i++) {
        if ($tunnel.HasExited) { throw 'A Cloudflare alagut leallt. Nezd meg az artifacts\local-preview\tunnel.err.log fajlt.' }
        Start-Sleep -Seconds 2
        if (Test-Path -LiteralPath $tunnelLog) {
            $match = [regex]::Match((Get-Content -LiteralPath $tunnelLog -Raw), 'https://[a-z0-9-]+\.trycloudflare\.com')
            if ($match.Success) { $base = $match.Value }
        }
    }
    if (-not $base) { throw 'Nem kaptam Cloudflare URL-t ket percen belul.' }
    $url = $base.TrimEnd('/') + $Page
    Write-Output "Ideiglenes tesztoldal: $url"
    & (Join-Path $PSScriptRoot 'run-check.ps1') -Url $url
}
finally {
    foreach ($process in @($tunnel, $server)) {
        if ($process -and -not $process.HasExited) {
            & taskkill.exe /PID $process.Id /T /F *> $null
        }
    }
}

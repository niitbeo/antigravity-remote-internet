param(
    [int]$Port = 4317,
    [string]$SettingsPath = "",
    [switch]$SkipInstall
)

$ErrorActionPreference = 'Stop'

function Resolve-TailscaleExe {
    $cmd = Get-Command tailscale -ErrorAction SilentlyContinue
    if ($cmd -and $cmd.Path) {
        return $cmd.Path
    }

    $candidates = @(
        'C:\\Program Files\\Tailscale\\tailscale.exe',
        'C:\\Program Files (x86)\\Tailscale\\tailscale.exe'
    )

    foreach ($item in $candidates) {
        if (Test-Path $item) {
            return $item
        }
    }

    return $null
}

function Ensure-TailscaleInstalled {
    param([switch]$NoInstall)

    $exe = Resolve-TailscaleExe
    if ($exe) {
        return $exe
    }

    if ($NoInstall) {
        throw 'tailscale not found. Install Tailscale first.'
    }

    Write-Host 'Installing Tailscale via winget...' -ForegroundColor Yellow
    winget install Tailscale.Tailscale --accept-package-agreements --accept-source-agreements | Out-Host

    $exe = Resolve-TailscaleExe
    if (-not $exe) {
        throw 'Tailscale installed but tailscale.exe was not found. Please restart shell and try again.'
    }

    return $exe
}

function Ensure-LoggedIn {
    param([string]$TailscaleExe)

    $jsonRaw = & $TailscaleExe status --json 2>$null
    if (-not $jsonRaw) {
        throw "Cannot read Tailscale status. Run: `"$TailscaleExe`" status"
    }

    $status = $jsonRaw | ConvertFrom-Json
    $loginName = $status.Self.LoginName
    if ([string]::IsNullOrWhiteSpace($loginName)) {
        Write-Host 'Tailscale is not logged in. Running tailscale up...' -ForegroundColor Yellow
        & $TailscaleExe up | Out-Host

        $jsonRaw = & $TailscaleExe status --json 2>$null
        $status = $jsonRaw | ConvertFrom-Json
        $loginName = $status.Self.LoginName
        if ([string]::IsNullOrWhiteSpace($loginName)) {
            throw 'Tailscale login is required. Please finish login, then rerun this script.'
        }
    }
}

function Resolve-SettingsPath {
    param([string]$ExplicitPath)

    if ($ExplicitPath -and $ExplicitPath.Trim().Length -gt 0) {
        return ,$ExplicitPath
    }

    $appData = $env:APPDATA
    return @(
        (Join-Path $appData 'Antigravity\\User\\settings.json'),
        (Join-Path $appData 'Cursor\\User\\settings.json'),
        (Join-Path $appData 'Code\\User\\settings.json')
    )
}

function Ensure-SettingsObject {
    param([string]$Path)

    if (-not (Test-Path $Path)) {
        $dir = Split-Path -Parent $Path
        if (-not (Test-Path $dir)) {
            New-Item -Path $dir -ItemType Directory -Force | Out-Null
        }
        '{}' | Set-Content -Path $Path -Encoding UTF8
    }

    $raw = Get-Content -Path $Path -Raw
    if (-not $raw.Trim()) {
        $raw = '{}'
    }

    try {
        return ($raw | ConvertFrom-Json)
    } catch {
        throw "settings.json is not valid JSON: $Path"
    }
}

function Upsert-Setting {
    param(
        [Parameter(Mandatory = $true)]$Object,
        [Parameter(Mandatory = $true)][string]$Name,
        [Parameter(Mandatory = $true)]$Value
    )

    $existing = $Object.PSObject.Properties[$Name]
    if ($null -ne $existing) {
        $existing.Value = $Value
    } else {
        $Object | Add-Member -MemberType NoteProperty -Name $Name -Value $Value
    }
}

function Save-Settings {
    param([string]$Path, $Object)

    $json = $Object | ConvertTo-Json -Depth 20
    $json | Set-Content -Path $Path -Encoding UTF8
}

function Resolve-PublicUrl {
    param([string]$TailscaleExe, [int]$ListenPort)

    & $TailscaleExe funnel --bg $ListenPort | Out-Host

    $serveJson = & $TailscaleExe serve status --json 2>$null
    if (-not $serveJson) {
        throw 'Cannot read tailscale serve status after enabling funnel.'
    }

    $status = $serveJson | ConvertFrom-Json
    $web = $status.Web
    if (-not $web) {
        throw 'No web serve entry found. Check tailscale funnel status.'
    }

    $hostPort = ($web.PSObject.Properties | Select-Object -First 1).Name
    if (-not $hostPort) {
        throw 'Cannot parse Tailscale funnel domain.'
    }

    $host = ($hostPort -split ':')[0]
    if (-not $host) {
        throw 'Cannot parse host from tailscale serve status.'
    }

    return "https://$host"
}

$tailscaleExe = Ensure-TailscaleInstalled -NoInstall:$SkipInstall
Ensure-LoggedIn -TailscaleExe $tailscaleExe
$publicUrl = Resolve-PublicUrl -TailscaleExe $tailscaleExe -ListenPort $Port

$settingsList = Resolve-SettingsPath -ExplicitPath $SettingsPath
foreach ($settingsPath in $settingsList) {
    $obj = Ensure-SettingsObject -Path $settingsPath
    Upsert-Setting -Object $obj -Name 'antigravityRemote.host' -Value '0.0.0.0'
    Upsert-Setting -Object $obj -Name 'antigravityRemote.port' -Value $Port
    Upsert-Setting -Object $obj -Name 'antigravityRemote.autoStart' -Value $true
    Upsert-Setting -Object $obj -Name 'antigravityRemote.publicBaseUrl' -Value $publicUrl
    Save-Settings -Path $settingsPath -Object $obj
    Write-Host "Updated settings: $settingsPath" -ForegroundColor Green
}

Write-Host "OK: Tailscale URL = $publicUrl" -ForegroundColor Green
Write-Host "Next: In Antigravity run 'Stop Relay' then 'Start Relay'." -ForegroundColor Yellow
Write-Host "Health check: $publicUrl/health" -ForegroundColor Cyan

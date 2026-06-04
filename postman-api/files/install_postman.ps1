<#
.SYNOPSIS
    Headless installation wrapper for the Squirrel-based Postman installer.
.DESCRIPTION
    Installs Postman inside a headless Session 0 (SYSTEM) context. Because
    the native Postman installer deadlocks trying to create interactive
    desktop shortcuts, this script orchestrates a monitored extraction,
    terminates the stuck processes, migrates binaries to a global target
    root, and purges the temporary system profile staging directories.
.PARAMETER DownloadUri
    The fully qualified download URI for the installer package.
.PARAMETER InstallRoot
    The system-wide path where the Postman application binaries will be
    permanently copied (e.g., 'C:\Program Files\Postman').
.PARAMETER TargetVersion
    The specific version string expected for the deployment (e.g., '12.13.4').
.PARAMETER CheckOnly
    A switch flag to return the system validation status to the caller
    without invoking downloading or extraction sequences.
.EXAMPLE
    .\install_postman.ps1 `
        -DownloadUri "https://dl.pstmn.io/download/latest/win64" `
        -InstallRoot "C:\Program Files\Postman" `
        -TargetVersion "latest"
#>
param (
    [Parameter(Mandatory = $true)]
    [string]$DownloadUri,

    [Parameter(Mandatory = $true)]
    [string]$InstallRoot,

    [Parameter(Mandatory = $true)]
    [string]$TargetVersion,

    [switch]$CheckOnly
)

# Guard block ensuring version-based script idempotency
$PostmanExePath = Join-Path $InstallRoot 'Postman.exe'
if (Test-Path $PostmanExePath) {
    $FileInfo = Get-Item $PostmanExePath
    $InstalledProductVersion = $FileInfo.VersionInfo.ProductVersion

    $IsVendorUrl = $DownloadUri -like '*dl.pstmn.io*'
    if ($TargetVersion -eq 'latest' -and $IsVendorUrl) {
        $BaseUrl = 'https://dl.pstmn.io/update/status'
        $Query = '?currentVersion=12.0.0&platform=win64'
        $StatusUrl = $BaseUrl + $Query
        $RestArgs = @{
            ErrorAction = 'SilentlyContinue'
            Uri         = $StatusUrl
        }
        $UpdateStatus = Invoke-RestMethod @RestArgs
        if ($UpdateStatus -and $UpdateStatus.version) {
            $TargetVersion = $UpdateStatus.version
        }
    }

    $IsLatestMatched = $TargetVersion -eq 'latest'
    $IsVersionMatch = $InstalledProductVersion -match $TargetVersion
    if ($IsLatestMatched -or $IsVersionMatch) {
        Write-Output "Postman version $InstalledProductVersion is up to date."
        exit 0
    }
}

# If execution reaches here, the package is missing or outdated.
if ($CheckOnly) {
    Write-Output "Postman requires installation or update."
    exit 1
}

$SetupExe = 'C:\Windows\Temp\PostmanSetup.exe'
$StartArgs = @{
    ArgumentList = '--silent'
    FilePath     = $SetupExe
}
Start-Process @StartArgs

$SourceDir = Join-Path $env:LOCALAPPDATA 'Postman'
$TimeoutSeconds = 90
$Timer = [System.Diagnostics.Stopwatch]::StartNew()
$LastSize = -1
$StableCount = 0

while ($StableCount -lt 3) {
    if ($Timer.Elapsed.TotalSeconds -gt $TimeoutSeconds) {
        break
    }
    Start-Sleep -Seconds 2
    if (Test-Path $SourceDir) {
        $GciArgs = @{
            ErrorAction = 'SilentlyContinue'
            File        = $true
            Path        = $SourceDir
            Recurse     = $true
        }
        $Files = Get-ChildItem @GciArgs
        $CurrentSize = ($Files | Measure-Object -Sum Length).Sum
        if ($CurrentSize -eq $LastSize -and $CurrentSize -gt 0) {
            $StableCount++
        } else {
            $LastSize = $CurrentSize
            $StableCount = 0
        }
    }
}

$KillList = @('PostmanSetup', 'Update', 'Postman')
foreach ($Name in $KillList) {
    $KillArgs = @{
        ErrorAction = 'SilentlyContinue'
        Force       = $true
        Name        = $Name
    }
    Stop-Process @KillArgs
}

if (Test-Path $SourceDir) {
    if (Test-Path $InstallRoot) {
        # Purge existing installations completely to prevent directory bloat
        $PurgeArgs = @{
            ErrorAction = 'SilentlyContinue'
            Force       = $true
            Path        = Join-Path $InstallRoot '*'
            Recurse     = $true
        }
        Remove-Item @PurgeArgs
    } else {
        $DirArgs = @{
            Force    = $true
            ItemType = 'Directory'
            Path     = $InstallRoot
        }
        New-Item @DirArgs
    }

    $CopyArgs = @{
        Destination = $InstallRoot
        Force       = $true
        Path        = Join-Path $SourceDir '*'
        Recurse     = $true
    }
    Copy-Item @CopyArgs

    $RemoveArgs = @{
        ErrorAction = 'SilentlyContinue'
        Force       = $true
        Path        = $SourceDir
        Recurse     = $true
    }
    Remove-Item @RemoveArgs
}

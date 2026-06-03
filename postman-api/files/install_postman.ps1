<#
.SYNOPSIS
    Headless installation wrapper for the Squirrel-based Postman installer.
.DESCRIPTION
    Installs Postman inside a headless Session 0 (SYSTEM) context. Because
    the native Postman installer deadlocks trying to create interactive
    desktop shortcuts, this script orchestrates a monitored extraction,
    terminates the stuck processes, migrates binaries to a global target
    root, and purges the temporary system profile staging directories.
.PARAMETER InstallRoot
    The system-wide path where the Postman application binaries will be
    permanently copied (e.g., 'C:\Program Files\Postman').
.PARAMETER TargetVersion
    The specific version string expected for the deployment (e.g., '12.13.4').
.EXAMPLE
    .\install_postman.ps1 -InstallRoot "C:\Program Files\Postman" `
        -TargetVersion "12.13.4"
#>
param (
    [Parameter(Mandatory = $true)]
    [string]$InstallRoot,

    [Parameter(Mandatory = $true)]
    [string]$TargetVersion
)

# Guard block ensuring version-based script idempotency
$ExePath = Join-Path $InstallRoot 'Postman.exe'
if (Test-Path $ExePath) {
    $CurrentVersion = (Get-Item $ExePath).VersionInfo.ProductVersion
    if ($CurrentVersion -match $TargetVersion) {
        Write-Host "Postman version $CurrentVersion is up to date. Exiting."
        exit 0
    }
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
    if (!(Test-Path $InstallRoot)) {
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

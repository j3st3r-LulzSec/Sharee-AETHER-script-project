<#
optimize-aether-safe.ps1
Safe one-click optimizations for Aether laptop.
Run as Administrator. Read before running.
#>

# Require admin
if (-not ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) {
    Write-Host "ERROR: Run this script as Administrator" -ForegroundColor Red
    exit 1
}

$timestamp = (Get-Date).ToString("yyyyMMdd-HHmmss")
$log = "$env:USERPROFILE\optimize-aether-log-$timestamp.txt"
"Start $timestamp" | Out-File $log

# Create restore point best effort
try {
    Write-Host "Creating system restore point" -ForegroundColor Cyan
    Checkpoint-Computer -Description "PreOptimize-Aether-$timestamp" -RestorePointType "MODIFY_SETTINGS" -ErrorAction Stop
    "Restore point created" | Out-File $log -Append
} catch {
    "Restore point not created or not available: $_" | Out-File $log -Append
    Write-Host "Warning restore point not created" -ForegroundColor Yellow
}

# Set power plan to Balanced then to High performance safely
Write-Host "Setting power plan to Balanced then High performance" -ForegroundColor Cyan
try {
    powercfg /setactive SCHEME_BALANCED
    Start-Sleep -Seconds 1
    powercfg /setactive SCHEME_MIN
    "Power plan set" | Out-File $log -Append
} catch {
    "Power plan change failed: $_" | Out-File $log -Append
}

# Visual effects best performance for current user
Write-Host "Applying visual effects for best performance" -ForegroundColor Cyan
try {
    $perfKey = "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\VisualEffects"
    New-Item -Path $perfKey -Force | Out-Null
    Set-ItemProperty -Path $perfKey -Name VisualFXSetting -Value 2 -Type DWord -Force
    "Visual effects set to best performance" | Out-File $log -Append
} catch {
    "Visual effects change failed: $_" | Out-File $log -Append
}

# Clear safe temp locations
Write-Host "Clearing temporary files" -ForegroundColor Cyan
$tempPaths = @("$env:TEMP","$env:LOCALAPPDATA\Temp","$env:WINDIR\Temp")
foreach ($p in $tempPaths) {
    if (Test-Path $p) {
        try {
            Get-ChildItem -Path $p -Recurse -Force -ErrorAction SilentlyContinue | Remove-Item -Recurse -Force -ErrorAction SilentlyContinue
            "Cleared $p" | Out-File $log -Append
        } catch {
            "Could not clear $p: $_" | Out-File $log -Append
        }
    }
}

# Trim the Windows component store safely
Write-Host "Running component store cleanup" -ForegroundColor Cyan
try {
    Dism.exe /Online /Cleanup-Image /StartComponentCleanup /ResetBase | Out-Null
    "Component store cleanup executed" | Out-File $log -Append
} catch {
    "Component cleanup failed: $_" | Out-File $log -Append
}

# Disable background apps via registry policy for current user
Write-Host "Disabling background apps for current user" -ForegroundColor Cyan
try {
    $regPath = "HKCU:\Software\Microsoft\Windows\CurrentVersion\BackgroundAccessApplications"
    New-Item -Path $regPath -Force | Out-Null
    Set-ItemProperty -Path $regPath -Name GlobalUserDisabled -Value 1 -Type DWord -Force
    "Background apps disabled for current user" | Out-File $log -Append
} catch {
    "Background apps change failed: $_" | Out-File $log -Append
}

# Suggest driver check and reboot
Write-Host ""
Write-Host "Safe optimization complete. Review log at $log" -ForegroundColor Green
Write-Host "Recommended next steps" -ForegroundColor Cyan
Write-Host "1) Reboot the laptop" -ForegroundColor Cyan
Write-Host "2) Open Device Manager and update Intel graphics and chipset drivers if needed" -ForegroundColor Cyan
"Finished at $(Get-Date)" | Out-File $log -Append

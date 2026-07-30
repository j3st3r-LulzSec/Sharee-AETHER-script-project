<#
optimize-aether.ps1
Full optimization script for Aether laptop.
This file contains the same safe steps as optimize-aether-safe.ps1 plus an aggressive section.
AGGRESSIVE ACTIONS ARE COMMENTED OUT BY DEFAULT.
Read the file and test in a VM before enabling any aggressive lines.
Run as Administrator.
#>

# --- Safe section (same as safe script) ---
if (-not ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) {
    Write-Host "ERROR: Run this script as Administrator" -ForegroundColor Red
    exit 1
}

$timestamp = (Get-Date).ToString("yyyyMMdd-HHmmss")
$log = "$env:USERPROFILE\optimize-aether-log-$timestamp.txt"
"Start $timestamp" | Out-File $log

try { Checkpoint-Computer -Description "PreOptimize-Aether-$timestamp" -RestorePointType "MODIFY_SETTINGS" -ErrorAction Stop; "Restore point created" | Out-File $log -Append } catch { "Restore point not created: $_" | Out-File $log -Append }

try { powercfg /setactive SCHEME_BALANCED; Start-Sleep -Seconds 1; powercfg /setactive SCHEME_MIN; "Power plan set" | Out-File $log -Append } catch { "Power plan change failed: $_" | Out-File $log -Append }

try { $perfKey = "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\VisualEffects"; New-Item -Path $perfKey -Force | Out-Null; Set-ItemProperty -Path $perfKey -Name VisualFXSetting -Value 2 -Type DWord -Force; "Visual effects set" | Out-File $log -Append } catch { "Visual effects change failed: $_" | Out-File $log -Append }

$tempPaths = @("$env:TEMP","$env:LOCALAPPDATA\Temp","$env:WINDIR\Temp")
foreach ($p in $tempPaths) { if (Test-Path $p) { try { Get-ChildItem -Path $p -Recurse -Force -ErrorAction SilentlyContinue | Remove-Item -Recurse -Force -ErrorAction SilentlyContinue; "Cleared $p" | Out-File $log -Append } catch { "Could not clear $p: $_" | Out-File $log -Append } } }

try { Dism.exe /Online /Cleanup-Image /StartComponentCleanup /ResetBase | Out-Null; "Component store cleanup executed" | Out-File $log -Append } catch { "Component cleanup failed: $_" | Out-File $log -Append }

try { $regPath = "HKCU:\Software\Microsoft\Windows\CurrentVersion\BackgroundAccessApplications"; New-Item -Path $regPath -Force | Out-Null; Set-ItemProperty -Path $regPath -Name GlobalUserDisabled -Value 1 -Type DWord -Force; "Background apps disabled" | Out-File $log -Append } catch { "Background apps change failed: $_" | Out-File $log -Append }

# --- Aggressive section (commented out) ---
# The lines below are destructive. They are commented out by default.
# To enable a line, remove the leading hash for that line only, test in a VM, and ensure you have a backup.

# Example App removal commands (uncomment to enable)
# Write-Host "Removing Xbox app" -ForegroundColor Yellow
# Get-AppxPackage -Name Microsoft.XboxApp -AllUsers | Remove-AppxPackage
# Get-AppxProvisionedPackage -Online | Where-Object DisplayName -Like "*Xbox*" | Remove-AppxProvisionedPackage -Online

# Example service disable commands (uncomment to enable)
# Write-Host "Disabling telemetry service DiagTrack" -ForegroundColor Yellow
# Set-Service -Name DiagTrack -StartupType Disabled
# Stop-Service -Name DiagTrack -Force

# Example scheduled task disable (uncomment to enable)
# Write-Host "Disabling Customer Experience Improvement scheduled tasks" -ForegroundColor Yellow
# Disable-ScheduledTask -TaskPath "\Microsoft\Windows\Customer Experience Improvement Program\" -TaskName "Consolidator" -ErrorAction SilentlyContinue

# Example registry startup cleanup (uncomment to enable)
# Write-Host "Backing up and removing non-essential startup entries" -ForegroundColor Yellow
# $startupKeys = @("HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Run","HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Run")
# foreach ($k in $startupKeys) {
#     $items = Get-ItemProperty -Path $k -ErrorAction SilentlyContinue | Select-Object -Property * -ExcludeProperty PS*,PSPath,PSParentPath,PSChildName,PSDrive,PSProvider
#     foreach ($name in $items.PSObject.Properties.Name) {
#         if ($name -in @("OneDrive","SecurityHealth")) { continue }
#         $value = (Get-ItemProperty -Path $k -Name $name -ErrorAction SilentlyContinue).$name
#         if ($value) {
#             New-Item -Path "$k-Backup" -ErrorAction SilentlyContinue | Out-Null
#             New-ItemProperty -Path "$k-Backup" -Name $name -Value $value -PropertyType String -Force | Out-Null
#             Remove-ItemProperty -Path $k -Name $name -ErrorAction SilentlyContinue
#         }
#     }
# }

Write-Host "Script finished. Review log at $log" -ForegroundColor Green
"Finished at $(Get-Date)" | Out-File $log -Append

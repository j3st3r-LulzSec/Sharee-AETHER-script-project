# Sharee-AETHER-script-project
AETHER script performance debloat
# optimize-aether

**One-click Windows optimization scripts for Aether laptop**  
Safe defaults for students who need low risk, high reward performance improvements.

## Quick summary
- **Safe script**: `optimize-aether-safe.ps1` — recommended for daily use on college laptops.
- **Aggressive script**: `optimize-aether.ps1` — contains optional destructive actions commented out. Only enable after VM testing and full backups.
- **Undo guidance**: `undo-steps.md`
- **Testing instructions**: `docs/TESTING.md`

## Important warnings
- **Run only the safe script** on your primary college laptop unless you have tested the aggressive actions in a VM and created a full system backup.
- **Always run as Administrator.**
- **Create a full backup and a restore point** before running any script that modifies system settings or removes apps.

## Usage
1. Inspect the scripts and README. Edit the aggressive sections if you plan to use them.
2. Open PowerShell as Administrator.
3. Run the safe script:
   ```powershell
   Set-ExecutionPolicy -Scope Process -ExecutionPolicy Bypass
   .\optimize-aether-safe.ps1

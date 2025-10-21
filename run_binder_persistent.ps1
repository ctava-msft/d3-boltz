# Persistent runner for binder generation
# This script runs the binder generation and keeps logs

$ErrorActionPreference = "Continue"
$OutputEncoding = [System.Text.Encoding]::UTF8

# Paths
$scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$boltzDir = Join-Path $scriptDir "BoltzDesign1"
$pythonExe = Join-Path $scriptDir "boltz_venv\Scripts\python.exe"
$outputLog = Join-Path $scriptDir "binder_generation.log"
$errorLog = Join-Path $scriptDir "binder_generation_error.log"
$statusFile = Join-Path $scriptDir "binder_status.txt"

# Change to BoltzDesign1 directory
Set-Location $boltzDir

# Write start time
$startTime = Get-Date
"Started at: $startTime" | Out-File $statusFile

Write-Host "Starting binder generation at $startTime"
Write-Host "Python: $pythonExe"
Write-Host "Working directory: $boltzDir"
Write-Host "Output log: $outputLog"
Write-Host "Error log: $errorLog"
Write-Host "Status file: $statusFile"
Write-Host ""

# Run the command
$args = @(
    "boltzdesign.py",
    "--target_name", "af3_tleap",
    "--input_type", "pdb",
    "--pdb_path", "..\\_inputs\\af3_tleap.pdb",
    "--target_type", "protein",
    "--design_samples", "2",
    "--length_min", "100",
    "--length_max", "150"
)

Write-Host "Running: $pythonExe $($args -join ' ')"
Write-Host ""

try {
    & $pythonExe @args *>&1 | Tee-Object -FilePath $outputLog
    $exitCode = $LASTEXITCODE
    $endTime = Get-Date
    $duration = $endTime - $startTime
    
    "Completed at: $endTime" | Out-File $statusFile -Append
    "Duration: $duration" | Out-File $statusFile -Append
    "Exit code: $exitCode" | Out-File $statusFile -Append
    
    Write-Host ""
    Write-Host "Completed at: $endTime"
    Write-Host "Duration: $duration"
    Write-Host "Exit code: $exitCode"
    
} catch {
    $errorMsg = $_.Exception.Message
    $endTime = Get-Date
    
    "ERROR at: $endTime" | Out-File $statusFile -Append
    "Error: $errorMsg" | Out-File $statusFile -Append
    
    Write-Host "ERROR: $errorMsg" -ForegroundColor Red
    $errorMsg | Out-File $errorLog -Append
}

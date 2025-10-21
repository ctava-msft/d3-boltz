# Quick Setup and Run Script for BoltzDesign1
# PowerShell version for Windows

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "BoltzDesign1 Quick Setup" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

# Check if Python is available
try {
    $pythonVersion = python --version 2>&1
    Write-Host "✓ Python found: $pythonVersion" -ForegroundColor Green
} catch {
    Write-Host "✗ ERROR: Python is not installed or not in PATH" -ForegroundColor Red
    Write-Host "Please install Python 3.10+ from https://www.python.org/" -ForegroundColor Yellow
    Read-Host "Press Enter to exit"
    exit 1
}

Write-Host ""
Write-Host "Step 1/4: Checking system requirements..." -ForegroundColor Yellow
Write-Host ""
python check_requirements.py
if ($LASTEXITCODE -ne 0) {
    Write-Host ""
    Write-Host "⚠ WARNING: Some requirements not met" -ForegroundColor Yellow
    Write-Host "You can continue but may encounter issues" -ForegroundColor Yellow
    Write-Host ""
    $continue = Read-Host "Continue anyway? (y/n)"
    if ($continue -ne "y") {
        exit 1
    }
}

Write-Host ""
Write-Host "Step 2/4: Setting up environment (this will take 15-30 minutes)..." -ForegroundColor Yellow
Write-Host "☕ This is a good time for a coffee break!" -ForegroundColor Cyan
Write-Host ""
python setup_environment.py
if ($LASTEXITCODE -ne 0) {
    Write-Host ""
    Write-Host "✗ ERROR: Setup failed" -ForegroundColor Red
    Read-Host "Press Enter to exit"
    exit 1
}

Write-Host ""
Write-Host "Step 3/4: Activating virtual environment..." -ForegroundColor Yellow
& ".\boltz_venv\Scripts\Activate.ps1"

Write-Host ""
Write-Host "Step 4/4: Ready to generate binders!" -ForegroundColor Yellow
Write-Host ""
Write-Host "You can now run:" -ForegroundColor Cyan
Write-Host "  python run_binder_generation.py" -ForegroundColor White
Write-Host ""
Write-Host "Or run a quick test:" -ForegroundColor Cyan
Write-Host "  python run_binder_generation.py --design_samples 1 --no-alphafold" -ForegroundColor White
Write-Host ""
Write-Host "========================================" -ForegroundColor Green
Write-Host "Setup Complete!" -ForegroundColor Green
Write-Host "========================================" -ForegroundColor Green
Write-Host ""

# Ask if user wants to run now
$runNow = Read-Host "Do you want to run binder generation now? (y/n)"
if ($runNow -eq "y") {
    Write-Host ""
    Write-Host "Starting binder generation with default settings..." -ForegroundColor Yellow
    Write-Host "⏱ This may take 1-2 hours depending on your GPU..." -ForegroundColor Cyan
    Write-Host ""
    python run_binder_generation.py
}

Write-Host ""
Write-Host "💡 Virtual environment is still active." -ForegroundColor Cyan
Write-Host "To deactivate, type: deactivate" -ForegroundColor Cyan
Write-Host ""
Write-Host "📖 For more information, see:" -ForegroundColor Cyan
Write-Host "   - GET_STARTED.md (quick start guide)" -ForegroundColor White
Write-Host "   - README.md (complete documentation)" -ForegroundColor White
Write-Host "   - QUICK_REFERENCE.md (command reference)" -ForegroundColor White
Write-Host ""

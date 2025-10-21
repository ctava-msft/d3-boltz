#!/usr/bin/env python3
"""
System Requirements Checker for BoltzDesign1
Checks if your system meets the requirements to run BoltzDesign1
"""

import sys
import platform
import subprocess
from pathlib import Path


def print_header(text):
    """Print formatted header"""
    print(f"\n{'='*60}")
    print(f"  {text}")
    print(f"{'='*60}")


def check_python_version():
    """Check Python version"""
    print("\n🐍 Python Version Check")
    version = sys.version_info
    current = f"{version.major}.{version.minor}.{version.micro}"
    print(f"   Current: Python {current}")
    
    if version.major == 3 and version.minor >= 10:
        print(f"   ✅ PASS - Python 3.10+ required")
        return True
    else:
        print(f"   ❌ FAIL - Python 3.10+ required, found {current}")
        print(f"   Please install Python 3.10 or newer")
        return False


def check_git():
    """Check if Git is installed"""
    print("\n📦 Git Installation Check")
    try:
        result = subprocess.run(
            ["git", "--version"],
            capture_output=True,
            text=True,
            check=True
        )
        version = result.stdout.strip()
        print(f"   {version}")
        print(f"   ✅ PASS - Git is installed")
        return True
    except (subprocess.CalledProcessError, FileNotFoundError):
        print(f"   ❌ FAIL - Git is not installed")
        print(f"   Please install Git from: https://git-scm.com/")
        return False


def check_cuda():
    """Check CUDA availability"""
    print("\n🎮 GPU/CUDA Check")
    try:
        import torch
        cuda_available = torch.cuda.is_available()
        if cuda_available:
            print(f"   PyTorch: {torch.__version__}")
            print(f"   CUDA Available: Yes")
            print(f"   CUDA Version: {torch.version.cuda}")
            print(f"   GPU Count: {torch.cuda.device_count()}")
            for i in range(torch.cuda.device_count()):
                print(f"   GPU {i}: {torch.cuda.get_device_name(i)}")
            print(f"   ✅ PASS - CUDA GPU available")
            return True
        else:
            print(f"   PyTorch: {torch.__version__}")
            print(f"   CUDA Available: No")
            print(f"   ⚠️  WARNING - No CUDA GPU detected")
            print(f"   Pipeline will run on CPU (much slower)")
            print(f"   Recommendation: Install CUDA toolkit and GPU drivers")
            return False
    except ImportError:
        print(f"   ⚠️  INFO - PyTorch not yet installed")
        print(f"   Will be installed during setup")
        return None


def check_disk_space():
    """Check available disk space"""
    print("\n💾 Disk Space Check")
    try:
        import shutil
        script_dir = Path(__file__).parent.resolve()
        usage = shutil.disk_usage(script_dir)
        free_gb = usage.free / (1024**3)
        print(f"   Available: {free_gb:.1f} GB")
        
        if free_gb >= 15:
            print(f"   ✅ PASS - Sufficient disk space (15+ GB recommended)")
            return True
        elif free_gb >= 10:
            print(f"   ⚠️  WARNING - Low disk space (15+ GB recommended)")
            return True
        else:
            print(f"   ❌ FAIL - Insufficient disk space")
            print(f"   Need at least 10 GB free, 15+ GB recommended")
            return False
    except Exception as e:
        print(f"   ⚠️  Could not check disk space: {e}")
        return None


def check_memory():
    """Check system memory"""
    print("\n🧠 System Memory Check")
    try:
        import psutil
        mem = psutil.virtual_memory()
        total_gb = mem.total / (1024**3)
        available_gb = mem.available / (1024**3)
        print(f"   Total RAM: {total_gb:.1f} GB")
        print(f"   Available: {available_gb:.1f} GB")
        
        if total_gb >= 16:
            print(f"   ✅ PASS - Sufficient RAM (16+ GB recommended)")
            return True
        elif total_gb >= 8:
            print(f"   ⚠️  WARNING - Limited RAM (16+ GB recommended)")
            print(f"   May need to reduce batch sizes")
            return True
        else:
            print(f"   ❌ FAIL - Insufficient RAM")
            print(f"   Need at least 8 GB, 16+ GB recommended")
            return False
    except ImportError:
        print(f"   ⚠️  psutil not installed, cannot check memory")
        return None
    except Exception as e:
        print(f"   ⚠️  Could not check memory: {e}")
        return None


def check_input_file():
    """Check if input PDB file exists"""
    print("\n📄 Input File Check")
    script_dir = Path(__file__).parent.resolve()
    pdb_file = script_dir / "_inputs" / "af3_tleap.pdb"
    
    if pdb_file.exists():
        size_kb = pdb_file.stat().st_size / 1024
        print(f"   File: {pdb_file.name}")
        print(f"   Size: {size_kb:.1f} KB")
        print(f"   Location: {pdb_file}")
        print(f"   ✅ PASS - Input PDB file found")
        return True
    else:
        print(f"   ❌ FAIL - Input PDB file not found")
        print(f"   Expected: {pdb_file}")
        return False


def check_network():
    """Check network connectivity for downloads"""
    print("\n🌐 Network Connectivity Check")
    try:
        import urllib.request
        urllib.request.urlopen('https://www.google.com', timeout=5)
        print(f"   ✅ PASS - Internet connection available")
        print(f"   Required for downloading model weights (~2GB)")
        return True
    except Exception:
        print(f"   ❌ FAIL - No internet connection")
        print(f"   Internet required to download model weights")
        return False


def check_virtual_environment():
    """Check if already in a virtual environment"""
    print("\n🔧 Virtual Environment Check")
    in_venv = hasattr(sys, 'real_prefix') or (
        hasattr(sys, 'base_prefix') and sys.base_prefix != sys.prefix
    )
    
    if in_venv:
        print(f"   ✅ Currently in virtual environment")
        print(f"   Prefix: {sys.prefix}")
        return True
    else:
        print(f"   ℹ️  Not in virtual environment (expected before setup)")
        return None


def print_system_info():
    """Print general system information"""
    print_header("System Information")
    print(f"   OS: {platform.system()} {platform.release()}")
    print(f"   Architecture: {platform.machine()}")
    print(f"   Processor: {platform.processor()}")
    print(f"   Python: {sys.version.split()[0]}")


def print_summary(results):
    """Print summary of checks"""
    print_header("Summary")
    
    passed = sum(1 for r in results.values() if r is True)
    failed = sum(1 for r in results.values() if r is False)
    warnings = sum(1 for r in results.values() if r is None)
    
    print(f"\n   ✅ Passed: {passed}")
    print(f"   ❌ Failed: {failed}")
    print(f"   ⚠️  Warnings: {warnings}")
    
    if failed == 0:
        print(f"\n   🎉 All critical checks passed!")
        print(f"   You can proceed with: python setup_environment.py")
        return True
    else:
        print(f"\n   ❌ Some critical checks failed")
        print(f"   Please address the issues above before proceeding")
        return False


def main():
    """Main check function"""
    print_header("BoltzDesign1 System Requirements Checker")
    print("This script will check if your system meets the requirements")
    
    print_system_info()
    
    # Run all checks
    results = {}
    results['python'] = check_python_version()
    results['git'] = check_git()
    results['cuda'] = check_cuda()
    results['disk'] = check_disk_space()
    results['memory'] = check_memory()
    results['input'] = check_input_file()
    results['network'] = check_network()
    results['venv'] = check_virtual_environment()
    
    # Print summary
    success = print_summary(results)
    
    # Print recommendations
    print_header("Recommendations")
    
    if not results.get('cuda'):
        print("\n   💡 No GPU detected:")
        print("      - Pipeline will run on CPU (10-50x slower)")
        print("      - Consider using a GPU-enabled system")
        print("      - Or use Google Colab free GPU:")
        print("        https://colab.research.google.com/github/yehlincho/BoltzDesign1/blob/main/Boltzdesign1.ipynb")
    
    if results.get('memory') is False:
        print("\n   💡 Low RAM detected:")
        print("      - Consider using --design_samples 1")
        print("      - Close other applications before running")
    
    if success:
        print("\n   📋 Next Steps:")
        print("      1. Run: python setup_environment.py")
        print("      2. Activate venv: .\\boltz_venv\\Scripts\\Activate.ps1")
        print("      3. Run: python run_binder_generation.py")
    
    print("\n" + "="*60 + "\n")
    
    return 0 if success else 1


if __name__ == "__main__":
    sys.exit(main())

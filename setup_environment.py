#!/usr/bin/env python3
"""
Setup script for BoltzDesign1 environment
Creates a Python virtual environment and installs all required dependencies
"""

import os
import sys
import subprocess
import platform
from pathlib import Path

def run_command(cmd, description, shell=True):
    """Run a command and print status"""
    print(f"\n{'='*60}")
    print(f"🔧 {description}")
    print(f"{'='*60}")
    try:
        result = subprocess.run(cmd, shell=shell, check=True, capture_output=True, text=True)
        print(result.stdout)
        if result.stderr:
            print(result.stderr)
        print(f"✅ {description} - SUCCESS")
        return True
    except subprocess.CalledProcessError as e:
        print(f"❌ {description} - FAILED")
        print(f"Error: {e.stderr}")
        return False

def main():
    """Main setup function"""
    print("🚀 Setting up BoltzDesign1 Environment")
    print("="*60)
    
    # Get the directory where this script is located
    script_dir = Path(__file__).parent.resolve()
    venv_dir = script_dir / "boltz_venv"
    
    # Determine Python executable
    python_exe = sys.executable
    is_windows = platform.system() == "Windows"
    
    print(f"📁 Working directory: {script_dir}")
    print(f"🐍 Python executable: {python_exe}")
    print(f"💻 Platform: {platform.system()}")
    
    # Step 1: Create virtual environment
    if not venv_dir.exists():
        if not run_command(
            f'"{python_exe}" -m venv "{venv_dir}"',
            "Creating virtual environment"
        ):
            sys.exit(1)
    else:
        print(f"\n✓ Virtual environment already exists at {venv_dir}")
    
    # Determine venv Python and pip paths
    if is_windows:
        venv_python = venv_dir / "Scripts" / "python.exe"
        venv_pip = venv_dir / "Scripts" / "pip.exe"
    else:
        venv_python = venv_dir / "bin" / "python"
        venv_pip = venv_dir / "bin" / "pip"
    
    # Step 2: Upgrade pip
    if not run_command(
        f'"{venv_pip}" install --upgrade pip setuptools wheel',
        "Upgrading pip, setuptools, and wheel"
    ):
        print("⚠️  Warning: pip upgrade failed, continuing anyway...")
    
    # Step 3: Clone BoltzDesign1 repository if not exists
    boltz_repo_dir = script_dir / "BoltzDesign1"
    if not boltz_repo_dir.exists():
        if not run_command(
            "git clone https://github.com/yehlincho/BoltzDesign1.git",
            f"Cloning BoltzDesign1 repository to {boltz_repo_dir}"
        ):
            sys.exit(1)
    else:
        print(f"\n✓ BoltzDesign1 repository already exists at {boltz_repo_dir}")
    
    # Step 4: Install boltz package
    boltz_src_dir = boltz_repo_dir / "boltz"
    if boltz_src_dir.exists():
        os.chdir(boltz_src_dir)
        if not run_command(
            f'"{venv_pip}" install -e .',
            "Installing Boltz package"
        ):
            sys.exit(1)
        os.chdir(script_dir)
    else:
        print(f"❌ Error: Boltz source directory not found at {boltz_src_dir}")
        sys.exit(1)
    
    # Step 5: Install core dependencies
    core_deps = [
        "torch",
        "pytorch-lightning",
        "numpy",
        "pandas",
        "scipy",
        "matplotlib",
        "seaborn",
        "tqdm",
        "PyYAML",
        "requests",
        "biopython",
        # "prody",  # Requires C++ compiler on Windows - install separately if needed
        "rdkit",
        "pypdb",
        "py3Dmol",
    ]
    
    print("\n📦 Installing core dependencies...")
    for dep in core_deps:
        run_command(
            f'"{venv_pip}" install {dep}',
            f"Installing {dep}"
        )
    
    # Step 6: Download Boltz model weights and CCD
    print("\n⬇️  Downloading Boltz model weights and dependencies...")
    download_script = f"""
import sys
sys.path.insert(0, r'{boltz_src_dir}')
from boltz.main import download
from pathlib import Path

cache = Path.home() / '.boltz'
cache.mkdir(parents=True, exist_ok=True)
download(cache)
print('Boltz weights downloaded successfully!')
"""
    
    download_script_file = script_dir / "download_weights.py"
    download_script_file.write_text(download_script, encoding='utf-8')
    
    run_command(
        f'"{venv_python}" "{download_script_file}"',
        "Downloading Boltz weights and CCD dictionary"
    )
    
    # Step 7: Setup LigandMPNN model parameters
    ligandmpnn_dir = boltz_repo_dir / "LigandMPNN"
    if ligandmpnn_dir.exists():
        os.chdir(ligandmpnn_dir)
        model_params_dir = ligandmpnn_dir / "model_params"
        
        if not model_params_dir.exists():
            if is_windows:
                # On Windows, we need to download files manually
                print("\n🧬 Setting up LigandMPNN model parameters...")
                model_params_dir.mkdir(exist_ok=True)
                
                model_urls = [
                    ("proteinmpnn_v_48_002.pt", "https://files.ipd.uw.edu/pub/ligandmpnn/proteinmpnn_v_48_002.pt"),
                    ("proteinmpnn_v_48_010.pt", "https://files.ipd.uw.edu/pub/ligandmpnn/proteinmpnn_v_48_010.pt"),
                    ("proteinmpnn_v_48_020.pt", "https://files.ipd.uw.edu/pub/ligandmpnn/proteinmpnn_v_48_020.pt"),
                    ("proteinmpnn_v_48_030.pt", "https://files.ipd.uw.edu/pub/ligandmpnn/proteinmpnn_v_48_030.pt"),
                    ("ligandmpnn_v_32_005_25.pt", "https://files.ipd.uw.edu/pub/ligandmpnn/ligandmpnn_v_32_005_25.pt"),
                    ("ligandmpnn_v_32_010_25.pt", "https://files.ipd.uw.edu/pub/ligandmpnn/ligandmpnn_v_32_010_25.pt"),
                    ("ligandmpnn_v_32_020_25.pt", "https://files.ipd.uw.edu/pub/ligandmpnn/ligandmpnn_v_32_020_25.pt"),
                    ("ligandmpnn_v_32_030_25.pt", "https://files.ipd.uw.edu/pub/ligandmpnn/ligandmpnn_v_32_030_25.pt"),
                ]
                
                download_models_script = f"""
import requests
from pathlib import Path
from tqdm import tqdm

model_params_dir = Path(r'{model_params_dir}')
models = {model_urls}

for filename, url in models:
    output_path = model_params_dir / filename
    if not output_path.exists():
        print(f'Downloading {{filename}}...')
        response = requests.get(url, stream=True)
        total_size = int(response.headers.get('content-length', 0))
        
        with open(output_path, 'wb') as f, tqdm(
            desc=filename,
            total=total_size,
            unit='B',
            unit_scale=True
        ) as pbar:
            for chunk in response.iter_content(chunk_size=8192):
                f.write(chunk)
                pbar.update(len(chunk))
        print(f'Downloaded {{filename}}')
    else:
        print(f'{{filename}} already exists')
"""
                
                download_models_file = script_dir / "download_models.py"
                download_models_file.write_text(download_models_script, encoding='utf-8')
                
                run_command(
                    f'"{venv_python}" "{download_models_file}"',
                    "Downloading LigandMPNN model parameters"
                )
            else:
                # On Unix systems, use the provided bash script
                run_command(
                    'bash get_model_params.sh "./model_params"',
                    "Setting up LigandMPNN model parameters"
                )
        else:
            print(f"\n✓ LigandMPNN model parameters already exist")
        
        os.chdir(script_dir)
    
    # Create requirements.txt for reference
    requirements_content = """# BoltzDesign1 Requirements
torch>=2.0.0
pytorch-lightning>=2.0.0
numpy>=1.24.0
pandas>=2.0.0
scipy>=1.10.0
matplotlib>=3.7.0
seaborn>=0.12.0
tqdm>=4.65.0
PyYAML>=6.0
requests>=2.31.0
biopython>=1.81
prody>=2.4.0
rdkit>=2023.3.1
pypdb>=2.3
py3Dmol>=2.0.0
"""
    
    requirements_file = script_dir / "requirements.txt"
    requirements_file.write_text(requirements_content, encoding='utf-8')
    print(f"\n📝 Created {requirements_file}")
    
    # Create activation instructions
    activation_instructions = f"""
{'='*60}
🎉 Setup Complete!
{'='*60}

To activate the environment:

Windows (PowerShell):
    .\\boltz_venv\\Scripts\\Activate.ps1

Windows (Command Prompt):
    boltz_venv\\Scripts\\activate.bat

Linux/Mac:
    source boltz_venv/bin/activate

After activation, you can run:
    python run_binder_generation.py

To deactivate:
    deactivate

{'='*60}
"""
    
    print(activation_instructions)
    
    # Save activation instructions to file
    instructions_file = script_dir / "ACTIVATION_INSTRUCTIONS.txt"
    instructions_file.write_text(activation_instructions, encoding='utf-8')

if __name__ == "__main__":
    main()

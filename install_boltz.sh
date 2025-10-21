#!/bin/bash
# Install Boltz properly in the virtual environment

set -e

cd /home/azureuser/localfiles/d3-boltz

echo "=== Installing Boltz ==="
echo ""

# Activate virtual environment
if [ ! -d "boltz_venv" ]; then
    echo "ERROR: Virtual environment not found"
    echo "Creating virtual environment..."
    python3 -m venv boltz_venv
fi

source boltz_venv/bin/activate
echo "✓ Virtual environment activated: $(which python3)"
echo ""

# Check if Boltz is really installed
echo "Checking current Boltz installation..."
if python3 -c "import boltz; print('Boltz version:', boltz.__version__ if hasattr(boltz, '__version__') else 'unknown')" 2>/dev/null; then
    echo "✓ Boltz is already installed"
    python3 -c "import boltz; print('Location:', boltz.__file__)"
    echo ""
    read -p "Reinstall anyway? (y/n) " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        exit 0
    fi
fi

echo ""
echo "Installing PyTorch with CUDA 12.1..."
pip install torch torchvision torchaudio --index-url https://download.pytorch.org/whl/cu121

echo ""
echo "Installing dependencies..."
pip install pytorch-lightning biopython rdkit numpy pandas scipy matplotlib seaborn tqdm pyyaml requests pypdb py3Dmol ipython

echo ""
echo "Downloading Boltz..."
if [ ! -d "boltz-main" ]; then
    wget -q --show-progress https://github.com/jwohlwend/boltz/archive/refs/heads/main.zip -O boltz-main.zip
    unzip -q boltz-main.zip
    rm boltz-main.zip
    echo "✓ Boltz downloaded"
else
    echo "✓ Boltz directory exists"
fi

echo ""
echo "Installing Boltz..."
cd boltz-main
pip install -e .
cd ..

echo ""
echo "Verifying Boltz installation..."
if python3 -c "from boltz.model.model import Boltz1; print('✓ Boltz1 import successful')" 2>/dev/null; then
    echo "✓ Boltz is working!"
else
    echo "ERROR: Boltz installation failed"
    echo "Trying to diagnose..."
    python3 -c "import boltz; print('Boltz location:', boltz.__file__)"
    python3 -c "from boltz.model.model import Boltz1"
    exit 1
fi

echo ""
echo "Downloading model weights..."
mkdir -p ~/.boltz
if [ ! -f ~/.boltz/boltz1.ckpt ]; then
    wget -q --show-progress -O ~/.boltz/boltz1.ckpt https://storage.googleapis.com/boltz-public/boltz1.ckpt
    echo "✓ Model weights downloaded"
else
    echo "✓ Model weights already exist"
fi

echo ""
echo "=== Installation Complete ==="
echo ""
echo "Boltz is installed at: $(python3 -c 'import boltz; print(boltz.__file__)')"
echo ""
echo "You can now run: ./run_binder_gpu.sh"

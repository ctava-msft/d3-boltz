#!/bin/bash
# Download Boltz model weights using the boltz CLI

cd /home/azureuser/localfiles/d3-boltz

source boltz_venv/bin/activate

echo "=== Downloading Boltz Model Weights ==="
echo ""

# Check if boltz command is available
if ! command -v boltz &> /dev/null; then
    echo "ERROR: boltz command not found"
    echo "Installing boltz first..."
    ./install_boltz.sh
fi

echo "Using boltz CLI to download model weights..."
echo ""

# The boltz predict command will automatically download weights on first run
# Let's create a dummy input to trigger the download
mkdir -p /tmp/boltz_test

cat > /tmp/boltz_test/test.yaml << 'EOFYAML'
version: 1
sequences:
  - protein:
      id: ["A"]
      sequence: "MKFLKFSLLTAVLLSVVFAFSSCGDDDDTYPYDVPDYAGYPYDVPDYA"
EOFYAML

echo "Running boltz to trigger weight download..."
echo "This will download the model weights (~2-3GB)..."
echo ""

# Run boltz predict which will download weights automatically
boltz predict /tmp/boltz_test/test.yaml --out_dir /tmp/boltz_test/output --recycling_steps 1 --num_workers 1 || true

echo ""
echo "Checking downloaded weights..."
ls -lh ~/.boltz/

# Check if weights were downloaded
if [ -f ~/.boltz/boltz1.ckpt ] || [ -f ~/.cache/boltz/boltz1.ckpt ]; then
    echo ""
    echo "✓ Model weights downloaded successfully"
    
    # Create symlink if needed
    if [ ! -f ~/.boltz/boltz1_conf.ckpt ]; then
        if [ -f ~/.boltz/boltz1.ckpt ]; then
            cd ~/.boltz
            ln -sf boltz1.ckpt boltz1_conf.ckpt
        elif [ -f ~/.cache/boltz/boltz1.ckpt ]; then
            mkdir -p ~/.boltz
            cd ~/.boltz
            ln -sf ~/.cache/boltz/boltz1.ckpt boltz1_conf.ckpt
        fi
        echo "✓ Created boltz1_conf.ckpt symlink"
    fi
    
    echo ""
    echo "Final weights location:"
    ls -lh ~/.boltz/ 2>/dev/null || ls -lh ~/.cache/boltz/ 2>/dev/null
    
    echo ""
    echo "=== Weights Ready ==="
    echo ""
    echo "You can now run: ./run_binder_gpu.sh"
else
    echo ""
    echo "ERROR: Failed to download model weights"
    echo "Please check your internet connection and try again"
    exit 1
fi

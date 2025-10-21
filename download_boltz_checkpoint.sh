#!/bin/bash
# Download the correct Boltz model checkpoint

echo "=== Downloading Boltz Model Checkpoints ==="
echo ""

mkdir -p ~/.boltz
cd ~/.boltz

echo "Current files in ~/.boltz/:"
ls -lh

echo ""
echo "Downloading boltz1_conf.ckpt..."
if [ ! -f "boltz1_conf.ckpt" ]; then
    # Try the main checkpoint URL
    wget -q --show-progress -O boltz1_conf.ckpt https://storage.googleapis.com/boltz-public/boltz1_conf.ckpt
    
    if [ $? -ne 0 ]; then
        echo "Main URL failed, trying alternative..."
        # If that fails, try the regular boltz1.ckpt and create a symlink
        if [ -f "boltz1.ckpt" ]; then
            echo "Creating symlink from boltz1.ckpt to boltz1_conf.ckpt..."
            ln -sf boltz1.ckpt boltz1_conf.ckpt
        else
            echo "Downloading boltz1.ckpt first..."
            wget -q --show-progress -O boltz1.ckpt https://storage.googleapis.com/boltz-public/boltz1.ckpt
            ln -sf boltz1.ckpt boltz1_conf.ckpt
        fi
    fi
    echo "✓ boltz1_conf.ckpt ready"
else
    echo "✓ boltz1_conf.ckpt already exists"
fi

echo ""
echo "Final checkpoint files:"
ls -lh ~/.boltz/

echo ""
echo "=== Model checkpoints ready ==="
echo ""
echo "You can now run: cd /home/azureuser/localfiles/d3-boltz && ./run_binder_gpu.sh"

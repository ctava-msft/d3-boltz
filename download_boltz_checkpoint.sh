#!/bin/bash
# Download the correct Boltz model checkpoint

echo "=== Downloading Boltz Model Checkpoints ==="
echo ""

mkdir -p ~/.boltz
cd ~/.boltz

echo "Current files in ~/.boltz/:"
ls -lh

echo ""
echo "Checking/downloading boltz1_conf.ckpt..."

# Remove corrupted file if it exists but is small
if [ -f "boltz1_conf.ckpt" ]; then
    size=$(stat -f%z "boltz1_conf.ckpt" 2>/dev/null || stat -c%s "boltz1_conf.ckpt" 2>/dev/null)
    if [ "$size" -lt 1000000 ]; then
        echo "Removing corrupted/incomplete checkpoint (size: $size bytes)..."
        rm -f boltz1_conf.ckpt
    fi
fi

if [ ! -f "boltz1_conf.ckpt" ]; then
    # Try the main checkpoint URL
    echo "Downloading boltz1_conf.ckpt (~2GB)..."
    wget --show-progress -O boltz1_conf.ckpt.tmp https://storage.googleapis.com/boltz-public/boltz1_conf.ckpt
    
    if [ $? -eq 0 ]; then
        mv boltz1_conf.ckpt.tmp boltz1_conf.ckpt
        echo "✓ Downloaded boltz1_conf.ckpt"
    else
        echo "Main URL failed, trying alternative..."
        rm -f boltz1_conf.ckpt.tmp
        
        # Try the regular boltz1.ckpt
        if [ ! -f "boltz1.ckpt" ] || [ $(stat -f%z "boltz1.ckpt" 2>/dev/null || stat -c%s "boltz1.ckpt" 2>/dev/null) -lt 1000000 ]; then
            echo "Downloading boltz1.ckpt (~2GB)..."
            wget --show-progress -O boltz1.ckpt.tmp https://storage.googleapis.com/boltz-public/boltz1.ckpt
            if [ $? -eq 0 ]; then
                mv boltz1.ckpt.tmp boltz1.ckpt
            else
                echo "ERROR: Failed to download checkpoint"
                exit 1
            fi
        fi
        
        echo "Creating symlink from boltz1.ckpt to boltz1_conf.ckpt..."
        ln -sf boltz1.ckpt boltz1_conf.ckpt
    fi
else
    echo "✓ boltz1_conf.ckpt already exists ($(stat -f%z "boltz1_conf.ckpt" 2>/dev/null || stat -c%s "boltz1_conf.ckpt" 2>/dev/null) bytes)"
fi

echo ""
echo "Final checkpoint files:"
ls -lh ~/.boltz/

echo ""
echo "=== Model checkpoints ready ==="
echo ""
echo "You can now run: cd /home/azureuser/localfiles/d3-boltz && ./run_binder_gpu.sh"

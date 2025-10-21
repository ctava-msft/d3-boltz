#!/bin/bash
# Patch the existing boltz2_compat.py to add path expansion

cd /home/azureuser/localfiles/d3-boltz/BoltzDesign1/boltzdesign

echo "=== Patching boltz2_compat.py to expand ~ in paths ==="
echo ""

# Check if file exists
if [ ! -f "boltz2_compat.py" ]; then
    echo "✗ Error: boltz2_compat.py not found"
    echo "Run ./fix_boltz2_import.sh first"
    exit 1
fi

# Create backup
cp boltz2_compat.py boltz2_compat.py.backup

# Use Python to add the path expansion
python3 << 'EOFPYTHON'
import re

# Read the file
with open('boltz2_compat.py', 'r') as f:
    content = f.read()

# Find the line where we load the checkpoint and add path expansion before it
pattern = r'(        """)\n(        # Load the checkpoint\n        checkpoint = torch\.load)'
replacement = r'\1\n        # Expand user path (e.g., ~/.boltz/boltz1_conf.ckpt)\n        import os\n        checkpoint_path = os.path.expanduser(checkpoint_path)\n        \n\2'

# Check if already patched
if 'os.path.expanduser' in content:
    print("✓ File already patched with path expansion")
else:
    content = re.sub(pattern, replacement, content)
    
    # Write back
    with open('boltz2_compat.py', 'w') as f:
        f.write(content)
    print("✓ Added path expansion to boltz2_compat.py")

# Verify the change
print("\nVerifying the patch:")
with open('boltz2_compat.py', 'r') as f:
    lines = f.readlines()
    for i, line in enumerate(lines, 1):
        if 'expanduser' in line:
            print(f"Line {i}: {line.rstrip()}")
            break
    else:
        print("⚠ Warning: Could not find expanduser in patched file")

EOFPYTHON

echo ""
echo "=== Patch Complete ==="
echo ""
echo "Now run: ./run_binder_gpu.sh"

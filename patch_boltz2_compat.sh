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

# Use Python to add the path expansion and confidence_args filtering
python3 << 'EOFPYTHON'
import re

# Read the file
with open('boltz2_compat.py', 'r') as f:
    content = f.read()

modified = False

# 1. Add path expansion if not present
if 'os.path.expanduser' not in content:
    pattern = r'(        """)\n(        # Load the checkpoint\n        checkpoint = torch\.load)'
    replacement = r'\1\n        # Expand user path (e.g., ~/.boltz/boltz1_conf.ckpt)\n        import os\n        checkpoint_path = os.path.expanduser(checkpoint_path)\n        \n\2'
    content = re.sub(pattern, replacement, content)
    print("✓ Added path expansion to boltz2_compat.py")
    modified = True
else:
    print("✓ Path expansion already present")

# 2. Add confidence_args filtering if not present
if 'confidence_args' not in content:
    # Find the embedder_args filtering section and add confidence_args after it
    pattern = r'(            print\(f"Filtered embedder_args: removed \{len\(embedder_args\) - len\(filtered_args\)\} deprecated parameters"\))'
    replacement = r'''\1
            
            # Filter confidence_args
            if 'confidence_args' in checkpoint['hyper_parameters']:
                confidence_args = checkpoint['hyper_parameters']['confidence_args']
                deprecated_confidence = [
                    'use_gaussian'
                ]
                filtered_confidence = {k: v for k, v in confidence_args.items() if k not in deprecated_confidence}
                checkpoint['hyper_parameters']['confidence_args'] = filtered_confidence
                if len(confidence_args) != len(filtered_confidence):
                    print(f"Filtered confidence_args: removed {len(confidence_args) - len(filtered_confidence)} deprecated parameters")'''
    
    content = re.sub(pattern, replacement, content)
    print("✓ Added confidence_args filtering to boltz2_compat.py")
    modified = True
else:
    print("✓ Confidence_args filtering already present")

if modified:
    # Write back
    with open('boltz2_compat.py', 'w') as f:
        f.write(content)
    print("\n✓ File updated successfully")
else:
    print("\n✓ No changes needed - file already up to date")

# Verify the changes
print("\nVerifying patches:")
with open('boltz2_compat.py', 'r') as f:
    content = f.read()
    if 'expanduser' in content:
        print("  ✓ Path expansion present")
    if 'confidence_args' in content:
        print("  ✓ Confidence_args filtering present")

EOFPYTHON

echo ""
echo "=== Patch Complete ==="
echo ""
echo "Now run: ./run_binder_gpu.sh"

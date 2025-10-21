#!/bin/bash
# Fix the import path in boltzdesign_utils.py

cd /home/azureuser/localfiles/d3-boltz/BoltzDesign1

echo "=== Fixing Import Path ==="
echo ""

# Fix the import to use relative import since we're already in the boltzdesign directory
python3 << 'EOFPYTHON'
# Read the file
with open('boltzdesign/boltzdesign_utils.py', 'r') as f:
    content = f.read()

# Replace the import with relative import
old_import = 'from boltzdesign.boltz2_compat import Boltz1'
new_import = 'from boltz2_compat import Boltz1'

if old_import in content:
    content = content.replace(old_import, new_import)
    print(f"✓ Changed to relative import: {new_import}")
    
    with open('boltzdesign/boltzdesign_utils.py', 'w') as f:
        f.write(content)
    print("✓ Updated boltzdesign/boltzdesign_utils.py")
else:
    print(f"⚠ Import already correct or different pattern found")
    print("Current import:")
    import subprocess
    subprocess.run(['grep', '-n', 'import Boltz1', 'boltzdesign/boltzdesign_utils.py'])
EOFPYTHON

echo ""
echo "Verifying import..."
grep -n "import Boltz1" boltzdesign/boltzdesign_utils.py

echo ""
echo "=== Fix Complete ==="
echo "You can now run: ./run_binder_gpu.sh"

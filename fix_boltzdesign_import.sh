#!/bin/bash
# Fix the import in boltzdesign.py to use relative import

cd /home/azureuser/localfiles/d3-boltz/BoltzDesign1

echo "=== Fixing Import in boltzdesign.py ==="

# Fix the import to use relative import
python3 << 'EOFPYTHON'
with open('boltzdesign.py', 'r') as f:
    content = f.read()

# Replace the import with relative import
old_import = 'from boltzdesign.input_utils import get_chains_sequence'
new_import = 'from input_utils import get_chains_sequence'

if old_import in content:
    content = content.replace(old_import, new_import)
    print(f"✓ Changed to relative import: {new_import}")
    
    with open('boltzdesign.py', 'w') as f:
        f.write(content)
    print("✓ Updated boltzdesign.py")
else:
    print("⚠ Import not found or already correct")
    
# Show the import line
import subprocess
result = subprocess.run(['grep', '-n', 'from.*input_utils import', 'boltzdesign.py'], 
                       capture_output=True, text=True)
print(f"Current import:\n{result.stdout}")
EOFPYTHON

echo ""
echo "=== Fix Complete ==="
echo "You can now run: ./run_binder_gpu.sh"

#!/bin/bash
# Find and fix Boltz v2.2.1 compatibility issues in BoltzDesign1

cd /home/azureuser/localfiles/d3-boltz/BoltzDesign1

echo "=== Finding Boltz v2 Compatibility Issues ==="
echo ""

# Search for add_mol_type_feat usage
echo "Searching for 'add_mol_type_feat'..."
grep -rn "add_mol_type_feat" . --include="*.py"

echo ""
echo "Searching for InputEmbedder usage..."
grep -rn "InputEmbedder" . --include="*.py"

echo ""
echo "Searching for Boltz1 instantiation..."
grep -rn "Boltz1(" . --include="*.py" -A 5

echo ""
echo "Checking Boltz v2 model signature..."
cd /home/azureuser/localfiles/d3-boltz
source boltz_venv/bin/activate

python3 << 'EOFPY'
import inspect
from boltz.model.models.boltz1 import Boltz1

print("=== Boltz1 __init__ signature ===")
sig = inspect.signature(Boltz1.__init__)
for param_name, param in sig.parameters.items():
    if param_name != 'self':
        default = param.default if param.default != inspect.Parameter.empty else "REQUIRED"
        print(f"  {param_name}: {default}")

print("\n=== Looking for InputEmbedder ===")
try:
    from boltz.model.modules.embedders import InputEmbedder
    sig = inspect.signature(InputEmbedder.__init__)
    print("InputEmbedder __init__ signature:")
    for param_name, param in sig.parameters.items():
        if param_name != 'self':
            default = param.default if param.default != inspect.Parameter.empty else "REQUIRED"
            print(f"  {param_name}: {default}")
except Exception as e:
    print(f"Error: {e}")

EOFPY

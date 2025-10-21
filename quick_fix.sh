#!/bin/bash
# Quick fix for the indentation error in boltzdesign.py

set -e

cd /home/azureuser/localfiles/d3-boltz/BoltzDesign1

if [ ! -f "boltzdesign.py" ]; then
    echo "ERROR: boltzdesign.py not found"
    exit 1
fi

echo "Fixing boltzdesign.py indentation error..."

# Create backup
cp boltzdesign.py boltzdesign.py.backup.$(date +%Y%m%d_%H%M%S)

# Fix the indentation error by restoring from backup if it exists
if [ -f "boltzdesign.py.backup" ]; then
    echo "Restoring from backup and applying correct patch..."
    cp boltzdesign.py.backup boltzdesign.py
fi

# Apply the correct patch using Python (more reliable than sed)
python3 << 'EOFPYTHON'
import sys

with open('boltzdesign.py', 'r') as f:
    lines = f.readlines()

new_lines = []
i = 0
boltz_path_patched = False
chain_detect_patched = False

while i < len(lines):
    line = lines[i]
    
    # Patch 1: Fix boltz path detection (look for the shutil.which line)
    if not boltz_path_patched and 'boltz_path = shutil.which("boltz")' in line:
        new_lines.append(line)
        i += 1
        # Add the venv check right after shutil.which
        indent = '            '  # Match the indentation
        new_lines.append(f'{indent}if boltz_path is None:\n')
        new_lines.append(f'{indent}    # Try to find boltz in the virtual environment\n')
        new_lines.append(f'{indent}    import sys\n')
        new_lines.append(f'{indent}    venv_boltz = os.path.join(os.path.dirname(sys.executable), "boltz")\n')
        new_lines.append(f'{indent}    if os.path.exists(venv_boltz):\n')
        new_lines.append(f'{indent}        boltz_path = venv_boltz\n')
        new_lines.append(f'{indent}\n')
        boltz_path_patched = True
        continue
    
    # Patch 2: Add chain auto-detection (after pdb_target_ids = None)
    if not chain_detect_patched and 'pdb_target_ids = None' in line and 'else:' in lines[i-1]:
        new_lines.append(line)
        i += 1
        # Add auto-detection code
        indent = '    '
        new_lines.append(f'{indent}\n')
        new_lines.append(f'{indent}# Auto-detect single chain case\n')
        new_lines.append(f'{indent}if pdb_target_ids is None and args.input_type == "pdb":\n')
        new_lines.append(f'{indent}    try:\n')
        new_lines.append(f'{indent}        from boltzdesign.input_utils import get_chains_sequence\n')
        new_lines.append(f'{indent}        chain_sequences = get_chains_sequence(pdb_path)\n')
        new_lines.append(f'{indent}        if len(chain_sequences) == 1:\n')
        new_lines.append(f'{indent}            pdb_target_ids = list(chain_sequences.keys())\n')
        new_lines.append(f'{indent}            print(f"Auto-detected single chain: {pdb_target_ids}")\n')
        new_lines.append(f'{indent}    except Exception as e:\n')
        new_lines.append(f'{indent}        print(f"Could not auto-detect chain: {{e}}")\n')
        new_lines.append(f'{indent}        pass\n')
        chain_detect_patched = True
        continue
    
    new_lines.append(line)
    i += 1

with open('boltzdesign.py', 'w') as f:
    f.writelines(new_lines)

print(f"✓ Boltz path patch applied: {boltz_path_patched}")
print(f"✓ Chain detection patch applied: {chain_detect_patched}")

if boltz_path_patched and chain_detect_patched:
    print("\n✓ All patches applied successfully!")
    sys.exit(0)
else:
    print("\n⚠ WARNING: Some patches may not have been applied")
    print("Please check boltzdesign.py manually")
    sys.exit(1)
EOFPYTHON

if [ $? -eq 0 ]; then
    echo ""
    echo "=== Fix Complete ==="
    echo "You can now run: ./run_binder_gpu.sh"
else
    echo ""
    echo "=== Fix Failed ==="
    echo "Please check the error messages above"
    exit 1
fi

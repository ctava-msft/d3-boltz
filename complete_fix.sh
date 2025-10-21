#!/bin/bash
# Complete fix: restore from backup and apply both patches correctly

cd /home/azureuser/localfiles/d3-boltz/BoltzDesign1

if [ ! -f "boltzdesign.py" ]; then
    echo "ERROR: boltzdesign.py not found"
    exit 1
fi

echo "=== Complete Fix for boltzdesign.py ==="
echo ""

# Restore from original backup
if [ -f "boltzdesign.py.backup" ]; then
    echo "Restoring from original backup..."
    cp boltzdesign.py.backup boltzdesign.py
    echo "✓ Restored"
else
    echo "Creating backup..."
    cp boltzdesign.py boltzdesign.py.backup.original
    echo "✓ Backup created"
fi

echo ""
echo "Applying patches..."
echo ""

# Apply both patches using Python
python3 << 'EOFPYTHON'
import sys

with open('boltzdesign.py', 'r') as f:
    lines = f.readlines()

new_lines = []
boltz_patched = False
chain_patched = False

i = 0
while i < len(lines):
    line = lines[i]
    
    # Patch 1: Boltz path detection
    # Look for: boltz_path = shutil.which("boltz")
    # This should be followed by: if boltz_path is None:
    if not boltz_patched and 'boltz_path = shutil.which("boltz")' in line:
        new_lines.append(line)
        i += 1
        
        # Check if the next line is already the error check
        if i < len(lines) and 'if boltz_path is None:' in lines[i]:
            # We need to insert our code BEFORE this line
            indent = '            '  # 12 spaces to match context
            new_lines.append(f'{indent}if boltz_path is None:\n')
            new_lines.append(f'{indent}    # Try to find boltz in the virtual environment\n')
            new_lines.append(f'{indent}    import sys\n')
            new_lines.append(f'{indent}    venv_boltz = os.path.join(os.path.dirname(sys.executable), "boltz")\n')
            new_lines.append(f'{indent}    if os.path.exists(venv_boltz):\n')
            new_lines.append(f'{indent}        boltz_path = venv_boltz\n')
            new_lines.append(f'{indent}\n')
            boltz_patched = True
            print("✓ Applied Boltz path detection patch")
        continue
    
    # Patch 2: Chain auto-detection
    # Look for: pdb_target_ids = [str(x.strip()) for x in args.pdb_target_ids.split(",")]
    if not chain_patched and 'pdb_target_ids = [str(x.strip()) for x in args.pdb_target_ids.split' in line:
        new_lines.append(line)
        i += 1
        
        # Insert auto-detection code
        indent = '        '  # 8 spaces to match context
        new_lines.append(f'\n')
        new_lines.append(f'{indent}# Auto-detect single chain case\n')
        new_lines.append(f'{indent}if pdb_target_ids is None and args.input_type == "pdb":\n')
        new_lines.append(f'{indent}    try:\n')
        new_lines.append(f'{indent}        from boltzdesign.input_utils import get_chains_sequence\n')
        new_lines.append(f'{indent}        chain_sequences = get_chains_sequence(pdb_path)\n')
        new_lines.append(f'{indent}        if len(chain_sequences) == 1:\n')
        new_lines.append(f'{indent}            pdb_target_ids = list(chain_sequences.keys())\n')
        new_lines.append(f'{indent}            print(f"Auto-detected single chain: {{pdb_target_ids}}")\n')
        new_lines.append(f'{indent}    except Exception as e:\n')
        new_lines.append(f'{indent}        print(f"Could not auto-detect chain: {{e}}")\n')
        new_lines.append(f'{indent}        pass\n')
        chain_patched = True
        print("✓ Applied chain auto-detection patch")
        continue
    
    new_lines.append(line)
    i += 1

# Write the patched file
with open('boltzdesign.py', 'w') as f:
    f.writelines(new_lines)

print("")
print(f"Patches applied: Boltz={boltz_patched}, Chain={chain_patched}")

if not boltz_patched or not chain_patched:
    print("")
    print("WARNING: Not all patches were applied!")
    sys.exit(1)

sys.exit(0)

EOFPYTHON

if [ $? -ne 0 ]; then
    echo ""
    echo "ERROR: Patching failed"
    exit 1
fi

echo ""
echo "=== Testing syntax ==="
python3 -m py_compile boltzdesign.py

if [ $? -eq 0 ]; then
    echo "✓ Syntax is correct!"
    echo ""
    echo "=== All patches applied successfully ==="
    echo ""
    echo "You can now run: cd /home/azureuser/localfiles/d3-boltz && ./run_binder_gpu.sh"
else
    echo ""
    echo "ERROR: Syntax check failed"
    echo "Showing lines around potential errors..."
    python3 -m py_compile boltzdesign.py 2>&1
    exit 1
fi

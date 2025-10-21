#!/bin/bash
# Add chain auto-detection to boltzdesign.py (based on actual file structure)

cd /home/azureuser/localfiles/d3-boltz/BoltzDesign1

if [ ! -f "boltzdesign.py" ]; then
    echo "ERROR: boltzdesign.py not found"
    exit 1
fi

echo "Adding chain auto-detection to boltzdesign.py..."

# Check if already patched
if grep -q "Auto-detect single chain case" boltzdesign.py; then
    echo "✓ Chain detection already patched"
    exit 0
fi

# Create backup
cp boltzdesign.py boltzdesign.py.backup.chain.$(date +%Y%m%d_%H%M%S)

# Find line 662 and add our code after it
python3 << 'EOFPYTHON'
with open('boltzdesign.py', 'r') as f:
    lines = f.readlines()

# Find the line: pdb_target_ids = [str(x.strip()) for x in args.pdb_target_ids.split(",")]...
target_line = -1
for i, line in enumerate(lines):
    if 'pdb_target_ids = [str(x.strip()) for x in args.pdb_target_ids.split' in line:
        target_line = i
        break

if target_line == -1:
    print("ERROR: Could not find pdb_target_ids assignment line")
    exit(1)

print(f"Found pdb_target_ids assignment at line {target_line + 1}")

# Insert our auto-detection code after this line
insert_pos = target_line + 1

patch_lines = [
    '\n',
    '        # Auto-detect single chain case\n',
    '        if pdb_target_ids is None and args.input_type == "pdb":\n',
    '            try:\n',
    '                from boltzdesign.input_utils import get_chains_sequence\n',
    '                chain_sequences = get_chains_sequence(pdb_path)\n',
    '                if len(chain_sequences) == 1:\n',
    '                    pdb_target_ids = list(chain_sequences.keys())\n',
    '                    print(f"Auto-detected single chain: {pdb_target_ids}")\n',
    '            except Exception as e:\n',
    '                print(f"Could not auto-detect chain: {e}")\n',
    '                pass\n',
]

# Insert the lines
lines[insert_pos:insert_pos] = patch_lines

# Write back
with open('boltzdesign.py', 'w') as f:
    f.writelines(lines)

print(f"✓ Inserted {len(patch_lines)} lines at position {insert_pos + 1}")
print("✓ Chain detection patch applied successfully!")

EOFPYTHON

if [ $? -eq 0 ]; then
    echo ""
    echo "=== Chain Detection Added ==="
    echo ""
    echo "Verifying patch..."
    if grep -q "Auto-detect single chain case" boltzdesign.py; then
        echo "✓ Patch verified in file"
        echo ""
        echo "You can now run: ./run_binder_gpu.sh"
    else
        echo "⚠ WARNING: Patch may not have been applied correctly"
    fi
else
    echo ""
    echo "=== Patch Failed ==="
    exit 1
fi

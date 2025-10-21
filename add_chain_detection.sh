#!/bin/bash
# Add chain auto-detection to boltzdesign.py

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

# Use Python to add the patch
python3 << 'EOFPYTHON'
import re

with open('boltzdesign.py', 'r') as f:
    content = f.read()

# Find the line where we set pdb_target_ids based on input
# Look for the pattern where we check if args.pdb_target_ids exists
pattern = r'([ \t]+pdb_target_ids = \[str\(x\.strip\(\)\) for x in args\.pdb_target_ids\.split\(","\)\] if args\.pdb_target_ids else None\n[ \t]+else:\n[ \t]+pdb_target_ids = None\n)'

match = re.search(pattern, content)

if match:
    # Insert our code right after this block
    insert_pos = match.end()
    
    patch = '''
    # Auto-detect single chain case
    if pdb_target_ids is None and args.input_type == "pdb":
        try:
            from boltzdesign.input_utils import get_chains_sequence
            chain_sequences = get_chains_sequence(pdb_path)
            if len(chain_sequences) == 1:
                pdb_target_ids = list(chain_sequences.keys())
                print(f"Auto-detected single chain: {pdb_target_ids}")
        except Exception as e:
            print(f"Could not auto-detect chain: {e}")
            pass

'''
    
    new_content = content[:insert_pos] + patch + content[insert_pos:]
    
    with open('boltzdesign.py', 'w') as f:
        f.write(new_content)
    
    print("✓ Chain detection patch applied successfully!")
    exit(0)
else:
    print("ERROR: Could not find the insertion point")
    print("Looking for alternative pattern...")
    
    # Try a simpler search - just look for 'pdb_target_ids = None' after an else
    lines = content.split('\n')
    for i, line in enumerate(lines):
        if 'else:' in line and i+1 < len(lines) and 'pdb_target_ids = None' in lines[i+1]:
            # Found it! Insert after line i+1
            insert_line = i + 2
            
            patch_lines = [
                '',
                '    # Auto-detect single chain case',
                '    if pdb_target_ids is None and args.input_type == "pdb":',
                '        try:',
                '            from boltzdesign.input_utils import get_chains_sequence',
                '            chain_sequences = get_chains_sequence(pdb_path)',
                '            if len(chain_sequences) == 1:',
                '                pdb_target_ids = list(chain_sequences.keys())',
                '                print(f"Auto-detected single chain: {pdb_target_ids}")',
                '        except Exception as e:',
                '            print(f"Could not auto-detect chain: {e}")',
                '            pass',
            ]
            
            lines[insert_line:insert_line] = patch_lines
            
            with open('boltzdesign.py', 'w') as f:
                f.write('\n'.join(lines))
            
            print("✓ Chain detection patch applied successfully (alternative method)!")
            exit(0)
    
    print("ERROR: Could not find insertion point for chain detection")
    exit(1)

EOFPYTHON

if [ $? -eq 0 ]; then
    echo ""
    echo "=== Chain Detection Added ==="
    echo "You can now run: ./run_binder_gpu.sh"
else
    echo ""
    echo "=== Patch Failed ==="
    echo "Please manually add the chain detection code"
    exit 1
fi

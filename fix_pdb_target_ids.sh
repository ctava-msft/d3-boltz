#!/bin/bash
# Fix pdb_target_ids None handling in boltzdesign.py

cd /home/azureuser/localfiles/d3-boltz/BoltzDesign1

echo "=== Fixing pdb_target_ids None Handling ==="

python3 << 'EOFPYTHON'
with open('boltzdesign.py', 'r') as f:
    lines = f.readlines()

# Find the section where we need to add the check
modified = False
new_lines = []

for i, line in enumerate(lines):
    new_lines.append(line)
    
    # After the auto-detection code and before the "if args.target_type" check
    # Look for the line that gets chain_sequences
    if 'chain_sequences = get_chains_sequence(pdb_path)' in line:
        # Check if the next few lines handle pdb_target_ids
        # Add check for None after auto-detection attempt
        indent = '            '
        # Look ahead to see if we already have the check
        if i + 2 < len(lines) and 'if not pdb_target_ids' in lines[i+1]:
            # Add additional check after auto-detection
            if i + 3 < len(lines) and 'for target_id in pdb_target_ids:' not in lines[i+3]:
                # Find the for loop and add None check before it
                continue
        # Add None check right after auto-detection
        if i + 2 < len(lines) and 'for target_id in pdb_target_ids:' in lines[i+2]:
            # Insert check before the for loop
            new_lines.append(f'{indent}if pdb_target_ids is None:\n')
            new_lines.append(f'{indent}    raise ValueError("No target chain IDs specified. Please provide --pdb_target_ids or ensure PDB has only one chain.")\n')
            modified = True

if modified:
    with open('boltzdesign.py', 'w') as f:
        f.writelines(new_lines)
    print("✓ Added pdb_target_ids None check")
else:
    print("⚠ Could not find insertion point, trying alternative approach...")
    
    # Alternative: add check right before all "for target_id in pdb_target_ids:" loops
    with open('boltzdesign.py', 'r') as f:
        content = f.read()
    
    # Add check before each iteration
    import re
    
    # Pattern to find "for target_id in pdb_target_ids:" with proper indentation
    pattern = r'(\s+)(for target_id in pdb_target_ids:)'
    
    def add_check(match):
        indent = match.group(1)
        for_line = match.group(2)
        check = f'{indent}if pdb_target_ids is None:\n{indent}    raise ValueError("No target chain IDs specified. Use --pdb_target_ids to specify chains.")\n{indent}{for_line}'
        return check
    
    # Only replace if not already have a check
    if 'if pdb_target_ids is None:' not in content:
        new_content = re.sub(pattern, add_check, content, count=1)
        
        if new_content != content:
            with open('boltzdesign.py', 'w') as f:
                f.write(new_content)
            print("✓ Added pdb_target_ids None check (alternative method)")
        else:
            print("⚠ Could not add check")
    else:
        print("✓ Check already exists")

# Verify
import subprocess
result = subprocess.run(['grep', '-A2', 'for target_id in pdb_target_ids', 'boltzdesign.py'], 
                       capture_output=True, text=True)
print(f"\nVerification:\n{result.stdout}")
EOFPYTHON

echo ""
echo "=== Fix Complete ==="
echo ""
echo "Now run: ./run_binder_gpu.sh"
echo "Make sure to provide --pdb_target_ids argument, e.g.:"
echo "./run_binder_gpu.sh --pdb_target_ids A"

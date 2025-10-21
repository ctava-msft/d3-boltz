#!/bin/bash
# Fix the indentation issue - the problem is mixing indentation levels

cd /home/azureuser/localfiles/d3-boltz/BoltzDesign1

if [ ! -f "boltzdesign.py" ]; then
    echo "ERROR: boltzdesign.py not found"
    exit 1
fi

echo "Fixing indentation at line 385..."
echo ""

# Create backup
cp boltzdesign.py boltzdesign.py.backup.indent2.$(date +%Y%m%d_%H%M%S)

# The issue: after "boltz_path = shutil.which("boltz")" (4 spaces indent)
# We're adding code with 12 spaces indent
# We need to add it with 4 spaces indent to match

python3 << 'EOFPYTHON'
with open('boltzdesign.py', 'r') as f:
    lines = f.readlines()

new_lines = []
i = 0

while i < len(lines):
    line = lines[i]
    
    # Find: boltz_path = shutil.which("boltz")
    if 'boltz_path = shutil.which("boltz")' in line:
        # Add the original line
        new_lines.append(line)
        i += 1
        
        # Skip any existing venv check (wrongly indented)
        while i < len(lines) and lines[i].strip().startswith('if boltz_path is None:'):
            # Skip this block
            indent_level = len(lines[i]) - len(lines[i].lstrip())
            i += 1
            # Skip the content of this if block
            while i < len(lines):
                next_indent = len(lines[i]) - len(lines[i].lstrip())
                if lines[i].strip() == '':
                    i += 1
                    continue
                if next_indent > indent_level:
                    i += 1
                else:
                    break
        
        # Now add the correct version with proper indentation
        # Match the indentation of the boltz_path line (4 spaces)
        indent = '    '
        new_lines.append(f'{indent}if boltz_path is None:\n')
        new_lines.append(f'{indent}    # Try to find boltz in the virtual environment\n')
        new_lines.append(f'{indent}    import sys\n')
        new_lines.append(f'{indent}    venv_boltz = os.path.join(os.path.dirname(sys.executable), "boltz")\n')
        new_lines.append(f'{indent}    if os.path.exists(venv_boltz):\n')
        new_lines.append(f'{indent}        boltz_path = venv_boltz\n')
        new_lines.append(f'{indent}\n')
        
        print(f"✓ Fixed Boltz path check indentation (4 spaces)")
        continue
    
    new_lines.append(line)
    i += 1

# Write back
with open('boltzdesign.py', 'w') as f:
    f.writelines(new_lines)

print("✓ File updated")

EOFPYTHON

echo ""
echo "=== Testing syntax ==="
python3 -m py_compile boltzdesign.py

if [ $? -eq 0 ]; then
    echo "✓ Syntax is correct!"
    echo ""
    echo "=== Fix Complete ==="
    echo ""
    echo "You can now run: cd /home/azureuser/localfiles/d3-boltz && ./run_binder_gpu.sh"
else
    echo ""
    echo "ERROR: Syntax still has issues"
    echo "Showing context..."
    sed -n '380,400p' boltzdesign.py | nl -v 380
    exit 1
fi

#!/bin/bash
# Fix the indentation error at line 385 in boltzdesign.py

cd /home/azureuser/localfiles/d3-boltz/BoltzDesign1

if [ ! -f "boltzdesign.py" ]; then
    echo "ERROR: boltzdesign.py not found"
    exit 1
fi

echo "Fixing indentation error at line 385..."

# Create backup
cp boltzdesign.py boltzdesign.py.backup.indent.$(date +%Y%m%d_%H%M%S)

# Use Python to fix the indentation issue
python3 << 'EOFPYTHON'
with open('boltzdesign.py', 'r') as f:
    lines = f.readlines()

# Find the problematic area around line 385
# Look for "boltz_path = shutil.which("boltz")"
fixed = False
new_lines = []
i = 0

while i < len(lines):
    line = lines[i]
    
    # Find the boltz_path line
    if 'boltz_path = shutil.which("boltz")' in line:
        # Add this line
        new_lines.append(line)
        i += 1
        
        # Check if next lines have the venv check with wrong indentation
        # Remove any incorrectly indented if boltz_path is None blocks
        while i < len(lines):
            next_line = lines[i]
            
            # Skip our added code if it has wrong indentation
            if 'if boltz_path is None:' in next_line and next_line.startswith('            if'):
                # This is our patch with correct indentation already
                break
            elif 'if boltz_path is None:' in next_line and not next_line.strip().startswith('if'):
                # Wrong indentation - skip this and related lines
                print(f"Removing incorrectly indented line {i+1}: {next_line.strip()}")
                i += 1
                # Skip the block
                while i < len(lines) and (lines[i].startswith('    ') or lines[i].strip() == ''):
                    if 'if boltz_path is None:' in lines[i]:
                        # Found the correct one
                        break
                    print(f"Removing line {i+1}: {lines[i].strip()}")
                    i += 1
                fixed = True
                break
            else:
                break
        
        # Now add the correct version if needed
        if i < len(lines) and 'if boltz_path is None:' in lines[i]:
            # The correct version is already there
            pass
        else:
            # Add the correct version
            new_lines.append('            if boltz_path is None:\n')
            new_lines.append('                # Try to find boltz in the virtual environment\n')
            new_lines.append('                import sys\n')
            new_lines.append('                venv_boltz = os.path.join(os.path.dirname(sys.executable), "boltz")\n')
            new_lines.append('                if os.path.exists(venv_boltz):\n')
            new_lines.append('                    boltz_path = venv_boltz\n')
            new_lines.append('\n')
            fixed = True
        
        continue
    
    new_lines.append(line)
    i += 1

# Write back
with open('boltzdesign.py', 'w') as f:
    f.writelines(new_lines)

if fixed:
    print("✓ Fixed indentation errors")
else:
    print("✓ No indentation errors found (file may already be correct)")

EOFPYTHON

if [ $? -eq 0 ]; then
    echo ""
    echo "=== Testing syntax ==="
    python3 -m py_compile boltzdesign.py
    
    if [ $? -eq 0 ]; then
        echo "✓ Syntax is correct!"
        echo ""
        echo "You can now run: ./run_binder_gpu.sh"
    else
        echo "⚠ Syntax errors still present"
        echo "Restoring from backup..."
        if [ -f "boltzdesign.py.backup" ]; then
            cp boltzdesign.py.backup boltzdesign.py
            echo "✓ Restored from original backup"
        fi
        exit 1
    fi
else
    echo "ERROR: Failed to fix indentation"
    exit 1
fi

#!/bin/bash
# Patch the 2 files that import ProDy

cd /home/azureuser/localfiles/d3-boltz/BoltzDesign1

echo "=== Patching ProDy imports ==="
echo ""

# File 1: boltzdesign/ligandmpnn_utils.py
if [ -f "boltzdesign/ligandmpnn_utils.py" ]; then
    echo "Checking boltzdesign/ligandmpnn_utils.py..."
    if grep -q "from prody import" boltzdesign/ligandmpnn_utils.py; then
        cp boltzdesign/ligandmpnn_utils.py boltzdesign/ligandmpnn_utils.py.backup
        sed -i 's/from prody import parsePDB/from LigandMPNN.prody_biopython_patch import parsePDB/g' boltzdesign/ligandmpnn_utils.py
        echo "✓ Patched boltzdesign/ligandmpnn_utils.py"
    else
        echo "✓ Already patched"
    fi
fi

# File 2: LigandMPNN/data_utils.py
if [ -f "LigandMPNN/data_utils.py" ]; then
    echo "Checking LigandMPNN/data_utils.py..."
    if grep -q "from prody import" LigandMPNN/data_utils.py; then
        cp LigandMPNN/data_utils.py LigandMPNN/data_utils.py.backup
        sed -i 's/from prody import \*/from prody_biopython_patch import */g' LigandMPNN/data_utils.py
        echo "✓ Patched LigandMPNN/data_utils.py"
    else
        echo "✓ Already patched"
    fi
fi

echo ""
echo "=== Verification ==="
echo ""
echo "Files with 'from prody':"
grep -r "from prody" . --include="*.py" || echo "None found - all patched!"

echo ""
echo "Files with prody_biopython_patch:"
grep -r "prody_biopython_patch" . --include="*.py" | wc -l
echo ""

echo "=== Patching Complete ==="
echo ""
echo "You can now run: cd /home/azureuser/localfiles/d3-boltz && ./run_binder_gpu.sh"

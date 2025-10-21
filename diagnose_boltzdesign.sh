#!/bin/bash
# Diagnostic script to find where to insert chain detection

cd /home/azureuser/localfiles/d3-boltz/BoltzDesign1

if [ ! -f "boltzdesign.py" ]; then
    echo "ERROR: boltzdesign.py not found"
    exit 1
fi

echo "=== Searching for pdb_target_ids assignments ==="
echo ""

grep -n "pdb_target_ids" boltzdesign.py | head -20

echo ""
echo "=== Lines around 'pdb_target_ids' (first occurrence) ==="
echo ""

line_num=$(grep -n "pdb_target_ids" boltzdesign.py | head -1 | cut -d: -f1)
if [ -n "$line_num" ]; then
    start=$((line_num - 5))
    end=$((line_num + 15))
    sed -n "${start},${end}p" boltzdesign.py | nl -ba -v $start
fi

echo ""
echo "=== Looking for args.pdb_target_ids ==="
echo ""

grep -n "args.pdb_target_ids" boltzdesign.py

echo ""
echo "=== Context around args.pdb_target_ids ==="
echo ""

line_num=$(grep -n "args.pdb_target_ids" boltzdesign.py | head -1 | cut -d: -f1)
if [ -n "$line_num" ]; then
    start=$((line_num - 3))
    end=$((line_num + 10))
    echo "Lines $start to $end:"
    sed -n "${start},${end}p" boltzdesign.py | nl -ba -v $start
fi

#!/bin/bash
# Create compatibility shim for Boltz API changes

cd /home/azureuser/localfiles/d3-boltz

source boltz_venv/bin/activate

echo "=== Creating Boltz API Compatibility Shim ==="
echo ""

# Find the boltz installation directory
BOLTZ_DIR=$(python3 -c "import boltz; import os; print(os.path.dirname(boltz.__file__))")
echo "Boltz installation: $BOLTZ_DIR"

# Create model.py in the model directory to redirect imports
cat > "$BOLTZ_DIR/model/model.py" << 'EOFPY'
"""
Compatibility shim for Boltz API changes.
Redirects old import paths to new structure.
"""
# Redirect Boltz1 from new location
from boltz.model.models.boltz1 import Boltz1

# Export for backward compatibility
__all__ = ['Boltz1']
EOFPY

echo "✓ Created compatibility shim at $BOLTZ_DIR/model/model.py"

echo ""
echo "Testing import..."
python3 -c "from boltz.model.model import Boltz1; print('✓ Boltz1 import successful!')"

if [ $? -eq 0 ]; then
    echo ""
    echo "=== Compatibility Shim Created Successfully ==="
    echo ""
    echo "You can now run: ./run_binder_gpu.sh"
else
    echo ""
    echo "ERROR: Import still failing"
    exit 1
fi

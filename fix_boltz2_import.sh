#!/bin/bash
# Fix the Boltz2 compatibility import issue

cd /home/azureuser/localfiles/d3-boltz/BoltzDesign1

echo "=== Fixing Boltz2 Import Issue ==="
echo ""

# Step 1: Ensure boltz2_compat.py exists
if [ ! -f "boltzdesign/boltz2_compat.py" ]; then
    echo "Creating boltzdesign/boltz2_compat.py..."
    cat > boltzdesign/boltz2_compat.py << 'EOFPY'
"""
Compatibility wrapper for loading Boltz2 checkpoints with different versions.
Filters out deprecated parameters that may exist in older checkpoints.
"""
import torch
from boltz.model.model import Boltz1 as OriginalBoltz1

class Boltz1(OriginalBoltz1):
    """
    Wrapper around Boltz1 that filters incompatible checkpoint parameters.
    """
    
    @classmethod
    def load_from_checkpoint(cls, checkpoint_path, map_location=None, hparams_file=None, strict=True, **kwargs):
        """
        Load checkpoint with compatibility filtering.
        """
        # Expand user path (e.g., ~/.boltz/boltz1_conf.ckpt)
        import os
        checkpoint_path = os.path.expanduser(checkpoint_path)
        
        # Load the checkpoint
        checkpoint = torch.load(checkpoint_path, map_location=map_location, weights_only=False)
        
        # Filter incompatible embedder_args parameters
        if 'hyper_parameters' in checkpoint and 'embedder_args' in checkpoint['hyper_parameters']:
            embedder_args = checkpoint['hyper_parameters']['embedder_args']
            
            # List of deprecated parameters to remove
            deprecated_params = [
                'add_mol_type_feat',
                'add_method_conditioning', 
                'add_modified_flag',
                'add_cyclic_flag'
            ]
            
            filtered_args = {k: v for k, v in embedder_args.items() if k not in deprecated_params}
            checkpoint['hyper_parameters']['embedder_args'] = filtered_args
            
            print(f"Filtered embedder_args: removed {len(embedder_args) - len(filtered_args)} deprecated parameters")
        
        # Save the filtered checkpoint temporarily
        import tempfile
        import os
        with tempfile.NamedTemporaryFile(mode='wb', delete=False, suffix='.ckpt') as tmp:
            torch.save(checkpoint, tmp)
            tmp_path = tmp.name
        
        try:
            # Load using the parent class method with the filtered checkpoint
            model = super(Boltz1, cls).load_from_checkpoint(
                tmp_path,
                map_location=map_location,
                hparams_file=hparams_file,
                strict=strict,
                **kwargs
            )
        finally:
            # Clean up temporary file
            if os.path.exists(tmp_path):
                os.unlink(tmp_path)
        
        return model

# Export for compatibility
__all__ = ['Boltz1']
EOFPY
    echo "✓ Created boltzdesign/boltz2_compat.py"
else
    echo "✓ boltzdesign/boltz2_compat.py already exists"
fi

# Step 2: Backup and fix the import in boltzdesign_utils.py
echo ""
echo "Fixing import in boltzdesign_utils.py..."

# Create backup if it doesn't exist
if [ ! -f "boltzdesign/boltzdesign_utils.py.backup.original" ]; then
    cp boltzdesign/boltzdesign_utils.py boltzdesign/boltzdesign_utils.py.backup.original
    echo "✓ Created backup: boltzdesign_utils.py.backup.original"
fi

# Use Python to do the replacement to avoid sed issues
python3 << 'EOFPYTHON'
import re

# Read the file
with open('boltzdesign/boltzdesign_utils.py', 'r') as f:
    content = f.read()

# Replace the import - handle both possible import patterns
old_patterns = [
    'from boltz.model.model import Boltz1',
    'from boltz.model.models.boltz1 import Boltz1',
    'from boltzdesign.boltz2_compat import Boltz1'
]

new_import = 'from boltz2_compat import Boltz1'

modified = False
for pattern in old_patterns:
    if pattern in content:
        content = content.replace(pattern, new_import)
        print(f"✓ Replaced: {pattern}")
        modified = True

if modified:
    # Write back
    with open('boltzdesign/boltzdesign_utils.py', 'w') as f:
        f.write(content)
    print("✓ Updated boltzdesign/boltzdesign_utils.py")
else:
    print("⚠ Import already correct or pattern not found")
EOFPYTHON

# Step 3: Verify the change
echo ""
echo "Verifying import in boltzdesign_utils.py..."
grep "from.*import Boltz1" boltzdesign/boltzdesign_utils.py

# Step 4: Test the import
echo ""
echo "Testing import..."
cd /home/azureuser/localfiles/d3-boltz
source boltz_venv/bin/activate

python3 << 'EOFTEST'
import sys
sys.path.insert(0, '/home/azureuser/localfiles/d3-boltz/BoltzDesign1')
sys.path.insert(0, '/home/azureuser/localfiles/d3-boltz/BoltzDesign1/boltzdesign')

try:
    # Test direct import
    from boltz2_compat import Boltz1
    print("✓ boltz2_compat imports successfully")
    
    # Test through boltzdesign_utils
    from boltzdesign_utils import *
    print("✓ boltzdesign_utils imports successfully")
    
    print(f"✓ Boltz1 class: {Boltz1}")
    print("")
    print("SUCCESS: All imports working correctly!")
    
except Exception as e:
    print(f"✗ Error: {e}")
    import traceback
    traceback.print_exc()
    exit(1)
EOFTEST

if [ $? -eq 0 ]; then
    echo ""
    echo "=== Fix Complete ==="
    echo ""
    echo "You can now run: ./run_binder_gpu.sh"
else
    echo ""
    echo "=== Fix Failed ==="
    echo "Please check the error messages above"
    exit 1
fi

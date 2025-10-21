#!/bin/bash
# Fix ConfidenceModule parameter mismatch issue
# This script filters out deprecated parameters from checkpoint hyperparameters

cd /home/azureuser/localfiles/d3-boltz/BoltzDesign1

echo "=== Fixing ConfidenceModule Parameter Issue ==="
echo ""

# Create or update the boltz2_compat.py wrapper
echo "Creating/updating boltzdesign/boltz2_compat.py..."
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
        
        print(f"Loading checkpoint from: {checkpoint_path}")
        
        # Load the checkpoint
        checkpoint = torch.load(checkpoint_path, map_location=map_location, weights_only=False)
        
        # Filter incompatible parameters
        if 'hyper_parameters' in checkpoint:
            hp = checkpoint['hyper_parameters']
            
            # Filter embedder_args
            if 'embedder_args' in hp:
                embedder_args = hp['embedder_args']
                deprecated_embedder = [
                    'add_mol_type_feat',
                    'add_method_conditioning', 
                    'add_modified_flag',
                    'add_cyclic_flag'
                ]
                filtered_embedder = {k: v for k, v in embedder_args.items() if k not in deprecated_embedder}
                hp['embedder_args'] = filtered_embedder
                removed = [k for k in embedder_args.keys() if k in deprecated_embedder]
                if removed:
                    print(f"Filtered embedder_args: removed {removed}")
            
            # Filter confidence_model_args (the one passed to ConfidenceModule.__init__)
            if 'confidence_model_args' in hp:
                confidence_model_args = hp['confidence_model_args']
                
                # List of parameters accepted by ConfidenceModule.__init__
                # Based on boltz/model/modules/confidence.py
                accepted_params = {
                    'pairformer_args', 'num_dist_bins', 'max_dist', 
                    'add_s_to_z_prod', 'add_s_input_to_s', 'use_s_diffusion',
                    'add_z_input_to_z', 'confidence_args', 'compile_pairformer'
                }
                
                # Filter to only accepted parameters
                filtered_confidence = {k: v for k, v in confidence_model_args.items() if k in accepted_params}
                removed = [k for k in confidence_model_args.keys() if k not in accepted_params]
                
                hp['confidence_model_args'] = filtered_confidence
                
                if removed:
                    print(f"Filtered confidence_model_args: removed {removed}")
            
            # Filter confidence_args (passed to ConfidenceHeads)
            if 'confidence_args' in hp:
                confidence_args = hp['confidence_args']
                
                # List of parameters accepted by ConfidenceHeads.__init__
                # Based on boltz/model/modules/confidence.py ConfidenceHeads class
                accepted_confidence_head_params = {
                    'num_plddt_bins', 'num_pde_bins', 'num_pae_bins', 'compute_pae'
                }
                
                # Filter to only accepted parameters
                filtered = {k: v for k, v in confidence_args.items() if k in accepted_confidence_head_params}
                removed = [k for k in confidence_args.keys() if k not in accepted_confidence_head_params]
                hp['confidence_args'] = filtered
                if removed:
                    print(f"Filtered confidence_args: removed {removed}")
        
        # Save the filtered checkpoint temporarily
        import tempfile
        with tempfile.NamedTemporaryFile(mode='wb', delete=False, suffix='.ckpt') as tmp:
            torch.save(checkpoint, tmp)
            tmp_path = tmp.name
        
        try:
            # Load using the parent class method with the filtered checkpoint
            print("Loading model with filtered parameters...")
            model = super(Boltz1, cls).load_from_checkpoint(
                tmp_path,
                map_location=map_location,
                hparams_file=hparams_file,
                strict=strict,
                **kwargs
            )
            print("✓ Model loaded successfully")
        finally:
            # Clean up temporary file
            if os.path.exists(tmp_path):
                os.unlink(tmp_path)
        
        return model

# Export for compatibility
__all__ = ['Boltz1']
EOFPY

echo "✓ Created boltzdesign/boltz2_compat.py"

# Update the import in boltzdesign_utils.py
echo ""
echo "Updating import in boltzdesign_utils.py..."

# Create backup if it doesn't exist
if [ ! -f "boltzdesign/boltzdesign_utils.py.backup.original" ]; then
    cp boltzdesign/boltzdesign_utils.py boltzdesign/boltzdesign_utils.py.backup.original
    echo "✓ Created backup: boltzdesign_utils.py.backup.original"
fi

# Use Python to do the replacement
python3 << 'EOFPYTHON'
import re

# Read the file
with open('boltzdesign/boltzdesign_utils.py', 'r') as f:
    content = f.read()

# Replace the import - handle all possible import patterns
patterns_to_replace = [
    ('from boltz.model.model import Boltz1', 'from boltzdesign.boltz2_compat import Boltz1'),
    ('from boltz.model.models.boltz1 import Boltz1', 'from boltzdesign.boltz2_compat import Boltz1'),
]

modified = False
for old_pattern, new_pattern in patterns_to_replace:
    if old_pattern in content:
        content = content.replace(old_pattern, new_pattern)
        print(f"✓ Replaced: {old_pattern}")
        modified = True

# If already using boltz2_compat but with wrong import path
if 'from boltz2_compat import Boltz1' in content:
    content = content.replace('from boltz2_compat import Boltz1', 'from boltzdesign.boltz2_compat import Boltz1')
    print("✓ Fixed import path to use boltzdesign.boltz2_compat")
    modified = True

if modified:
    with open('boltzdesign/boltzdesign_utils.py', 'w') as f:
        f.write(content)
    print("✓ Updated boltzdesign/boltzdesign_utils.py")
else:
    print("⚠ Import already correct or pattern not found")
    print("Current import line:")
    import subprocess
    subprocess.run(['grep', '-n', 'import Boltz1', 'boltzdesign/boltzdesign_utils.py'])
EOFPYTHON

# Verify the change
echo ""
echo "Verifying import in boltzdesign_utils.py..."
grep -n "import Boltz1" boltzdesign/boltzdesign_utils.py || echo "No Boltz1 import found"

echo ""
echo "=== Fix Complete ==="
echo ""
echo "The compatibility wrapper has been created and imports updated."
echo "This will filter out deprecated parameters when loading checkpoints."
echo ""
echo "You can now run: ./run_binder_gpu.sh"

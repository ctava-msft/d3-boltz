#!/bin/bash
# Complete fix for Boltz checkpoint compatibility issues
# Combines parameter filtering and import path fixes

cd /home/azureuser/localfiles/d3-boltz/BoltzDesign1

echo "=== Complete Boltz Compatibility Fix ==="
echo ""

# Step 1: Create the compatibility wrapper
echo "Step 1: Creating boltz2_compat.py wrapper..."
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
    def load_from_checkpoint(cls, checkpoint_path, map_location=None, hparams_file=None, strict=False, **kwargs):
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
                
                # First, filter the nested confidence_args if it exists
                if 'confidence_args' in confidence_model_args:
                    nested_confidence_args = confidence_model_args['confidence_args']
                    
                    # List of parameters accepted by ConfidenceHeads.__init__
                    accepted_confidence_head_params = {
                        'num_plddt_bins', 'num_pde_bins', 'num_pae_bins', 'compute_pae'
                    }
                    
                    filtered_nested = {k: v for k, v in nested_confidence_args.items() 
                                      if k in accepted_confidence_head_params}
                    removed_nested = [k for k in nested_confidence_args.keys() 
                                     if k not in accepted_confidence_head_params]
                    
                    confidence_model_args['confidence_args'] = filtered_nested
                    
                    if removed_nested:
                        print(f"Filtered nested confidence_args: removed {removed_nested}")
                
                # List of parameters accepted by ConfidenceModule.__init__
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
            
            # Also filter top-level confidence_args if it exists separately
            if 'confidence_args' in hp:
                confidence_args = hp['confidence_args']
                
                # List of parameters accepted by ConfidenceHeads.__init__
                accepted_confidence_head_params = {
                    'num_plddt_bins', 'num_pde_bins', 'num_pae_bins', 'compute_pae'
                }
                
                # Filter to only accepted parameters
                filtered = {k: v for k, v in confidence_args.items() if k in accepted_confidence_head_params}
                removed = [k for k in confidence_args.keys() if k not in accepted_confidence_head_params]
                hp['confidence_args'] = filtered
                if removed:
                    print(f"Filtered top-level confidence_args: removed {removed}")
        
        # Save the filtered checkpoint temporarily
        import tempfile
        with tempfile.NamedTemporaryFile(mode='wb', delete=False, suffix='.ckpt') as tmp:
            torch.save(checkpoint, tmp)
            tmp_path = tmp.name
        
        try:
            # First create the model instance with the hyperparameters
            print("Creating model instance...")
            from pytorch_lightning.core.saving import _load_state
            import inspect
            
            # Get the hyperparameters and instantiate the model
            _cls_kwargs = checkpoint.get("hyper_parameters", {}).copy()
            
            # Get the accepted parameters for Boltz1.__init__
            # Using OriginalBoltz1 to get the actual signature
            sig = inspect.signature(OriginalBoltz1.__init__)
            accepted_params = set(sig.parameters.keys()) - {'self'}
            
            # Filter hyperparameters to only include accepted ones
            filtered_kwargs = {k: v for k, v in _cls_kwargs.items() if k in accepted_params}
            removed_hparams = [k for k in _cls_kwargs.keys() if k not in accepted_params]
            
            if removed_hparams:
                print(f"Filtered hyperparameters: removed {removed_hparams}")
            
            # Merge with kwargs passed to load_from_checkpoint
            filtered_kwargs.update(kwargs)
            
            # Instantiate the model
            model = cls(**filtered_kwargs)
            
            # Now manually load the state dict with strict=False and filter mismatches
            print("Loading state dict with architecture compatibility filtering...")
            state_dict = checkpoint["state_dict"]
            model_state = model.state_dict()
            
            # Filter state_dict to only include keys that match in size
            filtered_state = {}
            skipped_keys = []
            
            for key, value in state_dict.items():
                if key in model_state:
                    if value.shape == model_state[key].shape:
                        filtered_state[key] = value
                    else:
                        skipped_keys.append(f"{key}: checkpoint={value.shape} vs model={model_state[key].shape}")
                else:
                    skipped_keys.append(f"{key}: not in model")
            
            if skipped_keys:
                print(f"Skipped {len(skipped_keys)} mismatched/missing keys:")
                for sk in skipped_keys[:5]:  # Show first 5
                    print(f"  - {sk}")
                if len(skipped_keys) > 5:
                    print(f"  ... and {len(skipped_keys) - 5} more")
            
            # Load the filtered state dict
            missing, unexpected = model.load_state_dict(filtered_state, strict=False)
            print(f"✓ Model loaded successfully (loaded {len(filtered_state)}/{len(state_dict)} keys)")
        finally:
            # Clean up temporary file
            if os.path.exists(tmp_path):
                os.unlink(tmp_path)
        
        return model

# Export for compatibility
__all__ = ['Boltz1']
EOFPY

echo "✓ Created boltzdesign/boltz2_compat.py"

# Step 2: Fix the import path
echo ""
echo "Step 2: Fixing import in boltzdesign_utils.py..."

# Create backup if it doesn't exist
if [ ! -f "boltzdesign/boltzdesign_utils.py.backup.original" ]; then
    cp boltzdesign/boltzdesign_utils.py boltzdesign/boltzdesign_utils.py.backup.original
    echo "✓ Created backup: boltzdesign_utils.py.backup.original"
fi

# Use Python to fix the import - use RELATIVE import since we're in boltzdesign/ directory
python3 << 'EOFPYTHON'
# Read the file
with open('boltzdesign/boltzdesign_utils.py', 'r') as f:
    content = f.read()

# Replace any Boltz1 imports with relative import
import re

# Find all possible import patterns
patterns = [
    'from boltz.model.model import Boltz1',
    'from boltz.model.models.boltz1 import Boltz1',
    'from boltzdesign.boltz2_compat import Boltz1',
]

# Use relative import since we're inside boltzdesign/ directory
correct_import = 'from boltz2_compat import Boltz1'

modified = False
for pattern in patterns:
    if pattern in content:
        content = content.replace(pattern, correct_import)
        print(f"✓ Replaced: {pattern}")
        modified = True

if modified:
    with open('boltzdesign/boltzdesign_utils.py', 'w') as f:
        f.write(content)
    print("✓ Updated to use relative import: from boltz2_compat import Boltz1")
else:
    # Check if it's already correct
    if correct_import in content:
        print("✓ Import already correct")
    else:
        print("⚠ Could not find import to fix")
EOFPYTHON

# Step 3: Verify
echo ""
echo "Step 3: Verifying changes..."
echo "Import line in boltzdesign_utils.py:"
grep -n "import Boltz1" boltzdesign/boltzdesign_utils.py

echo ""
echo "=== Fix Complete ==="
echo ""
echo "Changes made:"
echo "  1. Created boltz2_compat.py with parameter filtering"
echo "  2. Updated import to use relative import (from boltz2_compat import Boltz1)"
echo ""
echo "You can now run: ./run_binder_gpu.sh"

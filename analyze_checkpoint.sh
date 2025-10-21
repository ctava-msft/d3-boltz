#!/bin/bash
# Find the correct InputEmbedder import path in Boltz v2

cd /home/azureuser/localfiles/d3-boltz
source boltz_venv/bin/activate

echo "=== Finding InputEmbedder in Boltz v2 ==="
echo ""

python3 << 'EOFPY'
import inspect
import sys

# Find where InputEmbedder is defined
print("Looking for InputEmbedder...")
try:
    from boltz.model.modules.trunk import InputEmbedder
    print("✓ Found: from boltz.model.modules.trunk import InputEmbedder")
    
    print("\nInputEmbedder __init__ signature:")
    sig = inspect.signature(InputEmbedder.__init__)
    for param_name, param in sig.parameters.items():
        if param_name != 'self':
            default = param.default if param.default != inspect.Parameter.empty else "REQUIRED"
            print(f"  {param_name}: {default}")
            
except ImportError as e:
    print(f"Failed to import from trunk: {e}")
    
# Now check the actual Boltz1 checkpoint loading
print("\n=== Checking checkpoint loading ===")
try:
    from boltz.model.models.boltz1 import Boltz1
    print("Boltz1 can be imported successfully")
    
    # Check if there's a load_from_checkpoint method
    if hasattr(Boltz1, 'load_from_checkpoint'):
        print("✓ Boltz1.load_from_checkpoint exists")
    
except Exception as e:
    print(f"Error importing Boltz1: {e}")

# Check what the actual checkpoint expects
print("\n=== Analyzing checkpoint structure ===")
import torch
ckpt_path = "/home/azureuser/.boltz/boltz1_conf.ckpt"
try:
    checkpoint = torch.load(ckpt_path, map_location='cpu', weights_only=False)
    if 'hyper_parameters' in checkpoint:
        print("Checkpoint hyper_parameters keys:")
        for key in checkpoint['hyper_parameters'].keys():
            print(f"  {key}")
        
        if 'embedder_args' in checkpoint['hyper_parameters']:
            print("\nembedder_args content:")
            embedder_args = checkpoint['hyper_parameters']['embedder_args']
            for key, value in embedder_args.items():
                print(f"  {key}: {value}")
except Exception as e:
    print(f"Error loading checkpoint: {e}")

EOFPY

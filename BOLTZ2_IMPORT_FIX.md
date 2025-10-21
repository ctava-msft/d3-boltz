# Boltz2 Import Fix

## Problem
The `create_boltz2_wrapper.sh` script had an incorrect import path that caused:
```
ModuleNotFoundError: No module named 'boltzdesign.boltz2_compat'; 'boltzdesign' is not a package
```

## Root Cause
The script was updating the import to use `from boltzdesign.boltz2_compat import Boltz1`, but since `boltzdesign.py` adds `boltzdesign/` directory to sys.path and imports modules directly (e.g., `from boltzdesign_utils import *`), the correct import should be `from boltz2_compat import Boltz1` without the package prefix.

## Solution
Created `fix_boltz2_import.sh` which:

1. **Creates `boltz2_compat.py`** in the `BoltzDesign1/boltzdesign/` directory
2. **Updates the import** in `boltzdesign_utils.py` to use `from boltz2_compat import Boltz1`
3. **Uses Python for replacement** instead of sed to avoid shell escaping issues
4. **Tests the import** to verify it works correctly

## Usage

On the Linux system, run:

```bash
cd ~/localfiles/d3-boltz
chmod +x fix_boltz2_import.sh
./fix_boltz2_import.sh
```

Then run your binder generation:

```bash
./run_binder_gpu.sh
```

## What Changed

### Updated Files
- `create_boltz2_wrapper.sh` - Fixed import paths (for future use)
- Created `fix_boltz2_import.sh` - New script with correct logic

### Import Change
**Before:**
```python
from boltz.model.model import Boltz1
```

**After:**
```python
from boltz2_compat import Boltz1
```

This allows the compatibility wrapper to filter out deprecated parameters when loading Boltz2 checkpoints.

## Files Backed Up
The script creates `boltzdesign_utils.py.backup.original` before making changes.

## Path Expansion Issue (Update)

### Additional Problem Found
The checkpoint path `~/.boltz/boltz1_conf.ckpt` wasn't being expanded, causing:
```
FileNotFoundError: [Errno 2] No such file or directory: '~/.boltz/boltz1_conf.ckpt'
```

### Additional Fix
Created `patch_boltz2_path.sh` to add path expansion to `boltz2_compat.py`:
- Adds `os.path.expanduser(checkpoint_path)` before loading the checkpoint
- Creates backup before patching

### Usage After Initial Fix
If you already ran `fix_boltz2_import.sh` and got the path error:

```bash
cd ~/localfiles/d3-boltz
chmod +x patch_boltz2_path.sh
./patch_boltz2_path.sh
./run_binder_gpu.sh
```

### Complete Fresh Install
For a fresh setup, just run `fix_boltz2_import.sh` (it includes the path expansion fix).

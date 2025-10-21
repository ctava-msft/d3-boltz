# BoltzDesign1 Setup - Getting Started

## 📚 What You Have

I've created a complete setup for running BoltzDesign1 to generate protein binders using your `af3_tleap.pdb` file. Here's what's included:

### Files Created

1. **`check_requirements.py`** - Check if your system is ready
2. **`setup_environment.py`** - Automated environment setup
3. **`run_binder_generation.py`** - Main script to generate binders
4. **`README.md`** - Complete documentation
5. **`QUICK_REFERENCE.md`** - Quick command reference
6. **`GET_STARTED.md`** - This file!

## 🚦 Step-by-Step Instructions

### Step 0: Check System Requirements (Optional but Recommended)

Before starting, check if your system meets the requirements:

```powershell
python check_requirements.py
```

This will check:
- ✅ Python version (3.10+ required)
- ✅ Git installation
- ✅ GPU/CUDA availability
- ✅ Disk space (15+ GB recommended)
- ✅ RAM (16+ GB recommended)
- ✅ Input file exists
- ✅ Internet connectivity

### Step 1: Run Setup

This will take 15-30 minutes:

```powershell
python setup_environment.py
```

What this does:
- Creates a Python virtual environment
- Clones BoltzDesign1 repository from GitHub
- Installs all dependencies (PyTorch, Boltz, etc.)
- Downloads model weights (~2GB)
- Downloads LigandMPNN parameters
- Sets everything up automatically

### Step 2: Activate Virtual Environment

**Windows PowerShell:**
```powershell
.\boltz_venv\Scripts\Activate.ps1
```

You should see `(boltz_venv)` appear in your prompt.

### Step 3: Generate Binders

Now you're ready to generate binders!

**Basic run (recommended for first test):**
```powershell
python run_binder_generation.py
```

This uses your `_inputs/af3_tleap.pdb` file and default settings:
- Target type: protein
- Target chain: A
- Number of designs: 2
- Binder length: 100-150 amino acids

## 🎯 What to Expect

### Execution Time
- **With GPU:** 30-60 minutes per design
- **Without GPU:** 4-8 hours per design (much slower!)

### Pipeline Stages
1. **BoltzDesign** - Generates initial binder structures
2. **LigandMPNN** - Optimizes sequences
3. **AlphaFold3** - Validates designs (optional)

### Output Location
Results will be in:
```
BoltzDesign1/outputs/protein_af3_tleap_boltz1/
└── protein_af3_tleap_boltz1/
    └── ligandmpnn_cutoff_4/
        └── 03_af_pdb_success/  ← Your best designs are here!
```

Look for:
- `*.pdb` files - 3D structures of binder candidates
- `high_iptm_confidence_scores.csv` - Quality metrics

## 🔍 Evaluating Results

### Good Binder Candidates Have:
- **iPTM > 0.5** (interface confidence)
- **pLDDT > 70** (structure confidence)
- **Low PAE** at the binding interface

### What to Do with Results:
1. Open PDB files in PyMOL, ChimeraX, or similar
2. Check the binding interface
3. Select top candidates based on confidence scores
4. Proceed to experimental validation

## 🛠️ Customization Examples

### If you know specific binding residues:
```powershell
python run_binder_generation.py \
    --contact_residues "100,101,102,150" \
    --constraint_target A
```

### For multiple target chains:
```powershell
python run_binder_generation.py --target_chains A,B
```

### Generate more designs:
```powershell
python run_binder_generation.py --design_samples 5
```

### Faster testing (skip validation):
```powershell
python run_binder_generation.py --no-alphafold
```

## 📖 Documentation Files

- **`README.md`** - Complete documentation with all details
- **`QUICK_REFERENCE.md`** - Common commands and use cases
- **`GET_STARTED.md`** - This file

## ❓ Troubleshooting

### "Import Error" after setup
**Solution:** Make sure you activated the virtual environment:
```powershell
.\boltz_venv\Scripts\Activate.ps1
```

### Out of memory errors
**Solution:** Reduce design samples:
```powershell
python run_binder_generation.py --design_samples 1
```

### Takes too long
**Solution:** Skip AlphaFold3 validation:
```powershell
python run_binder_generation.py --no-alphafold
```

### No GPU available
**Check GPU:** 
```powershell
python -c "import torch; print(torch.cuda.is_available())"
```
Pipeline will work on CPU but will be much slower.

### Setup fails at downloading models
**Solution:** Check internet connection and try again. You may need to:
- Disable VPN temporarily
- Check firewall settings
- Try from a different network

## 🎓 Learning Resources

- **BoltzDesign1 Paper:** https://www.biorxiv.org/content/10.1101/2025.04.06.647261v1
- **GitHub Repository:** https://github.com/yehlincho/BoltzDesign1
- **Google Colab Demo:** https://colab.research.google.com/github/yehlincho/BoltzDesign1/blob/main/Boltzdesign1.ipynb

## 💡 Pro Tips

1. **Start small:** Run with 1-2 designs first to verify everything works
2. **Use GPU:** Make sure you have NVIDIA GPU with CUDA for reasonable speed
3. **Save configs:** Keep track of parameters that work well
4. **Iterate fast:** Use `--no-alphafold` during development
5. **Check results:** Always inspect confidence scores before proceeding

## ⚠️ Important Notes

- **Experimental software:** Results should be validated experimentally
- **GPU highly recommended:** CPU execution is 10-50x slower
- **Large downloads:** Model weights are ~2GB
- **Disk space:** Need 10-15GB free space
- **AlphaFold3:** Optional but requires separate installation for full validation

## 📞 Getting Help

1. **Check documentation:** Start with `README.md`
2. **Quick reference:** See `QUICK_REFERENCE.md` for common commands
3. **System issues:** Run `python check_requirements.py`
4. **BoltzDesign1 issues:** https://github.com/yehlincho/BoltzDesign1/issues

## 🚀 Quick Start Summary

```powershell
# 1. Check system (optional)
python check_requirements.py

# 2. Setup (once, 15-30 min)
python setup_environment.py

# 3. Activate environment (each session)
.\boltz_venv\Scripts\Activate.ps1

# 4. Generate binders
python run_binder_generation.py

# 5. Find results in:
# BoltzDesign1/outputs/.../03_af_pdb_success/
```

## ✅ Success Checklist

- [ ] System requirements checked (`check_requirements.py`)
- [ ] Environment setup completed (`setup_environment.py`)
- [ ] Virtual environment activated
- [ ] First test run completed
- [ ] Results found in output directory
- [ ] Top candidates identified by confidence scores

---

**You're all set! Good luck with your binder design!** 🧬🎉

For detailed information, see `README.md`.
For quick commands, see `QUICK_REFERENCE.md`.

# BoltzDesign1 Setup Summary

## ✅ What Has Been Created

I've created a complete, automated setup for running BoltzDesign1 to generate protein binders for your `af3_tleap.pdb` structure. Here's everything that's ready for you:

## 📦 Complete Package Includes

### 📚 Documentation (5 files)
1. **GET_STARTED.md** - Your first stop! Step-by-step quick start guide
2. **README.md** - Complete documentation with all details
3. **QUICK_REFERENCE.md** - Common commands and use case examples
4. **WORKFLOW_DIAGRAM.md** - Visual workflow and process diagrams
5. **FILES_INDEX.md** - Complete file organization guide

### 🔧 Setup Scripts (4 files)
1. **quick_setup.ps1** - One-click automated setup for PowerShell
2. **quick_setup.bat** - One-click automated setup for Command Prompt
3. **setup_environment.py** - Main Python setup script
4. **check_requirements.py** - System compatibility checker

### 🚀 Execution Scripts (1 file)
1. **run_binder_generation.py** - Main script to generate binders with full customization options

### 📁 Input Files (Already Present)
- `_inputs/af3_tleap.pdb` - Your target protein structure
- `_inputs/af3_tleap_sequence.dat` - Sequence data
- `_inputs/*.dat` - Distance constraint files

## 🎯 How to Get Started (3 Simple Steps)

### Absolute Fastest Way:
```powershell
# Just run this one script and follow the prompts:
.\quick_setup.ps1
```

### Step-by-Step Way:

#### Step 1: Setup (One-time, 15-30 minutes)
```powershell
# Option A: Use automated script
.\quick_setup.ps1

# Option B: Manual setup
python setup_environment.py
```

#### Step 2: Activate Environment (Each session)
```powershell
.\boltz_venv\Scripts\Activate.ps1
```

#### Step 3: Generate Binders
```powershell
# Basic run with defaults
python run_binder_generation.py

# Or with custom options
python run_binder_generation.py --design_samples 3 --target_chains A
```

## 🎓 What You Need to Know

### Before You Start
1. **Python 3.10+** must be installed
2. **15GB free disk space** recommended
3. **GPU highly recommended** (10-50x faster than CPU)
4. **Internet connection** needed for setup (downloads ~2GB)

### During Setup
- Setup takes **15-30 minutes**
- Downloads model weights (~2GB)
- Creates isolated Python environment
- Everything is automated!

### During Execution
- Each design takes **30-60 minutes** (GPU) or **4-8 hours** (CPU)
- Default: 2 designs are generated
- Results saved automatically
- Can skip AlphaFold3 validation for faster testing

### After Completion
- Results in: `BoltzDesign1/outputs/.../03_af_pdb_success/`
- Look for PDB files and confidence scores
- Select top candidates with iPTM > 0.5 and pLDDT > 70

## 📖 Documentation Guide

| What You Need | Which File to Read | Time to Read |
|---------------|-------------------|--------------|
| Quick start | GET_STARTED.md | 5 min |
| Specific commands | QUICK_REFERENCE.md | 3 min |
| Full documentation | README.md | 15 min |
| File organization | FILES_INDEX.md | 3 min |
| Visual workflow | WORKFLOW_DIAGRAM.md | 5 min |

## 💡 Key Features

### Automated Setup
- ✅ Creates virtual environment
- ✅ Clones BoltzDesign1 repository
- ✅ Installs all dependencies
- ✅ Downloads model weights
- ✅ Configures LigandMPNN
- ✅ Validates installation

### Flexible Execution
- 🎯 Use default settings or customize everything
- 🎯 Specify target chains
- 🎯 Define binding sites
- 🎯 Control binder length
- 🎯 Skip validation for faster iteration
- 🎯 Generate multiple designs

### Smart Defaults
- Uses your `af3_tleap.pdb` automatically
- Sensible parameter defaults
- GPU auto-detection
- Clear error messages

## 🔥 Quick Command Reference

```powershell
# Check system before setup
python check_requirements.py

# One-click setup and run
.\quick_setup.ps1

# Manual setup
python setup_environment.py

# Activate environment (do this each time)
.\boltz_venv\Scripts\Activate.ps1

# Basic binder generation
python run_binder_generation.py

# Quick test (fast, skip validation)
python run_binder_generation.py --design_samples 1 --no-alphafold

# Multiple chains
python run_binder_generation.py --target_chains A,B

# Specific binding site
python run_binder_generation.py --contact_residues "100,101,102" --constraint_target A

# More designs
python run_binder_generation.py --design_samples 5

# Custom binder size
python run_binder_generation.py --length_min 120 --length_max 180

# Help on all options
python run_binder_generation.py --help
```

## 📊 What to Expect

### Timeline
```
Setup:           15-30 minutes (one-time)
Per Design:      30-60 minutes (GPU) or 4-8 hours (CPU)
Default Run:     1-2 hours (2 designs on GPU)
```

### Outputs
```
BoltzDesign1/outputs/protein_af3_tleap_boltz1/
└── 03_af_pdb_success/  ← Your best binders here!
    ├── design_1.pdb
    ├── design_2.pdb
    └── high_iptm_confidence_scores.csv
```

### Quality Metrics
- **iPTM > 0.5** → Good binding prediction
- **pLDDT > 70** → High confidence structure
- **Low PAE** → Reliable interface positioning

## 🆘 Common Issues & Solutions

| Problem | Solution |
|---------|----------|
| Import errors | Activate venv: `.\boltz_venv\Scripts\Activate.ps1` |
| Out of memory | Reduce samples: `--design_samples 1` |
| Takes too long | Skip validation: `--no-alphafold` |
| No GPU | Will use CPU (slower but works) |
| Setup fails | Check internet, run `check_requirements.py` |

## 🎯 Success Checklist

- [ ] Read GET_STARTED.md
- [ ] Run setup (quick_setup.ps1 or setup_environment.py)
- [ ] Verify setup completed successfully
- [ ] Activate virtual environment
- [ ] Run test with `--design_samples 1 --no-alphafold`
- [ ] Check outputs directory
- [ ] Run full pipeline
- [ ] Analyze confidence scores
- [ ] Select top candidates

## 🔗 Important Links

### Local Documentation
- All documentation is in this directory
- Start with GET_STARTED.md
- No internet needed to read docs

### External Resources
- **BoltzDesign1 GitHub:** https://github.com/yehlincho/BoltzDesign1
- **Research Paper:** https://www.biorxiv.org/content/10.1101/2025.04.06.647261v1
- **Google Colab Demo:** https://colab.research.google.com/github/yehlincho/BoltzDesign1/blob/main/Boltzdesign1.ipynb

## 📞 Getting Help

1. **Read the docs** - Start with GET_STARTED.md
2. **Run system check** - `python check_requirements.py`
3. **Check examples** - QUICK_REFERENCE.md has many examples
4. **BoltzDesign1 issues** - https://github.com/yehlincho/BoltzDesign1/issues
5. **Contact author** - yehlin@mit.edu

## ⚡ Pro Tips

1. **Start with quick test** to verify everything works
2. **Use GPU** if available (much faster)
3. **Skip AlphaFold3** during development for faster iteration
4. **Keep successful parameters** in a notebook for reference
5. **Monitor GPU usage** with `nvidia-smi` during runs
6. **Check confidence scores** before proceeding with designs
7. **Visualize results** in PyMOL or ChimeraX

## 🎉 Ready to Start!

### Quickest Start (Recommended):
```powershell
# This does everything:
.\quick_setup.ps1
```

### Next Steps After Setup:
```powershell
# 1. Activate environment
.\boltz_venv\Scripts\Activate.ps1

# 2. Run quick test
python run_binder_generation.py --design_samples 1 --no-alphafold

# 3. If successful, run full pipeline
python run_binder_generation.py --design_samples 3
```

## 📝 Notes

- **Experimental software** - Results should be experimentally validated
- **GPU highly recommended** - CPU is 10-50x slower
- **Large models** - ~2GB download during setup
- **Disk space** - 10-15GB needed
- **Python 3.10** - Recommended version

---

## 🌟 Summary

You now have a **complete, turnkey solution** for generating protein binders using BoltzDesign1. Everything is automated, documented, and ready to use. Just run the setup script and follow the documentation!

**The entire system is designed to be:**
- ✅ **Easy to setup** - One-click automated installation
- ✅ **Simple to use** - Clear commands with sensible defaults
- ✅ **Well documented** - Multiple guides for different needs
- ✅ **Flexible** - Customizable for your specific requirements
- ✅ **Professional** - Industry-standard tools and practices

**Good luck with your binder design! 🧬🎉**

---

*Created for Mayo Clinic MHC Electrostatics Project*  
*Date: January 20, 2025*  
*Based on BoltzDesign1 by Yehlin Cho et al.*

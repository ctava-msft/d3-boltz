# BoltzDesign1 for Mayo Clinic - File Index

## 📁 Directory Structure

```
d3-boltz/
├── 📘 GET_STARTED.md          ← START HERE! Quick start guide
├── 📗 README.md                Complete documentation
├── 📙 QUICK_REFERENCE.md       Command reference & examples
├── 📋 FILES_INDEX.md           This file
│
├── 🔧 Setup Scripts
│   ├── quick_setup.bat         One-click setup (Windows CMD)
│   ├── quick_setup.ps1         One-click setup (PowerShell)
│   ├── check_requirements.py  System requirements checker
│   └── setup_environment.py   Main setup script
│
├── 🚀 Execution Scripts  
│   └── run_binder_generation.py  Main binder generation script
│
├── 📂 Input Files
│   └── _inputs/
│       ├── af3_tleap.pdb           Your target structure
│       ├── af3_tleap_sequence.dat  Sequence data
│       └── *.dat                   Distance constraints
│
└── 📦 Generated After Setup
    ├── boltz_venv/                 Python virtual environment
    ├── BoltzDesign1/               Cloned repository
    │   ├── boltzdesign.py         Main BoltzDesign script
    │   ├── boltz/                 Boltz model package
    │   ├── LigandMPNN/            Sequence optimization
    │   └── outputs/               Results directory
    ├── requirements.txt            Python dependencies list
    └── ACTIVATION_INSTRUCTIONS.txt Environment activation help
```

## 📄 File Descriptions

### Documentation Files

| File | Purpose | When to Use |
|------|---------|-------------|
| **GET_STARTED.md** | Quick start guide | First time setup |
| **README.md** | Complete documentation | Reference and details |
| **QUICK_REFERENCE.md** | Command examples | Looking for specific commands |
| **FILES_INDEX.md** | This file | Understanding file organization |

### Setup Scripts

| File | Purpose | Usage |
|------|---------|-------|
| **quick_setup.bat** | Automated setup for Windows CMD | Double-click or `quick_setup.bat` |
| **quick_setup.ps1** | Automated setup for PowerShell | `.\quick_setup.ps1` |
| **check_requirements.py** | Check system compatibility | `python check_requirements.py` |
| **setup_environment.py** | Manual setup script | `python setup_environment.py` |

### Execution Scripts

| File | Purpose | Usage |
|------|---------|-------|
| **run_binder_generation.py** | Generate protein binders | `python run_binder_generation.py [options]` |

## 🎯 Quick Navigation

### I'm New Here
👉 Start with **GET_STARTED.md**

### I Want to Run It Now
👉 Execute **quick_setup.ps1** or **quick_setup.bat**

### I Need Specific Commands
👉 Check **QUICK_REFERENCE.md**

### I Want Full Details
👉 Read **README.md**

### I Have Issues
👉 Run **check_requirements.py** first

## 🔄 Typical Workflow

```
1. Read GET_STARTED.md
   ↓
2. Run quick_setup.ps1 (or setup_environment.py)
   ↓
3. Activate virtual environment
   ↓
4. Run run_binder_generation.py
   ↓
5. Find results in BoltzDesign1/outputs/
   ↓
6. Analyze high_iptm_confidence_scores.csv
   ↓
7. Select top candidates for experimental validation
```

## 📊 Input Files

### Your PDB Structure
- **Location:** `_inputs/af3_tleap.pdb`
- **Format:** Standard PDB format from tLEAP
- **Contains:** Your target protein structure
- **Usage:** Automatically used by `run_binder_generation.py`

### Sequence Data
- **Location:** `_inputs/af3_tleap_sequence.dat`
- **Purpose:** Sequence information (if needed)

### Constraint Files
- **Location:** `_inputs/*.dat`
- **Purpose:** Distance constraints for MD simulations
- **Note:** Not directly used by BoltzDesign1 but kept for reference

## 📦 Output Files (After Running)

### Main Results Directory
```
BoltzDesign1/outputs/protein_af3_tleap_boltz1/
└── protein_af3_tleap_boltz1/
    └── ligandmpnn_cutoff_4/
        ├── 01_lmpnn_redesigned_high_iptm/
        │   ├── yaml/                      Config files
        │   └── pdb/                       Redesigned structures
        │
        ├── 02_design_final_af3/           AlphaFold3 predictions
        │
        └── 03_af_pdb_success/             ⭐ FINAL RESULTS
            ├── *.pdb                      Top binder structures
            └── high_iptm_confidence_scores.csv  Quality metrics
```

### Key Output Files

| File | Description |
|------|-------------|
| `*.pdb` | 3D structures of designed binders |
| `high_iptm_confidence_scores.csv` | Quality metrics (iPTM, pLDDT) |
| `config.yaml` | Run configuration |
| `rmsd_results.csv` | Structural analysis |

## 🔑 Key Concepts

### Environment Files
- **boltz_venv/** - Isolated Python environment with all dependencies
- **requirements.txt** - List of installed packages

### Model Files (Downloaded During Setup)
- **~/.boltz/boltz1_conf.ckpt** - Boltz model weights (~2GB)
- **~/.boltz/ccd.pkl** - Chemical Component Dictionary
- **BoltzDesign1/LigandMPNN/model_params/** - LigandMPNN weights

## 📈 Execution Order

### First Time Setup (Do Once)
1. `python check_requirements.py` (optional)
2. `python setup_environment.py` or run `quick_setup.ps1`
3. Wait 15-30 minutes for downloads and installation

### Each Binder Generation Run
1. Activate environment: `.\boltz_venv\Scripts\Activate.ps1`
2. Run: `python run_binder_generation.py [options]`
3. Wait 1-2 hours (GPU) or 4-8 hours (CPU)
4. Check results in outputs directory

## 🎓 Learning Path

1. **Beginner:**
   - Read GET_STARTED.md
   - Run quick_setup.ps1
   - Try default settings first

2. **Intermediate:**
   - Read QUICK_REFERENCE.md
   - Experiment with different parameters
   - Try specifying binding sites

3. **Advanced:**
   - Read full README.md
   - Optimize parameters for your target
   - Use multiple design samples
   - Interpret confidence scores

## 💡 Tips

### Finding Your Way
- Lost? Check this FILES_INDEX.md
- Need help? Read GET_STARTED.md
- Want examples? See QUICK_REFERENCE.md
- Need details? Consult README.md

### Best Practices
- Always activate virtual environment before running
- Start with 1-2 designs for testing
- Use `--no-alphafold` for faster iteration
- Keep track of successful parameters
- Check GPU usage during runs

### Troubleshooting
1. Run `python check_requirements.py`
2. Check if environment is activated
3. Verify input file exists
4. Check available disk space and memory
5. Review error messages carefully

## 📞 Support Resources

### Documentation (Local)
- GET_STARTED.md - Quick start
- README.md - Complete guide
- QUICK_REFERENCE.md - Command reference

### External Resources
- BoltzDesign1 GitHub: https://github.com/yehlincho/BoltzDesign1
- Paper: https://www.biorxiv.org/content/10.1101/2025.04.06.647261v1
- Colab Demo: https://colab.research.google.com/github/yehlincho/BoltzDesign1/blob/main/Boltzdesign1.ipynb

### Contact
- BoltzDesign1 Issues: https://github.com/yehlincho/BoltzDesign1/issues
- Author: yehlin@mit.edu

---

**Last Updated:** 2025-01-20
**Version:** 1.0
**For:** Mayo Clinic MHC Electrostatics Project

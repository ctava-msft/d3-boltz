# 🧬 BoltzDesign1 Binder Generation

**Generate AI-designed protein binders for your target structure**

---

## 🎯 What This Does

Uses state-of-the-art AI (BoltzDesign1) to design protein binders that specifically bind to your target structure in `_inputs/af3_tleap.pdb`.

**Based on:** [BoltzDesign1](https://github.com/yehlincho/BoltzDesign1) - Inverting all-atom structure prediction for biomolecular binder design

---

## ⚡ Quick Start (3 Steps)

### 1️⃣ Run Setup (One Time, ~20 minutes)
```powershell
.\quick_setup.ps1
```

### 2️⃣ Activate Environment (Each Session)
```powershell
.\boltz_venv\Scripts\Activate.ps1
```

### 3️⃣ Generate Binders
```powershell
python run_binder_generation.py
```

**That's it!** Results will be in `BoltzDesign1/outputs/.../03_af_pdb_success/`

---

## 📚 Documentation

| Document | Purpose | Read Time |
|----------|---------|-----------|
| **[🚀 GET_STARTED.md](GET_STARTED.md)** | Quick start guide | 5 min |
| **[📖 README.md](README.md)** | Complete documentation | 15 min |
| **[⚡ QUICK_REFERENCE.md](QUICK_REFERENCE.md)** | Command examples | 3 min |
| **[📊 WORKFLOW_DIAGRAM.md](WORKFLOW_DIAGRAM.md)** | Visual workflows | 5 min |
| **[📁 FILES_INDEX.md](FILES_INDEX.md)** | File organization | 3 min |
| **[📝 SUMMARY.md](SUMMARY.md)** | Complete summary | 5 min |

---

## 🎮 Common Commands

```powershell
# Quick test (faster, skip validation)
python run_binder_generation.py --design_samples 1 --no-alphafold

# Generate 5 designs
python run_binder_generation.py --design_samples 5

# Specify target chains
python run_binder_generation.py --target_chains A,B

# Define binding site
python run_binder_generation.py --contact_residues "100,101,102" --constraint_target A

# Larger binders
python run_binder_generation.py --length_min 150 --length_max 200

# See all options
python run_binder_generation.py --help
```

---

## 📦 What Gets Installed

During setup:
- ✅ Python virtual environment
- ✅ BoltzDesign1 repository (~200MB)
- ✅ Boltz model weights (~2GB)
- ✅ LigandMPNN models (~500MB)
- ✅ All Python dependencies

**Total:** ~3-4GB, takes 15-30 minutes

---

## ⏱️ How Long Does It Take?

| Configuration | Time (GPU) | Time (CPU) |
|--------------|-----------|-----------|
| Quick test (1 design, no validation) | ~30 min | ~4 hours |
| Standard (2 designs, full pipeline) | ~1-2 hours | ~8-16 hours |
| High-throughput (5 designs, no validation) | ~2 hours | ~20 hours |

**💡 Tip:** Use `--no-alphafold` for faster iteration during development

---

## 🎯 Expected Results

### Output Structure
```
BoltzDesign1/outputs/protein_af3_tleap_boltz1/
└── protein_af3_tleap_boltz1/
    └── ligandmpnn_cutoff_4/
        └── 03_af_pdb_success/  ⭐ YOUR RESULTS HERE
            ├── design_1.pdb
            ├── design_2.pdb
            └── high_iptm_confidence_scores.csv
```

### Quality Metrics
Good binder candidates typically have:
- ✅ **iPTM > 0.5** (interface confidence)
- ✅ **pLDDT > 70** (structure confidence)
- ✅ **Low PAE** at binding interface

---

## 💻 System Requirements

### Required
- ✅ Python 3.10 or newer
- ✅ 10GB free disk space (15GB recommended)
- ✅ 8GB RAM (16GB recommended)
- ✅ Internet connection (for setup)
- ✅ Windows 10/11, Linux, or macOS

### Recommended
- 💎 NVIDIA GPU with CUDA (10-50x faster!)
- 💎 16GB+ RAM
- 💎 SSD for faster I/O

---

## 🆘 Troubleshooting

| Problem | Quick Fix |
|---------|-----------|
| Import errors | Run: `.\boltz_venv\Scripts\Activate.ps1` |
| Out of memory | Use: `--design_samples 1` |
| Too slow | Add: `--no-alphafold` |
| Setup fails | Run: `python check_requirements.py` |

**For more help:** See [GET_STARTED.md](GET_STARTED.md#troubleshooting)

---

## 🔗 Links

- **BoltzDesign1 Repository:** https://github.com/yehlincho/BoltzDesign1
- **Research Paper:** https://www.biorxiv.org/content/10.1101/2025.04.06.647261v1
- **Google Colab Demo:** https://colab.research.google.com/github/yehlincho/BoltzDesign1/blob/main/Boltzdesign1.ipynb
- **Issues/Support:** https://github.com/yehlincho/BoltzDesign1/issues

---

## 📋 Pre-Run Checklist

Before running, make sure:
- [ ] Python 3.10+ installed
- [ ] 15GB free disk space
- [ ] Internet connection for setup
- [ ] GPU drivers installed (if using GPU)
- [ ] Input file exists: `_inputs/af3_tleap.pdb`

---

## 🎓 How It Works

```
Your Target → BoltzDesign → LigandMPNN → AlphaFold3 → Binder Designs
(af3_tleap.pdb)  (Structure)   (Sequence)   (Validate)   (*.pdb + scores)
```

**BoltzDesign1 uses:**
1. **Gradient-based optimization** to generate initial binder structures
2. **LigandMPNN** to optimize amino acid sequences
3. **AlphaFold3** to validate designs (optional)

---

## ⚠️ Important Notes

- **Experimental software** - Results need experimental validation
- **GPU strongly recommended** - CPU is 10-50x slower
- **Large downloads** - ~2GB of model weights during setup
- **Not validated** - Computational predictions, not lab-tested

---

## 📞 Support

1. **Local docs:** Start with [GET_STARTED.md](GET_STARTED.md)
2. **System check:** Run `python check_requirements.py`
3. **Examples:** See [QUICK_REFERENCE.md](QUICK_REFERENCE.md)
4. **GitHub Issues:** https://github.com/yehlincho/BoltzDesign1/issues
5. **Author:** yehlin@mit.edu

---

## 🌟 Features

- ✨ **One-click setup** - Automated installation
- ✨ **Smart defaults** - Works out of the box
- ✨ **Fully customizable** - Control all parameters
- ✨ **Well documented** - Multiple guides included
- ✨ **GPU accelerated** - Fast with NVIDIA GPUs
- ✨ **Professional tools** - State-of-the-art AI models

---

## 📊 Success Stories

BoltzDesign1 has been used to design binders for:
- ✅ Protein-protein interfaces
- ✅ DNA/RNA binding proteins
- ✅ Small molecule binders
- ✅ Peptide mimetics

See the [paper](https://www.biorxiv.org/content/10.1101/2025.04.06.647261v1) for examples and validation.

---

## 🎉 Ready to Start?

**New users:** Read [GET_STARTED.md](GET_STARTED.md) (5 minutes)

**Quick start:**
```powershell
.\quick_setup.ps1
```

**Questions?** Check [QUICK_REFERENCE.md](QUICK_REFERENCE.md) for examples

---

## 📄 Citation

If you use BoltzDesign1, please cite:

```bibtex
@article{cho2025boltzdesign1,
  title={Boltzdesign1: Inverting all-atom structure prediction model 
         for generalized biomolecular binder design},
  author={Cho, Yehlin and Pacesa, Martin and Zhang, Zhidian and 
          Correia, Bruno E and Ovchinnikov, Sergey},
  journal={bioRxiv},
  year={2025}
}
```

---

## 📜 License

This implementation uses BoltzDesign1, which is released under the MIT License.

---

**Created for Mayo Clinic MHC Electrostatics Project**  
**Date:** January 20, 2025  
**Version:** 1.0

---

<div align="center">

**🧬 Happy Binder Design! 🎉**

[Get Started](GET_STARTED.md) • [Documentation](README.md) • [Examples](QUICK_REFERENCE.md)

</div>

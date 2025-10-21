# Quick Reference Guide - BoltzDesign1 Common Use Cases

## 🚀 Quick Start Commands

### Basic Setup and Run
```powershell
# 1. Setup (run once)
python setup_environment.py

# 2. Activate environment
.\boltz_venv\Scripts\Activate.ps1

# 3. Run with defaults
python run_binder_generation.py
```

## 📋 Common Use Cases

### 1. Basic Protein Binder Design
Generate binders for a protein target:
```powershell
python run_binder_generation.py \
    --pdb _inputs/af3_tleap.pdb \
    --target_type protein \
    --target_chains A \
    --design_samples 3
```

### 2. Multi-Chain Protein Target
Design binders for a complex with multiple chains:
```powershell
python run_binder_generation.py \
    --target_chains A,B,C \
    --design_samples 5
```

### 3. Specific Binding Site
Target specific residues for binding:
```powershell
python run_binder_generation.py \
    --contact_residues "100,101,102,150,151" \
    --constraint_target A \
    --design_samples 3
```

### 4. DNA/RNA Binder Design
Generate protein binders for nucleic acids:
```powershell
python run_binder_generation.py \
    --target_type dna \
    --target_chains C,D \
    --design_samples 5
```

### 5. Fast Prototyping (Skip Validation)
Quick design without AlphaFold3 validation:
```powershell
python run_binder_generation.py \
    --design_samples 2 \
    --no-alphafold \
    --no-ligandmpnn
```

### 6. Large Binder Design
Design larger binders (e.g., for large binding surface):
```powershell
python run_binder_generation.py \
    --length_min 150 \
    --length_max 200 \
    --design_samples 3
```

### 7. Small Compact Binder
Design smaller, compact binders:
```powershell
python run_binder_generation.py \
    --length_min 60 \
    --length_max 100 \
    --design_samples 3
```

### 8. Beta-Sheet Rich Binder
Favor beta sheets over alpha helices:
```powershell
python run_binder_generation.py \
    --design_samples 3 \
    # Note: Add to BoltzDesign1 command:
    # --helix_loss_max -0.3 --helix_loss_min -0.6
```

### 9. High-Throughput Design
Generate many designs for screening:
```powershell
python run_binder_generation.py \
    --design_samples 10 \
    --no-alphafold
```

### 10. Custom Output Location
Save results to a specific directory:
```powershell
python run_binder_generation.py \
    --output_dir D:\BoltzResults \
    --design_samples 3
```

## 🎯 Parameter Quick Reference

### Target Configuration
| Parameter | Description | Example |
|-----------|-------------|---------|
| `--pdb` | Input PDB file path | `_inputs/af3_tleap.pdb` |
| `--target_type` | Target molecule type | `protein`, `dna`, `rna` |
| `--target_chains` | Target chain IDs | `A`, `A,B`, `C,D` |

### Design Parameters
| Parameter | Description | Default | Typical Range |
|-----------|-------------|---------|---------------|
| `--design_samples` | Number of designs | 2 | 1-10 |
| `--length_min` | Min binder length | 100 | 50-150 |
| `--length_max` | Max binder length | 150 | 100-200 |

### Binding Site Constraints
| Parameter | Description | Example |
|-----------|-------------|---------|
| `--contact_residues` | Specific contact residues | `"100,101,105"` |
| `--constraint_target` | Target chain for contacts | `A` |

### Performance Options
| Flag | Effect |
|------|--------|
| `--no-msa` | Skip MSA generation (faster) |
| `--no-alphafold` | Skip AF3 validation (much faster) |
| `--no-ligandmpnn` | Skip sequence redesign |
| `--gpu_id 0` | Specify GPU device |

## 📊 Understanding Output Metrics

### iPTM (Interface PTM Score)
- **> 0.8**: Excellent predicted binding
- **0.5 - 0.8**: Good predicted binding
- **< 0.5**: Weak predicted binding

### pLDDT (Confidence Score)
- **> 90**: Very high confidence
- **70 - 90**: High confidence
- **50 - 70**: Low confidence
- **< 50**: Very low confidence (likely disordered)

### Where to Find Results
```
BoltzDesign1/outputs/protein_af3_tleap_boltz1/
└── protein_af3_tleap_boltz1/
    └── ligandmpnn_cutoff_4/
        ├── 01_lmpnn_redesigned_high_iptm/
        │   └── yaml/                      # Input configs
        ├── 03_af_pdb_success/             # ⭐ BEST DESIGNS HERE
        │   ├── *.pdb                      # Structure files
        │   └── high_iptm_confidence_scores.csv  # Scores
        └── 02_design_final_af3/           # AF3 predictions
```

## 🔧 Troubleshooting Quick Fixes

### Problem: Out of Memory
**Solution:**
```powershell
python run_binder_generation.py --design_samples 1
```

### Problem: Takes Too Long
**Solution:**
```powershell
python run_binder_generation.py \
    --design_samples 2 \
    --no-alphafold
```

### Problem: No GPU Available
**Solution:** Install CUDA toolkit or run on CPU (slower):
```powershell
# Check GPU availability
python -c "import torch; print(f'CUDA Available: {torch.cuda.is_available()}')"
```

### Problem: Import Errors
**Solution:** Reactivate virtual environment:
```powershell
.\boltz_venv\Scripts\Activate.ps1
python run_binder_generation.py
```

### Problem: Binders Not Compact Enough
**Solution:** Use direct BoltzDesign1 parameters:
```powershell
# Edit run_binder_generation.py or call boltzdesign.py directly with:
# --num_intra_contacts 4
```

### Problem: Weak Target Interaction
**Solution:** Use direct BoltzDesign1 parameters:
```powershell
# --num_inter_contacts 4
```

## 📁 File Locations After Setup

```
d3-boltz/
├── setup_environment.py           # Setup script
├── run_binder_generation.py       # Main runner script
├── README.md                      # Full documentation
├── QUICK_REFERENCE.md             # This file
├── requirements.txt               # Python dependencies (auto-generated)
├── _inputs/
│   └── af3_tleap.pdb             # Your input structure
├── boltz_venv/                    # Virtual environment (created by setup)
└── BoltzDesign1/                  # Cloned repository (created by setup)
    ├── boltzdesign.py            # Main BoltzDesign script
    ├── boltz/                    # Boltz model package
    ├── LigandMPNN/               # LigandMPNN for sequence design
    └── outputs/                  # Results directory
```

## 🎓 Learning Path

1. **Start Simple:** Run with defaults to understand the workflow
   ```powershell
   python run_binder_generation.py
   ```

2. **Experiment with Parameters:** Try different binder lengths
   ```powershell
   python run_binder_generation.py --length_min 80 --length_max 120
   ```

3. **Add Constraints:** Specify binding sites if known
   ```powershell
   python run_binder_generation.py --contact_residues "100,101,102"
   ```

4. **Optimize Speed:** Use fast mode for iteration
   ```powershell
   python run_binder_generation.py --no-alphafold --design_samples 5
   ```

5. **Final Validation:** Run full pipeline on best designs
   ```powershell
   python run_binder_generation.py --design_samples 3
   ```

## 💡 Pro Tips

1. **Start with 2-3 designs** to test the pipeline, then scale up
2. **Use `--no-alphafold`** during development for faster iteration
3. **Save successful configurations** by keeping note of working parameters
4. **Check GPU usage** with `nvidia-smi` during runs
5. **Run multiple jobs** with different parameters in parallel (different `--suffix`)

## 🔗 Quick Links

- **BoltzDesign1 Repo:** https://github.com/yehlincho/BoltzDesign1
- **Paper:** https://www.biorxiv.org/content/10.1101/2025.04.06.647261v1
- **Google Colab Demo:** https://colab.research.google.com/github/yehlincho/BoltzDesign1/blob/main/Boltzdesign1.ipynb

## ⚡ One-Liner Cheat Sheet

```powershell
# Full setup and run in one session
python setup_environment.py && .\boltz_venv\Scripts\Activate.ps1 && python run_binder_generation.py

# Quick test run
python run_binder_generation.py --design_samples 1 --no-alphafold

# Production run
python run_binder_generation.py --design_samples 5 --contact_residues "100,101,102" --constraint_target A

# High-throughput screening
python run_binder_generation.py --design_samples 10 --no-alphafold --length_min 80 --length_max 120
```

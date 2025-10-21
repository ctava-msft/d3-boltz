# BoltzDesign1 Workflow Overview

## 🎯 Goal
Generate protein binders for the target structure in `af3_tleap.pdb`

## 📋 Complete Workflow

```
┌─────────────────────────────────────────────────────────────┐
│                     SETUP PHASE (Once)                       │
└─────────────────────────────────────────────────────────────┘
                              │
                              ▼
        ┌────────────────────────────────────────┐
        │  1. Check System Requirements          │
        │     python check_requirements.py       │
        │     ✓ Python 3.10+                    │
        │     ✓ Git installed                   │
        │     ✓ 15GB disk space                 │
        │     ✓ 16GB RAM                        │
        │     ✓ GPU (optional but recommended)  │
        └────────────────────────────────────────┘
                              │
                              ▼
        ┌────────────────────────────────────────┐
        │  2. Run Setup Script                   │
        │     python setup_environment.py        │
        │     OR: quick_setup.ps1               │
        │                                        │
        │     • Creates virtual environment      │
        │     • Clones BoltzDesign1 repo        │
        │     • Installs dependencies           │
        │     • Downloads models (~2GB)         │
        │     ⏱ Takes 15-30 minutes            │
        └────────────────────────────────────────┘
                              │
                              ▼
┌─────────────────────────────────────────────────────────────┐
│                  EXECUTION PHASE (Each Run)                  │
└─────────────────────────────────────────────────────────────┘
                              │
                              ▼
        ┌────────────────────────────────────────┐
        │  3. Activate Virtual Environment       │
        │     .\boltz_venv\Scripts\Activate.ps1  │
        │     You'll see: (boltz_venv)           │
        └────────────────────────────────────────┘
                              │
                              ▼
        ┌────────────────────────────────────────┐
        │  4. Run Binder Generation              │
        │     python run_binder_generation.py    │
        │                                        │
        │     Input: _inputs/af3_tleap.pdb      │
        │     ⏱ Takes 1-2 hours (GPU)          │
        │     ⏱ Takes 4-8 hours (CPU)          │
        └────────────────────────────────────────┘
                              │
                              ▼
        ┌────────────────────────────────────────┐
        │         BOLTZDESIGN STAGE              │
        │  • Gradient-based optimization         │
        │  • Generate initial binder structures  │
        │  • Optimize binding interface          │
        │  ⏱ ~30-60 min per design             │
        └────────────────────────────────────────┘
                              │
                              ▼
        ┌────────────────────────────────────────┐
        │         LIGANDMPNN STAGE               │
        │  • Sequence redesign                   │
        │  • Optimize amino acid sequences       │
        │  • Fix interface residues              │
        │  ⏱ ~5-10 min per design              │
        └────────────────────────────────────────┘
                              │
                              ▼
        ┌────────────────────────────────────────┐
        │         ALPHAFOLD3 STAGE               │
        │  • Structure prediction                │
        │  • Validation of designs               │
        │  • Confidence scoring                  │
        │  ⏱ ~10-20 min per design             │
        │  (Can be skipped with --no-alphafold) │
        └────────────────────────────────────────┘
                              │
                              ▼
┌─────────────────────────────────────────────────────────────┐
│                      RESULTS PHASE                           │
└─────────────────────────────────────────────────────────────┘
                              │
                              ▼
        ┌────────────────────────────────────────┐
        │  5. Analyze Results                    │
        │                                        │
        │  Location:                             │
        │  BoltzDesign1/outputs/.../             │
        │  03_af_pdb_success/                    │
        │                                        │
        │  Files:                                │
        │  • *.pdb - 3D structures              │
        │  • high_iptm_confidence_scores.csv    │
        └────────────────────────────────────────┘
                              │
                              ▼
        ┌────────────────────────────────────────┐
        │  6. Select Top Candidates              │
        │                                        │
        │  Criteria:                             │
        │  ✓ iPTM > 0.5                         │
        │  ✓ pLDDT > 70                         │
        │  ✓ Low PAE at interface               │
        │                                        │
        │  → Ready for experimental validation   │
        └────────────────────────────────────────┘
```

## 🗂️ File Flow

```
INPUT                       PROCESSING                    OUTPUT
─────                       ──────────                    ──────

_inputs/
└── af3_tleap.pdb    →    BoltzDesign1     →    outputs/
                           ┌─────────┐           └── protein_af3_tleap_boltz1/
                           │ Boltz   │               ├── results_final/
                           │ Design  │               │   └── *.cif (initial)
                           └────┬────┘               │
                                │                    ├── ligandmpnn_cutoff_4/
                           ┌────▼────┐               │   ├── 01_lmpnn_redesigned/
                           │Ligand   │               │   │   └── *.pdb (redesigned)
                           │ MPNN    │               │   │
                           └────┬────┘               │   ├── 02_design_final_af3/
                                │                    │   │   └── *_predicted.cif
                           ┌────▼────┐               │   │
                           │AlphaFold│               │   └── 03_af_pdb_success/ ⭐
                           │   3     │               │       ├── *.pdb (FINAL)
                           └─────────┘               │       └── confidence.csv
```

## 🎮 Command Options Quick View

```
python run_binder_generation.py

BASIC OPTIONS:
  --pdb PATH                  Input PDB file
  --target_type TYPE          protein|dna|rna|small_molecule
  --target_chains CHAINS      Chain IDs (e.g., A or A,B)
  --design_samples N          Number of designs to generate

DESIGN CONTROL:
  --length_min N              Minimum binder length (default: 100)
  --length_max N              Maximum binder length (default: 150)
  --contact_residues "X,Y,Z"  Specific binding site residues
  --constraint_target CHAIN   Target chain for constraints

PERFORMANCE:
  --gpu_id N                  GPU device to use (default: 0)
  --no-msa                    Skip MSA generation (faster)
  --no-alphafold              Skip AlphaFold3 validation (much faster)
  --no-ligandmpnn             Skip LigandMPNN redesign

OUTPUT:
  --output_dir PATH           Custom output location
  --suffix NAME               Output directory suffix
```

## ⏱️ Time Estimates

| Stage | GPU Time | CPU Time | Can Skip? |
|-------|----------|----------|-----------|
| BoltzDesign | 30-60 min | 4-6 hours | ❌ No |
| LigandMPNN | 5-10 min | 10-20 min | ✅ Yes (--no-ligandmpnn) |
| AlphaFold3 | 10-20 min | 1-2 hours | ✅ Yes (--no-alphafold) |
| **Total** | **1-2 hours** | **4-8 hours** | |

## 💾 Disk Space Requirements

| Component | Size | Required? |
|-----------|------|-----------|
| Virtual Environment | ~2 GB | Yes |
| Boltz Model Weights | ~2 GB | Yes |
| LigandMPNN Models | ~500 MB | Yes |
| Output Files (per design) | ~50-100 MB | Yes |
| **Minimum Total** | **~5 GB** | |
| **Recommended Total** | **15+ GB** | |

## 🎯 Success Metrics

```
Good Binder Candidate:
┌─────────────────────────────────────┐
│ Metric      │ Value  │ Status       │
├─────────────────────────────────────┤
│ iPTM        │ > 0.5  │ ✅ Good      │
│ pLDDT       │ > 70   │ ✅ Good      │
│ Interface   │ < 5 Å  │ ✅ Close     │
│ PAE         │ Low    │ ✅ Confident │
└─────────────────────────────────────┘

Poor Binder Candidate:
┌─────────────────────────────────────┐
│ Metric      │ Value  │ Status       │
├─────────────────────────────────────┤
│ iPTM        │ < 0.3  │ ❌ Poor      │
│ pLDDT       │ < 50   │ ❌ Poor      │
│ Interface   │ > 10 Å │ ❌ Far       │
│ PAE         │ High   │ ❌ Uncertain │
└─────────────────────────────────────┘
```

## 🔄 Iteration Strategies

### Strategy 1: Fast Prototyping
```
1. Run with --no-alphafold
2. Generate 5-10 designs quickly
3. Visual inspection
4. Select best → Full validation
```

### Strategy 2: Conservative
```
1. Start with 2 designs, full pipeline
2. Analyze results carefully
3. Adjust parameters
4. Run 3-5 more with optimized settings
```

### Strategy 3: High-Throughput
```
1. Run 10 designs with --no-alphafold
2. Quick filter by Boltz metrics
3. Take top 5
4. Run AlphaFold3 validation separately
```

## 🆘 Troubleshooting Flow

```
Problem?
    │
    ├─ Import Error
    │   └─ Activate venv: .\boltz_venv\Scripts\Activate.ps1
    │
    ├─ Out of Memory
    │   └─ Reduce samples: --design_samples 1
    │
    ├─ Takes Too Long
    │   └─ Skip validation: --no-alphafold
    │
    ├─ Poor Results
    │   ├─ Add constraints: --contact_residues "X,Y,Z"
    │   └─ Adjust length: --length_min --length_max
    │
    └─ GPU Not Found
        └─ Check CUDA: python -c "import torch; print(torch.cuda.is_available())"
```

## 📞 Quick Help

- **Setup issues?** → Check GET_STARTED.md
- **Need commands?** → See QUICK_REFERENCE.md
- **Full details?** → Read README.md
- **System check?** → Run check_requirements.py

---

**Ready to start?** Run: `python quick_setup.ps1` or `python setup_environment.py`

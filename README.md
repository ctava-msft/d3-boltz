# BoltzDesign1 Binder Generation Setup

This directory contains scripts to set up and run BoltzDesign1 for generating protein binders using your `af3_tleap.pdb` file.

## Overview

BoltzDesign1 is a molecular design tool that uses the Boltz model to design protein binders that interact with target biomolecules (proteins, DNA, RNA, small molecules, etc.).

**Reference:** https://github.com/yehlincho/BoltzDesign1

## Files in This Directory

- **`setup_environment.py`** - Creates virtual environment and installs all dependencies
- **`run_binder_generation.py`** - Main script to generate binders for your PDB file
- **`_inputs/af3_tleap.pdb`** - Your input structure file
- **`_inputs/af3_tleap_sequence.dat`** - Sequence data
- **`_inputs/*.dat`** - Distance bias constraint files

## Quick Start

### Step 1: Setup Environment

Run the setup script to create a Python virtual environment and install all dependencies:

```powershell
python setup_environment.py
```

This will:
- ✅ Create a virtual environment in `boltz_venv/`
- ✅ Clone the BoltzDesign1 repository
- ✅ Install Boltz and all required packages
- ✅ Download Boltz model weights (~2GB)
- ✅ Download LigandMPNN model parameters
- ✅ Set up all dependencies

**Note:** This process may take 15-30 minutes depending on your internet connection.

### Step 2: Activate the Virtual Environment

**Windows PowerShell:**
```powershell
.\boltz_venv\Scripts\Activate.ps1
```

**Windows Command Prompt:**
```cmd
boltz_venv\Scripts\activate.bat
```

**Linux/Mac:**
```bash
source boltz_venv/bin/activate
```

### Step 3: Generate Binders

Once the environment is activated, run the binder generation:

```powershell
python run_binder_generation.py
```

This will use the default settings:
- Input: `_inputs/af3_tleap.pdb`
- Target type: protein
- Target chain: A
- Number of designs: 2
- GPU: 0

## Advanced Usage

### Custom Target Chains

If your target consists of specific chains:

```powershell
python run_binder_generation.py --target_chains A,B
```

### Generate More Designs

To create more binder candidates:

```powershell
python run_binder_generation.py --design_samples 5
```

### Specify Binding Site

If you know specific residues that should be in the binding interface:

```powershell
python run_binder_generation.py --contact_residues "100,101,105,200" --constraint_target A
```

### DNA/RNA Targets

If your target is DNA or RNA:

```powershell
python run_binder_generation.py --target_type dna --target_chains C,D
```

### Control Binder Length

Specify minimum and maximum binder length:

```powershell
python run_binder_generation.py --length_min 120 --length_max 180
```

### Faster Execution (Skip AlphaFold3)

To speed up the pipeline by skipping AlphaFold3 validation:

```powershell
python run_binder_generation.py --no-alphafold
```

### Custom Output Directory

Save results to a specific location:

```powershell
python run_binder_generation.py --output_dir ../results
```

## Full Command-Line Options

```
usage: run_binder_generation.py [-h] [--pdb PDB] 
       [--target_type {protein,dna,rna,small_molecule,metal}]
       [--target_chains TARGET_CHAINS] [--design_samples DESIGN_SAMPLES]
       [--gpu_id GPU_ID] [--suffix SUFFIX] [--no-msa] [--output_dir OUTPUT_DIR]
       [--contact_residues CONTACT_RESIDUES] [--constraint_target CONSTRAINT_TARGET]
       [--length_min LENGTH_MIN] [--length_max LENGTH_MAX]
       [--no-alphafold] [--no-ligandmpnn]

Options:
  --pdb PDB             Path to input PDB file
  --target_type         Type of target (protein, dna, rna, small_molecule, metal)
  --target_chains       Comma-separated chain IDs for target
  --design_samples      Number of binder designs to generate
  --gpu_id             GPU device ID to use
  --suffix             Suffix for output directory naming
  --no-msa             Disable MSA generation
  --output_dir         Custom output directory
  --contact_residues   Binding site residues (comma-separated)
  --constraint_target  Target chain for constraints
  --length_min         Minimum binder length (default: 100)
  --length_max         Maximum binder length (default: 150)
  --no-alphafold       Skip AlphaFold3 validation (faster)
  --no-ligandmpnn      Skip LigandMPNN redesign step
```

## Pipeline Steps

The complete BoltzDesign1 pipeline consists of:

1. **BoltzDesign** - Generate initial binder structures using gradient-based optimization
2. **LigandMPNN** - Redesign sequences to optimize binding
3. **AlphaFold3** - Validate designs with structure prediction (optional)

## Output Structure

Results will be saved in:
```
BoltzDesign1/outputs/{target_type}_{target_name}_{suffix}/
├── {version}/
│   ├── results_final/           # Initial Boltz designs
│   └── ligandmpnn_cutoff_{X}/   # LigandMPNN redesigned binders
│       ├── 01_lmpnn_redesigned_high_iptm/  # High-confidence redesigns
│       ├── 02_design_json_af3/             # AlphaFold3 inputs
│       └── 03_af_pdb_success/              # Final validated designs ⭐
```

High-confidence designs can be found in the `03_af_pdb_success/` directory with accompanying confidence scores.

## Understanding Results

### Key Metrics

- **iPTM (Interface Predicted TM-score)** - Measures predicted binding interface quality (higher is better, >0.5 is good)
- **pLDDT (predicted Local Distance Difference Test)** - Per-residue confidence score (0-100, >70 is good)
- **PAE (Predicted Aligned Error)** - Confidence in relative position of residues

### Success Criteria

Good binder candidates typically have:
- iPTM > 0.5
- Complex pLDDT > 70
- Low PAE at the interface

These are saved in `high_iptm_confidence_scores.csv`.

## Optimization Tips

### If binders are not compact:
```powershell
python run_binder_generation.py --num_intra_contacts 4
```

### If target-binder interaction is weak:
```powershell
python run_binder_generation.py --num_inter_contacts 4
```

### To favor beta sheets over helices:
```powershell
python run_binder_generation.py --helix_loss_max -0.3 --helix_loss_min -0.6
```

## System Requirements

- **GPU:** NVIDIA GPU with CUDA support (recommended)
- **RAM:** 16GB+ recommended
- **Disk Space:** ~10GB for models and dependencies
- **Python:** 3.10+ (3.10 recommended)
- **OS:** Windows, Linux, or macOS

## Troubleshooting

### Import Errors After Setup

Make sure you've activated the virtual environment:
```powershell
.\boltz_venv\Scripts\Activate.ps1
```

### Out of Memory Errors

Try reducing batch size or using fewer design samples:
```powershell
python run_binder_generation.py --design_samples 1
```

### CUDA/GPU Issues

If GPU is not available, the pipeline will fall back to CPU (much slower). To verify GPU:
```powershell
python -c "import torch; print(torch.cuda.is_available())"
```

### Missing Model Files

If model downloads fail, manually download from:
- Boltz weights: https://huggingface.co/boltz-community/boltz-1
- LigandMPNN: https://files.ipd.uw.edu/pub/ligandmpnn/

## Additional Resources

- **BoltzDesign1 Paper:** https://www.biorxiv.org/content/10.1101/2025.04.06.647261v1
- **BoltzDesign1 GitHub:** https://github.com/yehlincho/BoltzDesign1
- **Google Colab Version:** https://colab.research.google.com/github/yehlincho/BoltzDesign1/blob/main/Boltzdesign1.ipynb

## Citation

If you use BoltzDesign1 in your research, please cite:

```bibtex
@article{cho2025boltzdesign1,
  title={Boltzdesign1: Inverting all-atom structure prediction model for generalized biomolecular binder design},
  author={Cho, Yehlin and Pacesa, Martin and Zhang, Zhidian and Correia, Bruno E and Ovchinnikov, Sergey},
  journal={bioRxiv},
  pages={2025--04},
  year={2025},
  publisher={Cold Spring Harbor Laboratory}
}
```

## Important Disclaimer

⚠️ **EXPERIMENTAL SOFTWARE:** This pipeline is under active development and has NOT been experimentally validated in laboratory settings. Results should be validated independently before experimental use.

## Support

For issues specific to:
- **This setup:** Check this README or the scripts' help messages
- **BoltzDesign1:** https://github.com/yehlincho/BoltzDesign1/issues
- **General questions:** yehlin@mit.edu

## License

This implementation uses BoltzDesign1, which is released under the MIT License.

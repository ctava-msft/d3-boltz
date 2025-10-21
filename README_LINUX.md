# BoltzDesign1 Linux Setup with A100 GPU

This guide provides instructions for running BoltzDesign1 on Ubuntu Linux with an NVIDIA A100 GPU.

## Prerequisites

### System Requirements
- Ubuntu 20.04 or 22.04 LTS
- NVIDIA A100 GPU (or other CUDA-capable GPU)
- NVIDIA Driver >= 525.x
- CUDA Toolkit 12.1 or higher
- Python 3.9-3.12
- 32+ GB RAM recommended
- 50+ GB free disk space

### Installing NVIDIA Drivers and CUDA

If you don't have NVIDIA drivers installed:

```bash
# Check current driver
nvidia-smi

# If not installed, install NVIDIA drivers
sudo apt update
sudo apt install nvidia-driver-535

# Reboot
sudo reboot

# Install CUDA Toolkit (if not already installed)
wget https://developer.download.nvidia.com/compute/cuda/12.1.0/local_installers/cuda_12.1.0_530.30.02_linux.run
sudo sh cuda_12.1.0_530.30.02_linux.run

# Add to PATH (add to ~/.bashrc for persistence)
export CUDA_HOME=/usr/local/cuda
export PATH=$CUDA_HOME/bin:$PATH
export LD_LIBRARY_PATH=$CUDA_HOME/lib64:$LD_LIBRARY_PATH
```

## Installation

### 1. Clone or Transfer Files

Transfer your d3-boltz directory to your Linux machine, or start fresh:

```bash
# Create project directory
mkdir -p ~/projects/d3-boltz
cd ~/projects/d3-boltz

# Copy your input PDB file
mkdir -p _inputs
cp /path/to/your/af3_tleap.pdb _inputs/
```

### 2. Run Setup Script

Make the setup script executable and run it:

```bash
chmod +x linux_setup.sh
./linux_setup.sh
```

This script will:
- Check for NVIDIA GPU and CUDA
- Create Python virtual environment
- Install PyTorch with CUDA support
- Install Boltz and all dependencies
- Clone BoltzDesign1 repository
- Apply BioPython ProDy patch
- Download Boltz model weights (~2GB)

**Note:** The setup will take 10-20 minutes depending on your internet connection.

## Running Binder Generation

### Basic Usage

Make the run script executable and run it:

```bash
chmod +x run_binder_gpu.sh
./run_binder_gpu.sh
```

This will run with default settings:
- Input: `_inputs/af3_tleap.pdb`
- Target name: `af3_tleap`
- Design samples: 2
- Length range: 100-150 residues

### Custom Configuration

You can override defaults using environment variables:

```bash
# Custom input file
INPUT_PDB="path/to/your/protein.pdb" ./run_binder_gpu.sh

# More design samples
DESIGN_SAMPLES=5 ./run_binder_gpu.sh

# Different length range
LENGTH_MIN=80 LENGTH_MAX=120 ./run_binder_gpu.sh

# All custom settings
INPUT_PDB="my_protein.pdb" \
TARGET_NAME="my_target" \
DESIGN_SAMPLES=3 \
LENGTH_MIN=90 \
LENGTH_MAX=140 \
./run_binder_gpu.sh
```

### Expected Runtime on A100

- **With A100 GPU**: 30-90 minutes total
  - Boltz design optimization: 15-45 minutes
  - Structure prediction: 10-30 minutes
  - Sequence refinement: 5-15 minutes

- **Speedup vs CPU**: 4-8x faster than CPU execution

## Monitoring Progress

### Real-time Monitoring

Make the monitoring script executable and run it:

```bash
chmod +x monitor_gpu.sh

# Single snapshot
./monitor_gpu.sh

# Continuous monitoring (updates every 30 seconds)
./monitor_gpu.sh --continuous

# Custom update interval (60 seconds)
./monitor_gpu.sh --continuous --interval 60
```

### Manual Checks

```bash
# Check GPU usage
nvidia-smi

# Watch GPU usage continuously (updates every 2 seconds)
watch -n 2 nvidia-smi

# Check Python processes
ps aux | grep python | grep boltzdesign

# Check output directory
ls -lh BoltzDesign1/outputs/

# View recent log
tail -f logs/binder_gen_*.log
```

## Output Files

Results are saved in `BoltzDesign1/outputs/protein_<target_name>_<N>/`:

```
protein_af3_tleap_0/
├── 01_init/                  # Initial processing
├── 02_af_pdb/                # Boltz predictions
├── 03_af_pdb_success/        # ✓ Final successful binder designs (PDB)
│   ├── af3_tleap_<sample>_<rank>.pdb
│   └── confidence scores
├── 04_seq/                   # LigandMPNN sequences
├── animation/                # Design trajectory
├── loss/                     # Training metrics
└── results_final/            # Final configurations
```

**Main output files:**
- `03_af_pdb_success/*.pdb` - Final binder structures
- `high_iptm_confidence_scores.csv` - Confidence metrics (if generated)

## Troubleshooting

### CUDA Out of Memory

If you get CUDA OOM errors:

```bash
# Use smaller batch size by editing BoltzDesign1/boltzdesign/configs/default_ppi_config.yaml
# Or use less design samples
DESIGN_SAMPLES=1 ./run_binder_gpu.sh
```

### GPU Not Detected

```bash
# Check driver
nvidia-smi

# Check PyTorch CUDA
source boltz_venv/bin/activate
python3 -c "import torch; print(f'CUDA available: {torch.cuda.is_available()}')"

# If CUDA not available, reinstall PyTorch
pip install torch==2.5.1 --index-url https://download.pytorch.org/whl/cu121
```

### ProDy Import Errors

The setup script applies a BioPython patch to avoid ProDy C++ compilation. If you still get ProDy errors:

```bash
# Check if patch was applied
grep -n "prody_biopython_patch" BoltzDesign1/LigandMPNN/data_utils.py

# Manually apply if needed
cd BoltzDesign1/LigandMPNN
# Edit data_utils.py, run.py, etc. to use prody_biopython_patch
```

### Permission Issues

```bash
# Make all scripts executable
chmod +x *.sh

# If you get permission errors with virtual environment
rm -rf boltz_venv
python3 -m venv boltz_venv
source boltz_venv/bin/activate
```

## Performance Optimization

### For A100 80GB

```bash
# Enable tensor cores and memory optimization
export PYTORCH_CUDA_ALLOC_CONF=max_split_size_mb:512
export CUDA_LAUNCH_BLOCKING=0

# Run with larger batch sizes if desired
# Edit BoltzDesign1/boltzdesign/configs/default_ppi_config.yaml
```

### For Multiple GPUs

To use a specific GPU:

```bash
# Use GPU 1 instead of GPU 0
CUDA_VISIBLE_DEVICES=1 ./run_binder_gpu.sh

# Use multiple GPUs (if code supports it)
CUDA_VISIBLE_DEVICES=0,1 ./run_binder_gpu.sh
```

## Comparing Results with Windows Run

The Linux GPU run should produce:
- Same quality binders (confidence scores)
- 4-8x faster execution time
- Same output format

To compare:
1. Copy the Windows output to Linux: `scp -r windows_machine:path/to/outputs .`
2. Compare PDB structures using PyMOL or similar
3. Compare confidence scores in CSV files

## Advanced Configuration

### Custom Design Parameters

Edit `BoltzDesign1/boltzdesign/configs/default_ppi_config.yaml`:

```yaml
# Key parameters to adjust:
learning_rate: 0.1        # Optimization speed
soft_iteration: 80        # Number of soft optimization steps
hard_iteration: 5         # Number of hard optimization steps
inter_chain_cutoff: 20.0  # Interface definition distance
```

### Running in Background

```bash
# Run in background with nohup
nohup ./run_binder_gpu.sh > output.log 2>&1 &

# Check progress
tail -f output.log

# Or use screen/tmux
screen -S binder_gen
./run_binder_gpu.sh
# Ctrl+A, D to detach
# screen -r binder_gen to reattach
```

## File Transfer Between Windows and Linux

```bash
# From Windows to Linux
scp af3_tleap.pdb user@linux-machine:~/projects/d3-boltz/_inputs/

# From Linux to Windows
scp -r user@linux-machine:~/projects/d3-boltz/BoltzDesign1/outputs/ ./results/
```

## Next Steps

After successful binder generation:
1. Analyze results in `03_af_pdb_success/`
2. Check confidence scores
3. Visualize in PyMOL or ChimeraX
4. Run molecular dynamics simulations
5. Validate experimentally

## Resources

- Boltz: https://github.com/jwohlwend/boltz
- BoltzDesign1: https://github.com/yehlincho/BoltzDesign1
- PyTorch CUDA: https://pytorch.org/get-started/locally/
- NVIDIA CUDA: https://developer.nvidia.com/cuda-toolkit

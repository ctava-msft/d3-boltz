# Quick Start Guide - Linux Ubuntu with A100 GPU

Get BoltzDesign1 running on your Linux Ubuntu box with A100 GPU in minutes.

## Prerequisites Check

```bash
# 1. Check NVIDIA driver
nvidia-smi
# Should show driver version >= 525.x and your A100 GPU

# 2. Check CUDA
nvcc --version
# Should show CUDA 12.x

# 3. Check Python
python3 --version
# Should be 3.9-3.12
```

If any of these fail, see [Prerequisites](#detailed-prerequisites) below.

## Installation (10-20 minutes)

```bash
# 1. Create project directory
mkdir -p ~/projects/d3-boltz
cd ~/projects/d3-boltz

# 2. Copy files from Windows machine
# - linux_setup.sh
# - run_binder_gpu.sh
# - monitor_gpu.sh
# - Your input PDB file

# 3. Create _inputs directory and add your PDB
mkdir -p _inputs
cp /path/to/af3_tleap.pdb _inputs/

# 4. Make scripts executable
chmod +x linux_setup.sh run_binder_gpu.sh monitor_gpu.sh

# 5. Run setup (downloads ~3GB)
./linux_setup.sh
```

## Run Binder Generation (30-90 minutes on A100)

```bash
# Basic run with defaults
./run_binder_gpu.sh

# Custom configuration
DESIGN_SAMPLES=3 LENGTH_MIN=80 LENGTH_MAX=120 ./run_binder_gpu.sh
```

## Monitor Progress

Open a second terminal:

```bash
cd ~/projects/d3-boltz

# Continuous monitoring (updates every 30s)
./monitor_gpu.sh --continuous

# Or watch GPU directly
watch -n 2 nvidia-smi
```

## Check Results

```bash
# List output files
ls -lh BoltzDesign1/outputs/protein_af3_tleap_0/03_af_pdb_success/

# View summary
cat logs/status_*.txt
```

## Expected Timeline

| Phase | Time (A100) | What's Happening |
|-------|-------------|------------------|
| Setup | 10-20 min | Download models, install packages |
| Initialization | 1-2 min | Load models, parse input |
| Boltz Design | 15-45 min | AI optimization of binder |
| Structure Prediction | 10-30 min | Generate 3D structures |
| Sequence Refinement | 5-15 min | LigandMPNN optimization |
| **Total** | **30-90 min** | Complete binder generation |

Compare to Windows CPU: 4-8 hours!

## Troubleshooting

### GPU Not Detected
```bash
nvidia-smi  # Check if driver works
python3 -c "import torch; print(torch.cuda.is_available())"  # Should print True
```

### Out of Memory
```bash
# Reduce samples
DESIGN_SAMPLES=1 ./run_binder_gpu.sh

# Or use smaller protein
```

### Permission Errors
```bash
chmod +x *.sh
sudo chown -R $USER:$USER ~/projects/d3-boltz
```

## File Transfer from Windows

```bash
# Copy your PDB file
scp user@windows-machine:C:/Users/.../af3_tleap.pdb ./_inputs/

# Copy results back to Windows
scp -r BoltzDesign1/outputs/ user@windows-machine:C:/Users/.../results/
```

## Detailed Prerequisites

### Install NVIDIA Drivers

```bash
# Ubuntu 20.04/22.04
sudo apt update
sudo apt install nvidia-driver-535
sudo reboot

# Verify
nvidia-smi
```

### Install CUDA Toolkit

```bash
# Download CUDA 12.1
wget https://developer.download.nvidia.com/compute/cuda/12.1.0/local_installers/cuda_12.1.0_530.30.02_linux.run

# Install
sudo sh cuda_12.1.0_530.30.02_linux.run

# Add to ~/.bashrc
echo 'export CUDA_HOME=/usr/local/cuda' >> ~/.bashrc
echo 'export PATH=$CUDA_HOME/bin:$PATH' >> ~/.bashrc
echo 'export LD_LIBRARY_PATH=$CUDA_HOME/lib64:$LD_LIBRARY_PATH' >> ~/.bashrc
source ~/.bashrc
```

### Install Python 3.10 (if needed)

```bash
# Ubuntu 22.04 has Python 3.10 by default
python3 --version

# If you need to install Python 3.10
sudo apt install python3.10 python3.10-venv python3-pip
```

## Quick Reference

```bash
# Activate environment
source boltz_venv/bin/activate

# Run with custom settings
INPUT_PDB="my_protein.pdb" DESIGN_SAMPLES=5 ./run_binder_gpu.sh

# Monitor continuously
./monitor_gpu.sh -c -i 60  # Update every 60 seconds

# Check GPU usage
nvidia-smi

# View logs
tail -f logs/binder_gen_*.log

# Check outputs
ls -lh BoltzDesign1/outputs/*/03_af_pdb_success/*.pdb
```

## Success Indicators

✅ Setup complete: "Setup Complete!" message  
✅ GPU detected: nvidia-smi shows A100  
✅ CUDA available: PyTorch detects CUDA  
✅ Running: GPU utilization > 80%  
✅ Complete: PDB files in 03_af_pdb_success/  

## Next Steps

1. ✅ Run with your protein → Get results in 30-90 min
2. 📊 Analyze confidence scores
3. 🔬 Visualize in PyMOL/ChimeraX  
4. 🧪 Plan experimental validation

**Need help?** Check `README_LINUX.md` for detailed documentation.

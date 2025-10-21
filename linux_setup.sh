#!/bin/bash
# Setup script for BoltzDesign1 on Linux Ubuntu with A100 GPU
# This script sets up the environment and installs all dependencies

set -e  # Exit on error

echo "========================================="
echo "BoltzDesign1 Linux Setup with GPU Support"
echo "========================================="
echo ""

# Check if CUDA is available
if ! command -v nvidia-smi &> /dev/null; then
    echo "ERROR: nvidia-smi not found. Please install NVIDIA drivers first."
    exit 1
fi

echo "Detected GPU:"
nvidia-smi --query-gpu=name,driver_version,memory.total --format=csv,noheader
echo ""

# Set CUDA environment variables
export CUDA_HOME=/usr/local/cuda
export PATH=$CUDA_HOME/bin:$PATH
export LD_LIBRARY_PATH=$CUDA_HOME/lib64:$LD_LIBRARY_PATH

# Check Python version
PYTHON_VERSION=$(python3 --version 2>&1 | awk '{print $2}')
echo "Python version: $PYTHON_VERSION"
if [[ ! "$PYTHON_VERSION" =~ ^3\.(9|10|11|12) ]]; then
    echo "WARNING: Python 3.9-3.12 recommended. Current version: $PYTHON_VERSION"
fi
echo ""

# Create virtual environment
echo "Creating virtual environment..."
python3 -m venv boltz_venv
source boltz_venv/bin/activate

# Upgrade pip
echo "Upgrading pip..."
pip install --upgrade pip

# Install PyTorch with CUDA 12.1 support (for A100)
echo "Installing PyTorch with CUDA support..."
pip install torch==2.5.1 torchvision torchaudio --index-url https://download.pytorch.org/whl/cu121

# Install pytorch-lightning
echo "Installing pytorch-lightning..."
pip install pytorch-lightning

# Clone and install Boltz
echo "Cloning Boltz repository..."
if [ ! -d "boltz1" ]; then
    git clone https://github.com/jwohlwend/boltz.git boltz1
fi

echo "Installing Boltz..."
cd boltz1
pip install -e .
cd ..

# Install other dependencies
echo "Installing additional dependencies..."
pip install numpy pandas scipy matplotlib seaborn tqdm pyyaml requests biopython rdkit pypdb py3Dmol ipython

# Clone BoltzDesign1 repository
echo "Cloning BoltzDesign1 repository..."
if [ ! -d "BoltzDesign1" ]; then
    git clone https://github.com/yehlincho/BoltzDesign1.git
fi

# Apply BioPython ProDy patch
echo "Applying BioPython patch for ProDy replacement..."
cat > BoltzDesign1/LigandMPNN/prody_biopython_patch.py << 'EOFPATCH'
"""
BioPython-based replacement for ProDy functionality.
This avoids the need for C++ compiler to install ProDy.
"""
from Bio.PDB import PDBParser, PDBIO, Structure, Model, Chain, Residue, Atom
import numpy as np

def confProDy(**kwargs):
    """Dummy function to replace ProDy's confProDy"""
    pass

def parsePDB(filename):
    """Parse PDB file using BioPython"""
    parser = PDBParser(QUIET=True)
    structure = parser.get_structure('structure', filename)
    return structure

class AtomGroup:
    """Mimic ProDy's AtomGroup using BioPython"""
    def __init__(self):
        self._coords = None
        self._betas = None
        self._names = None
        self._resnames = None
        self._elements = None
        self._occupancies = None
        self._resnums = None
        self._chids = None
        self._icodes = None
        self._flags = None
        self._structure = Structure.Structure('structure')
        self._model = Model.Model(0)
        self._structure.add(self._model)
    
    def setCoords(self, coords):
        self._coords = np.array(coords)
    
    def getCoords(self):
        return self._coords
    
    def setBetas(self, betas):
        self._betas = np.array(betas)
    
    def getBetas(self):
        return self._betas
    
    def setNames(self, names):
        self._names = names
    
    def getNames(self):
        return self._names
    
    def setResnames(self, resnames):
        self._resnames = resnames
    
    def getResnames(self):
        return self._resnames
    
    def setElements(self, elements):
        self._elements = elements
    
    def getElements(self):
        return self._elements
    
    def setOccupancies(self, occupancies):
        self._occupancies = np.array(occupancies)
    
    def getOccupancies(self):
        return self._occupancies
    
    def setResnums(self, resnums):
        self._resnums = np.array(resnums)
    
    def getResnums(self):
        return self._resnums
    
    def setChids(self, chids):
        self._chids = chids
    
    def getChids(self):
        return self._chids
    
    def setIcodes(self, icodes):
        self._icodes = icodes
    
    def getIcodes(self):
        return self._icodes
    
    def setFlags(self, flags_key, flags_value):
        if self._flags is None:
            self._flags = {}
        self._flags[flags_key] = flags_value
    
    def getFlags(self, flags_key):
        if self._flags is None:
            return None
        return self._flags.get(flags_key)
    
    def __add__(self, other):
        """Combine two AtomGroups"""
        combined = AtomGroup()
        if self._coords is not None and other._coords is not None:
            combined._coords = np.concatenate([self._coords, other._coords])
        if self._betas is not None and other._betas is not None:
            combined._betas = np.concatenate([self._betas, other._betas])
        return combined

def writePDB(filename, structure):
    """Write PDB file using BioPython"""
    structure = _prody_to_biopython(structure)
    io = PDBIO()
    io.set_structure(structure)
    io.save(filename)

def _prody_to_biopython(prody_obj):
    """Convert ProDy-like object to BioPython Structure"""
    if isinstance(prody_obj, AtomGroup):
        structure = Structure.Structure('structure')
        model = Model.Model(0)
        structure.add(model)
        
        coords = prody_obj.getCoords()
        names = prody_obj.getNames() if prody_obj.getNames() is not None else ['CA'] * len(coords)
        resnames = prody_obj.getResnames() if prody_obj.getResnames() is not None else ['ALA'] * len(coords)
        resnums = prody_obj.getResnums() if prody_obj.getResnums() is not None else list(range(1, len(coords) + 1))
        chids = prody_obj.getChids() if prody_obj.getChids() is not None else ['A'] * len(coords)
        elements = prody_obj.getElements() if prody_obj.getElements() is not None else ['C'] * len(coords)
        betas = prody_obj.getBetas() if prody_obj.getBetas() is not None else [0.0] * len(coords)
        occupancies = prody_obj.getOccupancies() if prody_obj.getOccupancies() is not None else [1.0] * len(coords)
        
        current_chain = None
        current_residue = None
        current_chain_id = None
        current_resnum = None
        
        for i in range(len(coords)):
            chain_id = chids[i]
            resnum = int(resnums[i])
            
            if chain_id != current_chain_id:
                current_chain = Chain.Chain(chain_id)
                model.add(current_chain)
                current_chain_id = chain_id
                current_resnum = None
            
            if resnum != current_resnum:
                current_residue = Residue.Residue((' ', resnum, ' '), resnames[i], '')
                current_chain.add(current_residue)
                current_resnum = resnum
            
            atom = Atom.Atom(names[i], coords[i], betas[i], occupancies[i], ' ', names[i], i, element=elements[i])
            current_residue.add(atom)
        
        return structure
    
    return prody_obj
EOFPATCH

# Patch the boltzdesign.py file for auto-detecting single chain and boltz path
echo "Patching boltzdesign.py..."
cd BoltzDesign1

# Create backup
cp boltzdesign.py boltzdesign.py.backup

# Apply patches using sed
# Patch 1: Auto-detect single chain with space ID
sed -i '/pdb_target_ids = \[str(x.strip()) for x in args.pdb_target_ids.split/a\        # Auto-detect single chain case\n        if pdb_target_ids is None and args.input_type == "pdb":\n            try:\n                from boltzdesign.input_utils import get_chains_sequence\n                chain_sequences = get_chains_sequence(pdb_path)\n                if len(chain_sequences) == 1:\n                    pdb_target_ids = list(chain_sequences.keys())\n                    print(f"Auto-detected single chain: {pdb_target_ids}")\n            except Exception as e:\n                print(f"Could not auto-detect chain: {e}")\n                pass' boltzdesign.py

# Patch 2: Fix boltz path detection
sed -i 's/boltz_path = shutil.which("boltz")/boltz_path = shutil.which("boltz")\n    if boltz_path is None:\n        # Try to find boltz in the virtual environment\n        venv_boltz = os.path.join(os.path.dirname(sys.executable), "boltz")\n        if os.path.exists(venv_boltz):\n            boltz_path = venv_boltz/' boltzdesign.py

cd ..

# Download Boltz model weights
echo "Downloading Boltz model weights..."
python3 << EOFPYTHON
from boltz.main import download_model_weights
download_model_weights()
EOFPYTHON

echo ""
echo "========================================="
echo "Setup Complete!"
echo "========================================="
echo ""
echo "To activate the environment, run:"
echo "  source boltz_venv/bin/activate"
echo ""
echo "To run binder generation, use:"
echo "  ./run_binder_gpu.sh"
echo ""
echo "GPU Information:"
nvidia-smi --query-gpu=name,memory.total,memory.free --format=csv
echo ""

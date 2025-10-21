#!/bin/bash
# Troubleshooting and manual setup for BoltzDesign1
# Run this if linux_setup.sh fails

set -e

echo "=== BoltzDesign1 Manual Setup ==="
echo ""

# Check if we're in the right directory
if [ ! -f "linux_setup.sh" ]; then
    echo "ERROR: Please run this from the d3-boltz directory"
    exit 1
fi

# Activate virtual environment
if [ ! -d "boltz_venv" ]; then
    echo "ERROR: Virtual environment not found. Run linux_setup.sh first to create it."
    exit 1
fi

source boltz_venv/bin/activate
echo "✓ Virtual environment activated"

# Check if Boltz is installed
if ! python3 -c "import boltz" 2>/dev/null; then
    echo "Boltz not found. Installing Boltz..."
    
    # Check for GPU
    if command -v nvidia-smi &> /dev/null; then
        echo "GPU detected. Installing PyTorch with CUDA 12.1..."
        pip install torch torchvision torchaudio --index-url https://download.pytorch.org/whl/cu121
    else
        echo "No GPU detected. Installing PyTorch for CPU..."
        pip install torch torchvision torchaudio
    fi
    
    # Install other dependencies
    echo "Installing dependencies..."
    pip install pytorch-lightning biopython rdkit numpy pandas scipy matplotlib seaborn \
                tqdm pyyaml requests pypdb py3Dmol ipython
    
    # Clone and install Boltz
    if [ ! -d "boltz-main" ]; then
        echo "Downloading Boltz..."
        wget -q https://github.com/jwohlwend/boltz/archive/refs/heads/main.zip
        unzip -q main.zip
        rm main.zip
        echo "✓ Boltz downloaded"
    fi
    
    echo "Installing Boltz..."
    cd boltz-main
    pip install -e .
    cd ..
    echo "✓ Boltz installed"
    
    # Download model weights
    echo "Downloading Boltz model weights (~2GB)..."
    mkdir -p ~/.boltz
    wget -q -O ~/.boltz/boltz1.ckpt https://storage.googleapis.com/boltz-public/boltz1.ckpt
    echo "✓ Model weights downloaded"
else
    echo "✓ Boltz is installed"
fi

# Clone BoltzDesign1 if not present
if [ ! -d "BoltzDesign1" ]; then
    echo "Cloning BoltzDesign1 repository..."
    git clone https://github.com/yehlincho/BoltzDesign1.git
    echo "✓ BoltzDesign1 cloned"
else
    echo "✓ BoltzDesign1 directory exists"
fi

# Check if boltzdesign.py exists
if [ ! -f "BoltzDesign1/boltzdesign.py" ]; then
    echo "ERROR: boltzdesign.py not found in BoltzDesign1 directory"
    echo "The repository may be incomplete. Try removing and re-cloning:"
    echo "  rm -rf BoltzDesign1"
    echo "  git clone https://github.com/yehlincho/BoltzDesign1.git"
    exit 1
fi
echo "✓ boltzdesign.py found"

# Create BioPython ProDy patch
echo "Creating BioPython ProDy patch..."
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
echo "✓ BioPython patch created"

# Patch all files that use ProDy
echo "Patching ProDy imports..."
cd BoltzDesign1

# Patch ligandmpnn_utils.py
if [ -f "LigandMPNN/ligandmpnn_utils.py" ]; then
    if ! grep -q "prody_biopython_patch" LigandMPNN/ligandmpnn_utils.py; then
        cp LigandMPNN/ligandmpnn_utils.py LigandMPNN/ligandmpnn_utils.py.backup
        sed -i 's/from prody import/from prody_biopython_patch import/g' LigandMPNN/ligandmpnn_utils.py
        sed -i 's/import prody/import prody_biopython_patch as prody/g' LigandMPNN/ligandmpnn_utils.py
        echo "✓ Patched ligandmpnn_utils.py"
    fi
fi

# Patch run.py
if [ -f "LigandMPNN/run.py" ]; then
    if ! grep -q "prody_biopython_patch" LigandMPNN/run.py; then
        cp LigandMPNN/run.py LigandMPNN/run.py.backup
        sed -i 's/from prody import/from prody_biopython_patch import/g' LigandMPNN/run.py
        sed -i 's/import prody/import prody_biopython_patch as prody/g' LigandMPNN/run.py
        echo "✓ Patched run.py"
    fi
fi

# Patch data_utils.py
if [ -f "boltzdesign/data_utils.py" ]; then
    if ! grep -q "prody_biopython_patch" boltzdesign/data_utils.py; then
        cp boltzdesign/data_utils.py boltzdesign/data_utils.py.backup
        sed -i 's/from prody import/from prody_biopython_patch import/g' boltzdesign/data_utils.py
        sed -i 's/import prody/import prody_biopython_patch as prody/g' boltzdesign/data_utils.py
        echo "✓ Patched data_utils.py"
    fi
fi

# Patch input_utils.py
if [ -f "boltzdesign/input_utils.py" ]; then
    if ! grep -q "prody_biopython_patch" boltzdesign/input_utils.py; then
        cp boltzdesign/input_utils.py boltzdesign/input_utils.py.backup
        sed -i 's/from prody import/from prody_biopython_patch import/g' boltzdesign/input_utils.py
        sed -i 's/import prody/import prody_biopython_patch as prody/g' boltzdesign/input_utils.py
        echo "✓ Patched input_utils.py"
    fi
fi

cd ..

# Now patch boltzdesign.py
echo "Patching boltzdesign.py..."
cd BoltzDesign1

# Create backup
if [ ! -f "boltzdesign.py.backup" ]; then
    cp boltzdesign.py boltzdesign.py.backup
    echo "✓ Backup created"
fi

# Check if patches are already applied
if grep -q "Auto-detect single chain case" boltzdesign.py; then
    echo "✓ Patches already applied"
else
    echo "Applying patches..."
    
    # Patch 1: Auto-detect single chain
    python3 << 'EOFPYTHON'
import sys

with open('boltzdesign.py', 'r') as f:
    content = f.read()

# Find the line to patch after
search_str = "pdb_target_ids = [str(x.strip()) for x in args.pdb_target_ids.split(\",\")] if args.pdb_target_ids else None"

if search_str in content:
    patch = """
        # Auto-detect single chain case
        if pdb_target_ids is None and args.input_type == "pdb":
            try:
                from boltzdesign.input_utils import get_chains_sequence
                chain_sequences = get_chains_sequence(pdb_path)
                if len(chain_sequences) == 1:
                    pdb_target_ids = list(chain_sequences.keys())
                    print(f"Auto-detected single chain: {pdb_target_ids}")
            except Exception as e:
                print(f"Could not auto-detect chain: {e}")
                pass"""
    
    content = content.replace(search_str, search_str + patch)
    
    # Patch 2: Fix boltz path - find the existing error handling
    # We need to add code BEFORE the existing error, not replace it
    search_str2 = 'if boltz_path is None:\n            raise FileNotFoundError'
    if search_str2 in content:
        patch2 = '''if boltz_path is None:
            # Try to find boltz in the virtual environment
            import sys
            venv_boltz = os.path.join(os.path.dirname(sys.executable), "boltz")
            if os.path.exists(venv_boltz):
                boltz_path = venv_boltz
        if boltz_path is None:
            raise FileNotFoundError'''
        content = content.replace(search_str2, patch2)
    
    with open('boltzdesign.py', 'w') as f:
        f.write(content)
    
    print("✓ Patches applied")
else:
    print("WARNING: Could not find patch location in boltzdesign.py")
    print("File may have been updated. Please check manually.")
EOFPYTHON
fi

cd ..

echo ""
echo "=== Setup Complete ==="
echo ""
echo "You can now run:"
echo "  ./run_binder_gpu.sh"
echo ""

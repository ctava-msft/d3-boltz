#!/bin/bash
# Patch all ProDy imports to use BioPython replacement

cd /home/azureuser/localfiles/d3-boltz/BoltzDesign1

echo "=== Patching ProDy imports ==="
echo ""

# Check if prody_biopython_patch.py exists
if [ ! -f "LigandMPNN/prody_biopython_patch.py" ]; then
    echo "ERROR: prody_biopython_patch.py not found"
    echo "Creating it now..."
    
    cat > LigandMPNN/prody_biopython_patch.py << 'EOFPATCH'
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
    
    echo "✓ Created prody_biopython_patch.py"
fi

echo "Patching files..."
echo ""

# Patch ligandmpnn_utils.py in boltzdesign directory
if [ -f "boltzdesign/ligandmpnn_utils.py" ]; then
    if grep -q "from prody import" boltzdesign/ligandmpnn_utils.py; then
        cp boltzdesign/ligandmpnn_utils.py boltzdesign/ligandmpnn_utils.py.backup
        sed -i 's/from prody import/from LigandMPNN.prody_biopython_patch import/g' boltzdesign/ligandmpnn_utils.py
        sed -i 's/import prody/import LigandMPNN.prody_biopython_patch as prody/g' boltzdesign/ligandmpnn_utils.py
        echo "✓ Patched boltzdesign/ligandmpnn_utils.py"
    else
        echo "✓ boltzdesign/ligandmpnn_utils.py already patched"
    fi
fi

# Patch ligandmpnn_utils.py in LigandMPNN directory
if [ -f "LigandMPNN/ligandmpnn_utils.py" ]; then
    if grep -q "from prody import" LigandMPNN/ligandmpnn_utils.py; then
        cp LigandMPNN/ligandmpnn_utils.py LigandMPNN/ligandmpnn_utils.py.backup
        sed -i 's/from prody import/from prody_biopython_patch import/g' LigandMPNN/ligandmpnn_utils.py
        sed -i 's/import prody/import prody_biopython_patch as prody/g' LigandMPNN/ligandmpnn_utils.py
        echo "✓ Patched LigandMPNN/ligandmpnn_utils.py"
    else
        echo "✓ LigandMPNN/ligandmpnn_utils.py already patched"
    fi
fi

# Patch run.py
if [ -f "LigandMPNN/run.py" ]; then
    if grep -q "from prody import" LigandMPNN/run.py; then
        cp LigandMPNN/run.py LigandMPNN/run.py.backup
        sed -i 's/from prody import/from prody_biopython_patch import/g' LigandMPNN/run.py
        sed -i 's/import prody/import prody_biopython_patch as prody/g' LigandMPNN/run.py
        echo "✓ Patched LigandMPNN/run.py"
    else
        echo "✓ LigandMPNN/run.py already patched"
    fi
fi

# Patch data_utils.py
if [ -f "boltzdesign/data_utils.py" ]; then
    if grep -q "from prody import" boltzdesign/data_utils.py; then
        cp boltzdesign/data_utils.py boltzdesign/data_utils.py.backup
        sed -i 's/from prody import/from LigandMPNN.prody_biopython_patch import/g' boltzdesign/data_utils.py
        sed -i 's/import prody/import LigandMPNN.prody_biopython_patch as prody/g' boltzdesign/data_utils.py
        echo "✓ Patched boltzdesign/data_utils.py"
    else
        echo "✓ boltzdesign/data_utils.py already patched"
    fi
fi

# Patch input_utils.py
if [ -f "boltzdesign/input_utils.py" ]; then
    if grep -q "from prody import" boltzdesign/input_utils.py; then
        cp boltzdesign/input_utils.py boltzdesign/input_utils.py.backup
        sed -i 's/from prody import/from LigandMPNN.prody_biopython_patch import/g' boltzdesign/input_utils.py
        sed -i 's/import prody/import LigandMPNN.prody_biopython_patch as prody/g' boltzdesign/input_utils.py
        echo "✓ Patched boltzdesign/input_utils.py"
    else
        echo "✓ boltzdesign/input_utils.py already patched"
    fi
fi

echo ""
echo "=== All ProDy imports patched ==="
echo ""
echo "You can now run: cd /home/azureuser/localfiles/d3-boltz && ./run_binder_gpu.sh"

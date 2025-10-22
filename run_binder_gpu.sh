#!/bin/bash
# Run binder generation on Linux with GPU support

set -e

# Configuration
INPUT_PDB="${INPUT_PDB:-_inputs/af3_tleap.pdb}"
TARGET_NAME="${TARGET_NAME:-af3_tleap}"
DESIGN_SAMPLES="${DESIGN_SAMPLES:-2}"
LENGTH_MIN="${LENGTH_MIN:-100}"
LENGTH_MAX="${LENGTH_MAX:-150}"
TARGET_TYPE="${TARGET_TYPE:-protein}"
PDB_TARGET_IDS="${PDB_TARGET_IDS:-A}"  # Default to chain A, override with PDB_TARGET_IDS=B or pass --pdb_target_ids

# Activate virtual environment
if [ ! -d "boltz_venv" ]; then
    echo "ERROR: Virtual environment not found. Run ./linux_setup.sh first."
    exit 1
fi

source boltz_venv/bin/activate

# Set CUDA environment
export CUDA_VISIBLE_DEVICES=0  # Use first GPU, change if needed
export PYTORCH_CUDA_ALLOC_CONF=max_split_size_mb:512

# Check GPU availability
echo "========================================="
echo "GPU Status:"
echo "========================================="
if python3 -c "import torch; print(f'CUDA available: {torch.cuda.is_available()}'); print(f'GPU count: {torch.cuda.device_count()}'); print(f'GPU name: {torch.cuda.get_device_name(0) if torch.cuda.is_available() else \"N/A\"}')"; then
    echo ""
else
    echo "WARNING: GPU check failed!"
fi

# Check input file
if [ ! -f "$INPUT_PDB" ]; then
    echo "ERROR: Input PDB file not found: $INPUT_PDB"
    echo "Please set INPUT_PDB environment variable or place file at _inputs/af3_tleap.pdb"
    exit 1
fi

echo "========================================="
echo "Binder Generation Configuration"
echo "========================================="
echo "Input PDB: $INPUT_PDB"
echo "Target name: $TARGET_NAME"
echo "Design samples: $DESIGN_SAMPLES"
echo "Length range: $LENGTH_MIN - $LENGTH_MAX residues"
echo "Target type: $TARGET_TYPE"
echo "Target chain IDs: $PDB_TARGET_IDS"
echo ""

# Create log directory
LOG_DIR="logs"
mkdir -p "$LOG_DIR"

TIMESTAMP=$(date +"%Y%m%d_%H%M%S")
LOG_FILE="$LOG_DIR/binder_gen_${TIMESTAMP}.log"
STATUS_FILE="$LOG_DIR/status_${TIMESTAMP}.txt"

echo "Started at: $(date)" | tee "$STATUS_FILE"
echo "Log file: $LOG_FILE"
echo ""

# Change to BoltzDesign1 directory
cd BoltzDesign1

# Run binder generation
echo "Starting binder generation..."
echo "This will take 30-90 minutes on GPU (A100)..."
echo ""

python3 boltzdesign.py \
    --target_name "$TARGET_NAME" \
    --input_type pdb \
    --pdb_path "../$INPUT_PDB" \
    --target_type "$TARGET_TYPE" \
    --pdb_target_ids "$PDB_TARGET_IDS" \
    --design_samples "$DESIGN_SAMPLES" \
    --length_min "$LENGTH_MIN" \
    --length_max "$LENGTH_MAX" \
    2>&1 | tee "../$LOG_FILE"

EXIT_CODE=${PIPESTATUS[0]}

cd ..

# Record completion
echo "" | tee -a "$STATUS_FILE"
echo "Completed at: $(date)" | tee -a "$STATUS_FILE"
echo "Exit code: $EXIT_CODE" | tee -a "$STATUS_FILE"

if [ $EXIT_CODE -eq 0 ]; then
    echo "" | tee -a "$STATUS_FILE"
    echo "=========================================" | tee -a "$STATUS_FILE"
    echo "SUCCESS! Binder generation completed." | tee -a "$STATUS_FILE"
    echo "=========================================" | tee -a "$STATUS_FILE"
    echo "" | tee -a "$STATUS_FILE"
    echo "Results location:" | tee -a "$STATUS_FILE"
    ls -lh BoltzDesign1/outputs/protein_${TARGET_NAME}_*/03_af_pdb_success/*.pdb 2>/dev/null | tee -a "$STATUS_FILE" || echo "No PDB files found yet (may still be processing)" | tee -a "$STATUS_FILE"
else
    echo "" | tee -a "$STATUS_FILE"
    echo "=========================================" | tee -a "$STATUS_FILE"
    echo "ERROR: Binder generation failed." | tee -a "$STATUS_FILE"
    echo "=========================================" | tee -a "$STATUS_FILE"
    echo "Check log file: $LOG_FILE" | tee -a "$STATUS_FILE"
fi

exit $EXIT_CODE

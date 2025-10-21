#!/bin/bash
# Run binder generation in the background with nohup

set -e

# Configuration (can be overridden with environment variables)
INPUT_PDB="${INPUT_PDB:-_inputs/af3_tleap.pdb}"
TARGET_NAME="${TARGET_NAME:-af3_tleap}"
DESIGN_SAMPLES="${DESIGN_SAMPLES:-2}"
LENGTH_MIN="${LENGTH_MIN:-100}"
LENGTH_MAX="${LENGTH_MAX:-150}"
TARGET_TYPE="${TARGET_TYPE:-protein}"

# Create log directory
LOG_DIR="logs"
mkdir -p "$LOG_DIR"

TIMESTAMP=$(date +"%Y%m%d_%H%M%S")
LOG_FILE="$LOG_DIR/binder_gen_${TIMESTAMP}.log"
NOHUP_FILE="$LOG_DIR/nohup_${TIMESTAMP}.out"
PID_FILE="$LOG_DIR/pid_${TIMESTAMP}.txt"

echo "========================================="
echo "Background Binder Generation"
echo "========================================="
echo "Input PDB: $INPUT_PDB"
echo "Target name: $TARGET_NAME"
echo "Design samples: $DESIGN_SAMPLES"
echo "Length range: $LENGTH_MIN - $LENGTH_MAX residues"
echo "Target type: $TARGET_TYPE"
echo ""
echo "Log file: $LOG_FILE"
echo "Nohup output: $NOHUP_FILE"
echo "PID file: $PID_FILE"
echo ""

# Check if virtual environment exists
if [ ! -d "boltz_venv" ]; then
    echo "ERROR: Virtual environment not found. Run ./linux_setup.sh first."
    exit 1
fi

# Check input file
if [ ! -f "$INPUT_PDB" ]; then
    echo "ERROR: Input PDB file not found: $INPUT_PDB"
    exit 1
fi

# Create a wrapper script that will be run by nohup
WRAPPER_SCRIPT="$LOG_DIR/wrapper_${TIMESTAMP}.sh"
cat > "$WRAPPER_SCRIPT" << 'EOFWRAPPER'
#!/bin/bash

# Activate virtual environment
source boltz_venv/bin/activate

# Set CUDA environment
export CUDA_VISIBLE_DEVICES=0
export PYTORCH_CUDA_ALLOC_CONF=max_split_size_mb:512

# Change to BoltzDesign1 directory
cd BoltzDesign1

# Run binder generation
python3 boltzdesign.py \
    --target_name "__TARGET_NAME__" \
    --input_type pdb \
    --pdb_path "../__INPUT_PDB__" \
    --target_type "__TARGET_TYPE__" \
    --design_samples __DESIGN_SAMPLES__ \
    --length_min __LENGTH_MIN__ \
    --length_max __LENGTH_MAX__

EOFWRAPPER

# Replace placeholders in wrapper script
sed -i "s|__TARGET_NAME__|$TARGET_NAME|g" "$WRAPPER_SCRIPT"
sed -i "s|__INPUT_PDB__|$INPUT_PDB|g" "$WRAPPER_SCRIPT"
sed -i "s|__TARGET_TYPE__|$TARGET_TYPE|g" "$WRAPPER_SCRIPT"
sed -i "s|__DESIGN_SAMPLES__|$DESIGN_SAMPLES|g" "$WRAPPER_SCRIPT"
sed -i "s|__LENGTH_MIN__|$LENGTH_MIN|g" "$WRAPPER_SCRIPT"
sed -i "s|__LENGTH_MAX__|$LENGTH_MAX|g" "$WRAPPER_SCRIPT"

# Make wrapper executable
chmod +x "$WRAPPER_SCRIPT"

# Run with nohup
echo "Starting background process..."
nohup bash "$WRAPPER_SCRIPT" > "$LOG_FILE" 2>&1 &
BG_PID=$!

# Save PID
echo "$BG_PID" > "$PID_FILE"

echo ""
echo "========================================="
echo "Process started in background!"
echo "========================================="
echo "Process ID: $BG_PID"
echo ""
echo "To monitor progress:"
echo "  tail -f $LOG_FILE"
echo ""
echo "To check if still running:"
echo "  ps -p $BG_PID"
echo ""
echo "To check GPU usage:"
echo "  watch -n 5 nvidia-smi"
echo ""
echo "To kill the process:"
echo "  kill $BG_PID"
echo "  # or"
echo "  kill \$(cat $PID_FILE)"
echo ""

# Wait a moment to ensure process started
sleep 2

# Check if process is still running
if ps -p $BG_PID > /dev/null 2>&1; then
    echo "✓ Process is running successfully"
    echo ""
    echo "Started at: $(date)"
    echo "Expected completion: 30-90 minutes"
else
    echo "✗ ERROR: Process failed to start"
    echo "Check log file: $LOG_FILE"
    exit 1
fi

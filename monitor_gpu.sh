#!/bin/bash
# Monitor GPU usage and binder generation progress

# Function to display GPU stats
show_gpu_stats() {
    echo "========================================="
    echo "GPU Status - $(date)"
    echo "========================================="
    nvidia-smi --query-gpu=index,name,temperature.gpu,utilization.gpu,utilization.memory,memory.used,memory.total --format=csv,noheader,nounits | \
    awk -F', ' '{printf "GPU %s: %s\n  Temp: %s°C | GPU Util: %s%% | Mem Util: %s%% | Memory: %s/%s MB\n", $1, $2, $3, $4, $5, $6, $7}'
    echo ""
}

# Function to check Python processes
show_python_processes() {
    echo "Python Processes:"
    ps aux | grep "[p]ython.*boltzdesign" | awk '{printf "  PID: %s | CPU: %s%% | MEM: %s%% | Time: %s\n", $2, $3, $4, $10}'
    echo ""
}

# Function to check output directory
show_output_status() {
    if [ -d "BoltzDesign1/outputs" ]; then
        echo "Output Directory Status:"
        LATEST_OUTPUT=$(ls -td BoltzDesign1/outputs/protein_*/ 2>/dev/null | head -1)
        if [ -n "$LATEST_OUTPUT" ]; then
            echo "  Latest run: $LATEST_OUTPUT"
            echo "  Files created: $(find "$LATEST_OUTPUT" -type f | wc -l)"
            echo "  Size: $(du -sh "$LATEST_OUTPUT" 2>/dev/null | cut -f1)"
            
            # Check for PDB files
            PDB_COUNT=$(find "$LATEST_OUTPUT" -name "*.pdb" 2>/dev/null | wc -l)
            if [ $PDB_COUNT -gt 0 ]; then
                echo "  ✓ PDB files found: $PDB_COUNT"
            fi
            
            # Check for CIF files
            CIF_COUNT=$(find "$LATEST_OUTPUT" -name "*.cif" 2>/dev/null | wc -l)
            if [ $CIF_COUNT -gt 0 ]; then
                echo "  ✓ CIF files found: $CIF_COUNT"
            fi
        else
            echo "  No output directories found yet"
        fi
    else
        echo "Output directory not created yet"
    fi
    echo ""
}

# Function to show recent log entries
show_recent_logs() {
    if [ -d "logs" ]; then
        LATEST_LOG=$(ls -t logs/binder_gen_*.log 2>/dev/null | head -1)
        if [ -n "$LATEST_LOG" ]; then
            echo "Recent Log Entries (last 10 lines):"
            tail -10 "$LATEST_LOG" | sed 's/^/  /'
        fi
    fi
    echo ""
}

# Parse command line arguments
INTERVAL=30
CONTINUOUS=false

while [[ $# -gt 0 ]]; do
    case $1 in
        -c|--continuous)
            CONTINUOUS=true
            shift
            ;;
        -i|--interval)
            INTERVAL="$2"
            shift 2
            ;;
        -h|--help)
            echo "Usage: $0 [-c|--continuous] [-i|--interval SECONDS]"
            echo ""
            echo "Options:"
            echo "  -c, --continuous    Run continuously (Ctrl+C to stop)"
            echo "  -i, --interval SEC  Update interval in seconds (default: 30)"
            echo "  -h, --help          Show this help message"
            exit 0
            ;;
        *)
            echo "Unknown option: $1"
            echo "Use -h or --help for usage information"
            exit 1
            ;;
    esac
done

# Main monitoring loop
if [ "$CONTINUOUS" = true ]; then
    echo "Starting continuous monitoring (interval: ${INTERVAL}s)"
    echo "Press Ctrl+C to stop"
    echo ""
    
    while true; do
        clear
        show_gpu_stats
        show_python_processes
        show_output_status
        show_recent_logs
        
        echo "Next update in ${INTERVAL}s... (Ctrl+C to stop)"
        sleep "$INTERVAL"
    done
else
    # Single run
    show_gpu_stats
    show_python_processes
    show_output_status
    show_recent_logs
fi

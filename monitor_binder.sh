#!/bin/bash
# Monitor background binder generation processes

LOG_DIR="logs"

echo "========================================="
echo "Background Process Monitor"
echo "========================================="
echo ""

# Find all PID files
PID_FILES=$(ls -t $LOG_DIR/pid_*.txt 2>/dev/null)

if [ -z "$PID_FILES" ]; then
    echo "No background processes found."
    echo ""
    echo "Start a background process with:"
    echo "  ./run_binder_background.sh"
    exit 0
fi

echo "Active and recent processes:"
echo ""

for PID_FILE in $PID_FILES; do
    PID=$(cat "$PID_FILE" 2>/dev/null)
    TIMESTAMP=$(basename "$PID_FILE" | sed 's/pid_//;s/.txt//')
    LOG_FILE="$LOG_DIR/binder_gen_${TIMESTAMP}.log"
    
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo "Process: $PID (started: $TIMESTAMP)"
    
    if ps -p $PID > /dev/null 2>&1; then
        echo "Status: ✓ RUNNING"
        
        # Show process details
        echo ""
        ps -p $PID -o pid,user,%cpu,%mem,etime,cmd --no-headers
        
        # Show last few lines of log
        if [ -f "$LOG_FILE" ]; then
            echo ""
            echo "Recent log output:"
            echo "---"
            tail -n 5 "$LOG_FILE"
            echo "---"
        fi
        
        echo ""
        echo "Monitor this process:"
        echo "  tail -f $LOG_FILE"
        echo ""
        echo "Kill this process:"
        echo "  kill $PID"
    else
        echo "Status: ✗ COMPLETED or STOPPED"
        
        if [ -f "$LOG_FILE" ]; then
            # Check for success/failure in log
            if grep -q "SUCCESS" "$LOG_FILE" 2>/dev/null; then
                echo "Result: ✓ SUCCESS"
            elif grep -q "ERROR\|Traceback" "$LOG_FILE" 2>/dev/null; then
                echo "Result: ✗ FAILED"
                echo ""
                echo "Last error lines:"
                echo "---"
                tail -n 10 "$LOG_FILE" | grep -A 5 -B 5 "ERROR\|Traceback" | tail -n 10
                echo "---"
            else
                echo "Result: Unknown (check log file)"
            fi
        fi
        
        echo ""
        echo "View log:"
        echo "  cat $LOG_FILE"
    fi
    
    echo ""
done

echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

# Show GPU status if processes are running
RUNNING_COUNT=$(ps -p $(cat $LOG_DIR/pid_*.txt 2>/dev/null | tr '\n' ',' | sed 's/,$//') 2>/dev/null | wc -l)
if [ $RUNNING_COUNT -gt 1 ]; then
    echo "Current GPU Status:"
    echo "---"
    nvidia-smi --query-gpu=index,name,utilization.gpu,memory.used,memory.total --format=csv,noheader 2>/dev/null || echo "GPU info not available"
    echo "---"
    echo ""
fi

echo "Commands:"
echo "  Monitor all:     watch -n 5 ./monitor_binder.sh"
echo "  GPU status:      watch -n 5 nvidia-smi"
echo "  Kill all:        pkill -f boltzdesign.py"

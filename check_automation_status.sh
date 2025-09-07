#!/bin/bash

# 🗼 Project Watchtower - Automation Status Checker
# Quick way to check the current status of the infinite automation

PROJECT_DIR="/Users/salescode/Desktop/Recycle_Bin/fwb"
cd "$PROJECT_DIR"

echo "🗼 PROJECT WATCHTOWER - AUTOMATION STATUS"
echo "========================================"
echo "⏰ Current Time: $(date)"
echo ""

# Check if automation is running
AUTOMATION_PID=$(pgrep -f "infinite_automation.sh" | head -1)
if [[ -n "$AUTOMATION_PID" ]]; then
    echo "🟢 Automation Status: RUNNING (PID: $AUTOMATION_PID)"
else
    echo "🔴 Automation Status: NOT RUNNING"
fi

echo ""

# Check latest logs
if [[ -d "automation/logs" ]]; then
    LATEST_LOG=$(ls -t automation/logs/*.log 2>/dev/null | head -1)
    if [[ -n "$LATEST_LOG" ]]; then
        echo "📝 Latest Log: $LATEST_LOG"
        echo "📊 Last 10 Log Entries:"
        echo "----------------------------------------"
        tail -10 "$LATEST_LOG" 2>/dev/null || echo "No recent log entries"
        echo "----------------------------------------"
    else
        echo "📝 No log files found"
    fi
else
    echo "📁 Automation logs directory not found"
fi

echo ""

# Check iteration reports
if [[ -d "automation/reports" ]]; then
    REPORT_COUNT=$(ls automation/reports/*.md 2>/dev/null | wc -l)
    echo "📄 Total Reports Generated: $REPORT_COUNT"
    
    LATEST_REPORT=$(ls -t automation/reports/iteration_*.md 2>/dev/null | head -1)
    if [[ -n "$LATEST_REPORT" ]]; then
        echo "📊 Latest Iteration Report: $(basename "$LATEST_REPORT")"
        
        # Extract health score from latest report
        if [[ -f "$LATEST_REPORT" ]]; then
            HEALTH_SCORE=$(grep "Health Score:" "$LATEST_REPORT" | head -1)
            if [[ -n "$HEALTH_SCORE" ]]; then
                echo "💊 $HEALTH_SCORE"
            fi
        fi
    fi
else
    echo "📁 Reports directory not found"
fi

echo ""

# Check for completion status
if [[ -f "automation/PERFECT_APP_REPORT.md" ]]; then
    echo "🏆 STATUS: PERFECTION ACHIEVED!"
    echo "✅ Your Project Watchtower app is perfect!"
    echo "📄 Check automation/PERFECT_APP_REPORT.md for details"
elif [[ -f "WAKE_UP_STATUS.txt" ]]; then
    echo "🌅 WAKE UP STATUS AVAILABLE!"
    echo "📄 Check WAKE_UP_STATUS.txt"
elif [[ -f "automation/MAX_ITERATIONS_REPORT.md" ]]; then
    echo "⚠️ Maximum iterations reached"
    echo "📄 Check automation/MAX_ITERATIONS_REPORT.md for details"
else
    echo "🔄 STATUS: AUTOMATION IN PROGRESS"
    echo "⏳ Working towards perfection..."
fi

echo ""

# Network status
if ping -c 1 8.8.8.8 >/dev/null 2>&1; then
    echo "🌐 Network: CONNECTED"
else
    echo "🌐 Network: DISCONNECTED (Will auto-recover)"
fi

echo ""

# Quick app status
if [[ -f "pubspec.yaml" ]]; then
    APP_NAME=$(grep "^name:" pubspec.yaml | cut -d' ' -f2)
    echo "📱 App: $APP_NAME (Project Watchtower)"
else
    echo "📱 App: Status unknown"
fi

# Build status
echo "🔨 Checking quick build status..."
if flutter doctor --version >/dev/null 2>&1; then
    echo "🔧 Flutter: Available"
    if [[ -f "pubspec.lock" ]]; then
        echo "📚 Dependencies: Resolved"
    else
        echo "📚 Dependencies: May need resolution"
    fi
else
    echo "🔧 Flutter: Not available or issues"
fi

echo ""
echo "========================================"
echo "💡 Tips:"
echo "   - Run this script anytime to check status"
echo "   - Logs are in automation/logs/"
echo "   - Reports are in automation/reports/"
echo "   - Final status will be in WAKE_UP_STATUS.txt"
echo ""
echo "😴 Sweet dreams! Automation is working hard!"
echo "========================================"





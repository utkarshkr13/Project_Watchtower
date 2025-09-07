#!/bin/bash

# Dashboard Status Check for Project Watch Tower
echo "🌐 Project Watch Tower Web Dashboard Status"
echo "=============================================="

# Check if dashboard is running
if pgrep -f "web_dashboard.py" > /dev/null; then
    echo "✅ Dashboard Status: RUNNING"
    echo "🌐 URL: http://localhost:5001"
    echo "📊 Real-time analytics: ACTIVE"
    echo "🎯 Interactive controls: ENABLED"
    echo ""
    echo "💡 Features Available:"
    echo "   ✅ Real-time issue tracking"
    echo "   ✅ Page-specific analysis (5 pages)"
    echo "   ✅ Performance metrics"
    echo "   ✅ Interactive controls"
    echo "   ✅ Live activity feed"
    echo "   ✅ Beautiful charts and graphs"
    echo ""
    echo "🛑 To stop: pkill -f web_dashboard.py"
    echo "🔄 To restart: ./start_web_dashboard.sh"
else
    echo "❌ Dashboard Status: NOT RUNNING"
    echo "🚀 To start: ./start_web_dashboard.sh"
fi

echo ""
echo "📱 Auto-commit system status:"
if pgrep -f "auto_commit_system.py" > /dev/null; then
    echo "✅ Auto-commit: RUNNING (5-minute intervals)"
else
    echo "❌ Auto-commit: NOT RUNNING"
fi

echo ""
echo "🤖 AI Testing system status:"
if pgrep -f "smart_ai_fixer.py" > /dev/null; then
    echo "✅ AI Testing: RUNNING"
else
    echo "❌ AI Testing: NOT RUNNING"
fi

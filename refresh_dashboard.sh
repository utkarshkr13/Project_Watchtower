#!/bin/bash

# Refresh Dashboard Script - Bypass Browser Cache
echo "🔄 Refreshing Project Watch Tower Dashboard..."
echo "🌐 Opening with cache-busting parameters..."

# Kill any existing dashboard
pkill -f web_dashboard.py 2>/dev/null

# Wait a moment
sleep 2

# Start dashboard in background
python3 web_dashboard.py &
DASHBOARD_PID=$!

# Wait for dashboard to start
sleep 3

# Generate timestamp for cache busting
TIMESTAMP=$(date +%s)

echo "✅ Dashboard restarted with PID: $DASHBOARD_PID"
echo "🌐 Opening fresh dashboard..."
echo "📱 URL: http://localhost:5001?v=$TIMESTAMP"

# Open with cache busting
open "http://localhost:5001?v=$TIMESTAMP"

echo ""
echo "💡 If you still see the old design:"
echo "   1. Press Cmd+Shift+R (hard refresh)"
echo "   2. Or press Cmd+Option+R (clear cache and reload)"
echo "   3. Or open Developer Tools (F12) and right-click refresh → Empty Cache and Hard Reload"
echo ""
echo "🎨 You should now see the beautiful Apple-inspired design!"

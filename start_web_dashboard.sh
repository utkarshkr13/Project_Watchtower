#!/bin/bash

# Start Web Dashboard for Project Watch Tower AI Testing
# Beautiful, interactive real-time analytics dashboard

echo "🌐 Starting Project Watch Tower Web Dashboard..."
echo "📊 Real-time AI Testing Analytics"
echo "🎯 Interactive monitoring and control"
echo ""

# Check if Flask is installed
python3 -c "import flask" 2>/dev/null || {
    echo "📦 Installing Flask and dependencies..."
    pip3 install -r web_requirements.txt
}

# Check if we're in the right directory
if [ ! -f "web_dashboard.py" ]; then
    echo "❌ Error: web_dashboard.py not found. Please run this script from the project root directory."
    exit 1
fi

echo "🚀 Starting web dashboard server..."
echo "🌐 Dashboard will be available at: http://localhost:5001"
echo "📱 Real-time updates enabled"
echo "🎨 Beautiful interactive interface"
echo ""
echo "💡 Features:"
echo "   ✅ Real-time issue tracking"
echo "   ✅ Page-specific analysis"
echo "   ✅ Performance metrics"
echo "   ✅ Interactive controls"
echo "   ✅ Live activity feed"
echo "   ✅ Beautiful charts and graphs"
echo ""
echo "🛑 Press Ctrl+C to stop the dashboard"
echo ""

# Start the web dashboard
python3 web_dashboard.py

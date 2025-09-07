#!/bin/bash

# Start Auto-Commit System for Project Watch Tower
# This script starts the automatic Git commit system that runs every 5 minutes

echo "🚀 Starting Auto-Commit System for Project Watch Tower..."
echo "📁 Repository: /Users/salescode/Desktop/Recycle_Bin/project_watch_tower"
echo "🌐 GitHub: https://github.com/utkarshkr13/Project_Watchtower.git"
echo "⏰ Commit interval: 5 minutes"
echo "🔄 Running in background..."

# Check if auto-commit is already running
if [ -f "auto_commit.pid" ]; then
    PID=$(cat auto_commit.pid)
    if ps -p $PID > /dev/null 2>&1; then
        echo "⚠️ Auto-commit system is already running with PID: $PID"
        echo "🛑 To stop current system: kill $PID"
        echo "🛑 To restart: kill $PID && ./start_auto_commit.sh"
        exit 1
    else
        echo "🧹 Cleaning up old PID file..."
        rm auto_commit.pid
    fi
fi

# Install required Python package if not present
python3 -c "import git" 2>/dev/null || {
    echo "📦 Installing GitPython..."
    pip3 install GitPython
}

# Check if we're in the right directory
if [ ! -f "pubspec.yaml" ]; then
    echo "❌ Error: pubspec.yaml not found. Please run this script from the project root directory."
    exit 1
fi

# Initialize git repository if needed
if [ ! -d ".git" ]; then
    echo "🔧 Initializing git repository..."
    git init
    git remote add origin https://github.com/utkarshkr13/Project_Watchtower.git
    git config user.name "Project Watch Tower AI"
    git config user.email "ai@projectwatchtower.com"
fi

# Start the auto-commit system in background
nohup python3 auto_commit_system.py > auto_commit.log 2>&1 &

# Get the process ID
PID=$!
echo "✅ Auto-commit system started with PID: $PID"
echo "📝 Log file: auto_commit.log"
echo "🛑 To stop: kill $PID"
echo ""

# Save PID to file for easy management
echo $PID > auto_commit.pid

echo "💡 The system will now automatically commit changes every 5 minutes"
echo "💡 Check auto_commit.log for detailed output"
echo "💡 Your laptop must be running for commits to happen"
echo "💡 All AI testing files, logs, and improvements will be automatically committed"
echo ""
echo "📊 To check status: ps -p $PID"
echo "📄 To view logs: tail -f auto_commit.log"
echo "🛑 To stop: kill $PID"

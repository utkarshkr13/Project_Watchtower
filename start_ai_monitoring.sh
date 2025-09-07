#!/bin/bash

echo "🤖 Starting AI Monitoring for Project Watch Tower"
echo "=================================================="

# Check if simulator is running
echo "🔍 Checking iOS Simulator status..."
if ! xcrun simctl list devices | grep -q "Booted"; then
    echo "❌ No iOS simulator is running!"
    echo "🚀 Starting iOS Simulator..."
    open -a Simulator
    echo "⏳ Waiting for simulator to start..."
    sleep 10
fi

# Check if app is installed
echo "📱 Checking if app is installed..."
if ! xcrun simctl list apps booted | grep -q "com.fwb.app.fwb"; then
    echo "🔨 Building and installing app..."
    flutter clean
    flutter build ios --simulator --debug
    xcrun simctl install booted build/ios/iphonesimulator/Runner.app
fi

# Launch the app
echo "🚀 Launching Project Watch Tower app..."
xcrun simctl launch booted com.fwb.app.fwb

# Wait a moment for app to load
echo "⏳ Waiting for app to load..."
sleep 3

# Start AI monitoring
echo "🤖 Starting AI monitoring..."
echo "👆 Now tap on the app to see AI analysis in real-time!"
echo "Press Ctrl+C to stop monitoring"
echo ""

python3 terminal_ai_monitor.py

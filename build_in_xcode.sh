#!/bin/bash

echo "🚀 Building Project Watch Tower in Xcode"
echo "========================================"

# Check if we're in the right directory
if [ ! -f "ios/Runner.xcworkspace/contents.xcworkspacedata" ]; then
    echo "❌ Error: Not in the Flutter project directory"
    echo "Please run this script from the project root directory"
    exit 1
fi

echo "📱 Opening Xcode workspace..."
echo "1. Xcode will open with your project"
echo "2. Select iPhone 16 Pro simulator"
echo "3. Click the Play button to build and run"
echo "4. Wait for the app to launch in the simulator"
echo "5. Then you can use the web dashboard to take screenshots"

# Open Xcode workspace
open ios/Runner.xcworkspace

echo ""
echo "✅ Xcode opened successfully!"
echo ""
echo "📋 Next steps:"
echo "   1. In Xcode, select iPhone 16 Pro simulator"
echo "   2. Click the Play button (▶️) to build and run"
echo "   3. Wait for the app to launch"
echo "   4. Open web dashboard: http://localhost:5001"
echo "   5. Click '📸 Take Manual Screenshot' button"
echo ""
echo "🎯 The screenshot system will capture REAL images from your running app!"

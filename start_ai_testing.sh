#!/bin/bash

# FWB AI Test Automation Startup Script
# =====================================
# This script starts the complete AI-driven testing system
# including device setup, test execution, and reporting

set -e  # Exit on any error

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Configuration
PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TEST_CASES_DIR="$PROJECT_ROOT/test_cases"
AUTOMATION_DIR="$TEST_CASES_DIR/automation"
AI_ENGINE_DIR="$AUTOMATION_DIR/ai_engine"
DEVICE_MANAGER_DIR="$AUTOMATION_DIR/device_testing"
REPORTS_DIR="$TEST_CASES_DIR/reports"

# Default values
FLUTTER_BUILD=true
SETUP_DEVICES=true
RUN_TESTS=true
GENERATE_REPORTS=true
CLEANUP_DEVICES=true
TEST_CATEGORY="all"
TEST_LIMIT=100
PARALLEL_EXECUTION=true
DASHBOARD_PORT=8080
LOG_LEVEL="INFO"

# Function to print colored output
print_status() {
    echo -e "${BLUE}[$(date +'%H:%M:%S')] $1${NC}"
}

print_success() {
    echo -e "${GREEN}[$(date +'%H:%M:%S')] ✅ $1${NC}"
}

print_error() {
    echo -e "${RED}[$(date +'%H:%M:%S')] ❌ $1${NC}"
}

print_warning() {
    echo -e "${YELLOW}[$(date +'%H:%M:%S')] ⚠️  $1${NC}"
}

print_header() {
    echo -e "${PURPLE}"
    echo "🤖 =================================="
    echo "   FWB AI Test Automation System"
    echo "   Powered by Computer Vision & ML"
    echo "===================================${NC}"
    echo
}

# Function to show usage
show_usage() {
    echo "Usage: $0 [OPTIONS]"
    echo
    echo "Options:"
    echo "  --no-build              Skip Flutter build"
    echo "  --no-devices            Skip device setup"
    echo "  --no-tests              Skip test execution"
    echo "  --no-reports            Skip report generation"
    echo "  --no-cleanup            Skip device cleanup"
    echo "  --category <category>   Test category (all, auth, home, watch_party, theme)"
    echo "  --limit <number>        Number of tests to run (default: 100)"
    echo "  --sequential            Run tests sequentially instead of parallel"
    echo "  --dashboard             Start web dashboard only"
    echo "  --port <port>           Dashboard port (default: 8080)"
    echo "  --log-level <level>     Log level (DEBUG, INFO, WARNING, ERROR)"
    echo "  --help                  Show this help message"
    echo
    echo "Examples:"
    echo "  $0                                    # Run full test suite"
    echo "  $0 --category auth --limit 50        # Run 50 authentication tests"
    echo "  $0 --dashboard --port 9000           # Start dashboard on port 9000"
    echo "  $0 --no-build --no-devices           # Skip build and device setup"
}

# Parse command line arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        --no-build)
            FLUTTER_BUILD=false
            shift
            ;;
        --no-devices)
            SETUP_DEVICES=false
            shift
            ;;
        --no-tests)
            RUN_TESTS=false
            shift
            ;;
        --no-reports)
            GENERATE_REPORTS=false
            shift
            ;;
        --no-cleanup)
            CLEANUP_DEVICES=false
            shift
            ;;
        --category)
            TEST_CATEGORY="$2"
            shift 2
            ;;
        --limit)
            TEST_LIMIT="$2"
            shift 2
            ;;
        --sequential)
            PARALLEL_EXECUTION=false
            shift
            ;;
        --dashboard)
            SETUP_DEVICES=false
            RUN_TESTS=false
            FLUTTER_BUILD=false
            shift
            ;;
        --port)
            DASHBOARD_PORT="$2"
            shift 2
            ;;
        --log-level)
            LOG_LEVEL="$2"
            shift 2
            ;;
        --help)
            show_usage
            exit 0
            ;;
        *)
            print_error "Unknown option: $1"
            show_usage
            exit 1
            ;;
    esac
done

# Function to check prerequisites
check_prerequisites() {
    print_status "Checking prerequisites..."
    
    local missing_tools=()
    
    # Check Flutter
    if ! command -v flutter &> /dev/null; then
        missing_tools+=("flutter")
    fi
    
    # Check Python
    if ! command -v python3 &> /dev/null; then
        missing_tools+=("python3")
    fi
    
    # Check Node.js (for Appium)
    if ! command -v node &> /dev/null; then
        missing_tools+=("node")
    fi
    
    # Check Xcode (on macOS)
    if [[ "$OSTYPE" == "darwin"* ]] && ! command -v xcodebuild &> /dev/null; then
        print_warning "Xcode not found - iOS testing will be disabled"
    fi
    
    # Check Android SDK
    if [[ -z "$ANDROID_SDK_ROOT" && -z "$ANDROID_HOME" ]]; then
        print_warning "Android SDK not found - Android testing may be limited"
    fi
    
    if [[ ${#missing_tools[@]} -gt 0 ]]; then
        print_error "Missing required tools: ${missing_tools[*]}"
        echo
        echo "Please install the missing tools:"
        for tool in "${missing_tools[@]}"; do
            case $tool in
                flutter)
                    echo "  Flutter: https://flutter.dev/docs/get-started/install"
                    ;;
                python3)
                    echo "  Python 3: https://www.python.org/downloads/"
                    ;;
                node)
                    echo "  Node.js: https://nodejs.org/"
                    ;;
            esac
        done
        exit 1
    fi
    
    print_success "All prerequisites met"
}

# Function to setup Python environment
setup_python_env() {
    print_status "Setting up Python environment..."
    
    cd "$AUTOMATION_DIR"
    
    # Create virtual environment if it doesn't exist
    if [[ ! -d "venv" ]]; then
        print_status "Creating Python virtual environment..."
        python3 -m venv venv
    fi
    
    # Activate virtual environment
    source venv/bin/activate
    
    # Install dependencies
    if [[ -f "requirements.txt" ]]; then
        print_status "Installing Python dependencies..."
        pip install -r requirements.txt
    else
        print_warning "requirements.txt not found, installing basic dependencies..."
        pip install opencv-python pillow torch torchvision transformers tensorflow
        pip install Appium-Python-Client selenium flask flask-socketio
        pip install jinja2 requests psutil
    fi
    
    print_success "Python environment ready"
}

# Function to setup Node.js environment
setup_node_env() {
    print_status "Setting up Node.js environment..."
    
    # Install Appium globally if not present
    if ! command -v appium &> /dev/null; then
        print_status "Installing Appium..."
        npm install -g appium @appium/doctor
    fi
    
    # Install required drivers
    print_status "Installing Appium drivers..."
    appium driver install uiautomator2 || true
    appium driver install xcuitest || true
    
    print_success "Node.js environment ready"
}

# Function to build Flutter app
build_flutter_app() {
    if [[ "$FLUTTER_BUILD" == "false" ]]; then
        print_status "Skipping Flutter build"
        return
    fi
    
    print_status "Building Flutter app..."
    
    cd "$PROJECT_ROOT"
    
    # Get dependencies
    flutter pub get
    
    # Run code generation if needed
    if [[ -f "pubspec.yaml" ]] && grep -q "build_runner" pubspec.yaml; then
        print_status "Running code generation..."
        flutter packages pub run build_runner build --delete-conflicting-outputs
    fi
    
    # Build for iOS (if on macOS)
    if [[ "$OSTYPE" == "darwin"* ]]; then
        print_status "Building iOS app..."
        flutter build ios --simulator --debug
        
        if [[ $? -eq 0 ]]; then
            print_success "iOS build completed"
        else
            print_error "iOS build failed"
            exit 1
        fi
    fi
    
    # Build for Android
    print_status "Building Android app..."
    flutter build apk --debug
    
    if [[ $? -eq 0 ]]; then
        print_success "Android build completed"
    else
        print_error "Android build failed"
        exit 1
    fi
    
    print_success "Flutter build completed"
}

# Function to start Appium server
start_appium_server() {
    print_status "Starting Appium server..."
    
    # Check if Appium is already running
    if lsof -ti:4723 &> /dev/null; then
        print_warning "Appium server already running on port 4723"
        return
    fi
    
    # Start Appium server in background
    appium --log-level error > appium.log 2>&1 &
    APPIUM_PID=$!
    
    # Wait for server to start
    local timeout=30
    local count=0
    while [[ $count -lt $timeout ]]; do
        if curl -s http://localhost:4723/wd/hub/status &> /dev/null; then
            print_success "Appium server started (PID: $APPIUM_PID)"
            return
        fi
        sleep 1
        ((count++))
    done
    
    print_error "Failed to start Appium server"
    exit 1
}

# Function to setup devices
setup_devices() {
    if [[ "$SETUP_DEVICES" == "false" ]]; then
        print_status "Skipping device setup"
        return
    fi
    
    print_status "Setting up test devices..."
    
    cd "$DEVICE_MANAGER_DIR"
    source "$AUTOMATION_DIR/venv/bin/activate"
    
    # Setup devices using device manager
    python device_manager.py --setup \
        --install-ios "$PROJECT_ROOT/build/ios/iphonesimulator/Runner.app" \
        --install-android "$PROJECT_ROOT/build/app/outputs/flutter-apk/app-debug.apk"
    
    if [[ $? -eq 0 ]]; then
        print_success "Device setup completed"
    else
        print_error "Device setup failed"
        exit 1
    fi
}

# Function to run AI tests
run_ai_tests() {
    if [[ "$RUN_TESTS" == "false" ]]; then
        print_status "Skipping test execution"
        return
    fi
    
    print_status "Running AI-powered tests..."
    print_status "Category: $TEST_CATEGORY, Limit: $TEST_LIMIT, Parallel: $PARALLEL_EXECUTION"
    
    cd "$AI_ENGINE_DIR"
    source "$AUTOMATION_DIR/venv/bin/activate"
    
    # Create reports directory
    mkdir -p "$REPORTS_DIR"
    
    # Run the AI test engine
    local cmd="python AI_TEST_AUTOMATION_ENGINE.py"
    cmd="$cmd --category $TEST_CATEGORY"
    cmd="$cmd --limit $TEST_LIMIT"
    
    if [[ "$PARALLEL_EXECUTION" == "false" ]]; then
        cmd="$cmd --sequential"
    fi
    
    print_status "Executing: $cmd"
    
    eval $cmd
    
    if [[ $? -eq 0 ]]; then
        print_success "AI test execution completed"
        
        # Move reports to reports directory
        if [[ -f "test_report.html" ]]; then
            mv test_report.html "$REPORTS_DIR/"
        fi
        if [[ -f "test_results.json" ]]; then
            mv test_results.json "$REPORTS_DIR/"
        fi
        if [[ -d "screenshots" ]]; then
            mv screenshots "$REPORTS_DIR/"
        fi
        
    else
        print_error "AI test execution failed"
        exit 1
    fi
}

# Function to start dashboard
start_dashboard() {
    print_status "Starting AI Test Dashboard on port $DASHBOARD_PORT..."
    
    cd "$AI_ENGINE_DIR"
    source "$AUTOMATION_DIR/venv/bin/activate"
    
    python AI_TEST_AUTOMATION_ENGINE.py --dashboard --port "$DASHBOARD_PORT"
}

# Function to generate reports
generate_reports() {
    if [[ "$GENERATE_REPORTS" == "false" ]]; then
        print_status "Skipping report generation"
        return
    fi
    
    print_status "Generating comprehensive reports..."
    
    cd "$REPORTS_DIR"
    
    # Create comprehensive report
    cat << EOF > comprehensive_report.md
# FWB AI Test Automation Report

**Generated:** $(date)
**Test Category:** $TEST_CATEGORY
**Test Limit:** $TEST_LIMIT
**Parallel Execution:** $PARALLEL_EXECUTION

## Summary

This report contains the results of AI-powered automated testing for the FWB application.

## Test Results

- **HTML Report:** [test_report.html](test_report.html)
- **JSON Results:** [test_results.json](test_results.json)
- **Screenshots:** [screenshots/](screenshots/)

## Device Information

- **iOS Simulators:** iPhone 15 Pro, iPhone 16 Pro, iPad Pro
- **Android Emulators:** Pixel 8 Pro, Galaxy S24

## AI Features Used

- ✅ Computer Vision Element Detection
- ✅ Behavioral Learning
- ✅ Adaptive Test Generation
- ✅ Self-Healing Tests
- ✅ Real-time Performance Monitoring

## Next Steps

1. Review failed tests in detail
2. Update test cases based on AI insights
3. Implement suggested improvements
4. Schedule next automated run

---
*Generated by FWB AI Test Automation System*
EOF
    
    print_success "Reports generated in $REPORTS_DIR"
    
    # Open report in browser if on macOS
    if [[ "$OSTYPE" == "darwin"* ]] && [[ -f "test_report.html" ]]; then
        open "test_report.html"
    fi
}

# Function to cleanup devices
cleanup_devices() {
    if [[ "$CLEANUP_DEVICES" == "false" ]]; then
        print_status "Skipping device cleanup"
        return
    fi
    
    print_status "Cleaning up test devices..."
    
    cd "$DEVICE_MANAGER_DIR"
    source "$AUTOMATION_DIR/venv/bin/activate" 2>/dev/null || true
    
    python device_manager.py --cleanup
    
    print_success "Device cleanup completed"
}

# Function to stop Appium server
stop_appium_server() {
    if [[ -n "$APPIUM_PID" ]]; then
        print_status "Stopping Appium server..."
        kill "$APPIUM_PID" 2>/dev/null || true
        print_success "Appium server stopped"
    fi
}

# Function to cleanup on exit
cleanup_on_exit() {
    print_status "Performing cleanup..."
    cleanup_devices
    stop_appium_server
    print_success "Cleanup completed"
}

# Trap exit signals
trap cleanup_on_exit EXIT INT TERM

# Main execution flow
main() {
    print_header
    
    # Check if just running dashboard
    if [[ "$RUN_TESTS" == "false" && "$SETUP_DEVICES" == "false" && "$FLUTTER_BUILD" == "false" ]]; then
        setup_python_env
        start_dashboard
        return
    fi
    
    # Full test execution flow
    check_prerequisites
    setup_python_env
    setup_node_env
    start_appium_server
    build_flutter_app
    setup_devices
    run_ai_tests
    generate_reports
    
    print_success "🎉 AI Test Automation completed successfully!"
    
    # Show summary
    echo
    echo -e "${CYAN}📊 Test Summary:${NC}"
    if [[ -f "$REPORTS_DIR/test_results.json" ]]; then
        python3 -c "
import json
try:
    with open('$REPORTS_DIR/test_results.json', 'r') as f:
        data = json.load(f)
        summary = data.get('summary', {})
        print(f'  Total Tests: {summary.get(\"total\", 0)}')
        print(f'  Passed: {summary.get(\"passed\", 0)} ✅')
        print(f'  Failed: {summary.get(\"failed\", 0)} ❌')
        print(f'  Skipped: {summary.get(\"skipped\", 0)} ⏭️')
        print(f'  Pass Rate: {summary.get(\"pass_rate\", 0)}%')
        print(f'  Execution Time: {summary.get(\"execution_time\", 0):.2f}s')
except:
    print('  No test results available')
"
    fi
    
    echo
    echo -e "${CYAN}📁 Generated Files:${NC}"
    echo "  Reports: $REPORTS_DIR"
    echo "  Logs: $AUTOMATION_DIR/test_automation.log"
    echo "  Screenshots: $REPORTS_DIR/screenshots/"
    
    echo
    echo -e "${GREEN}🚀 Next Steps:${NC}"
    echo "  1. Review the HTML report for detailed results"
    echo "  2. Check failed tests and screenshots"
    echo "  3. Update test cases based on AI insights"
    echo "  4. Integrate with CI/CD pipeline"
}

# Run main function
main "$@"

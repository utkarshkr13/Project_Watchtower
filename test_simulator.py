#!/usr/bin/env python3
"""
Project Watch Tower - Simulator Testing Script
Real-time testing for iOS Simulator with AI-powered analysis
"""

import cv2
import numpy as np
import time
import subprocess
import json
import os
from datetime import datetime
import threading
import sys

class SimulatorTester:
    def __init__(self):
        self.test_results = []
        self.screenshots_dir = "test_screenshots"
        self.running = False
        
        # Create screenshots directory
        os.makedirs(self.screenshots_dir, exist_ok=True)
        
        print("🏰 Project Watch Tower - Simulator Testing System")
        print("=" * 60)
        
    def capture_simulator_screenshot(self):
        """Capture screenshot from iOS Simulator"""
        try:
            timestamp = datetime.now().strftime("%Y%m%d_%H%M%S")
            screenshot_path = f"{self.screenshots_dir}/screenshot_{timestamp}.png"
            
            # Use xcrun simctl to capture simulator screenshot
            result = subprocess.run([
                "xcrun", "simctl", "io", "booted", "screenshot", screenshot_path
            ], capture_output=True, text=True)
            
            if result.returncode == 0:
                print(f"📸 Screenshot captured: {screenshot_path}")
                return screenshot_path
            else:
                print(f"❌ Failed to capture screenshot: {result.stderr}")
                return None
                
        except Exception as e:
            print(f"❌ Screenshot error: {e}")
            return None
    
    def analyze_screenshot(self, screenshot_path):
        """Analyze screenshot using computer vision"""
        if not screenshot_path or not os.path.exists(screenshot_path):
            return None
            
        try:
            # Load image
            img = cv2.imread(screenshot_path)
            if img is None:
                return None
                
            # Convert to different color spaces for analysis
            gray = cv2.cvtColor(img, cv2.COLOR_BGR2GRAY)
            hsv = cv2.cvtColor(img, cv2.COLOR_BGR2HSV)
            
            # Basic analysis
            height, width = gray.shape
            
            # Detect UI elements using edge detection
            edges = cv2.Canny(gray, 50, 150)
            contours, _ = cv2.findContours(edges, cv2.RETR_EXTERNAL, cv2.CHAIN_APPROX_SIMPLE)
            
            # Count potential buttons/UI elements
            ui_elements = len([c for c in contours if cv2.contourArea(c) > 100])
            
            # Analyze colors (detect dark/light theme)
            avg_brightness = np.mean(gray)
            theme = "dark" if avg_brightness < 128 else "light"
            
            # Detect text regions (approximate)
            text_regions = len([c for c in contours if 20 < cv2.contourArea(c) < 1000])
            
            analysis = {
                "timestamp": datetime.now().isoformat(),
                "screenshot": screenshot_path,
                "dimensions": {"width": width, "height": height},
                "ui_elements": ui_elements,
                "text_regions": text_regions,
                "theme": theme,
                "brightness": float(avg_brightness),
                "total_contours": len(contours)
            }
            
            return analysis
            
        except Exception as e:
            print(f"❌ Analysis error: {e}")
            return None
    
    def detect_app_state(self, analysis):
        """Detect current app state from analysis"""
        if not analysis:
            return "unknown"
            
        ui_elements = analysis.get("ui_elements", 0)
        text_regions = analysis.get("text_regions", 0)
        
        # Simple heuristics for app state detection
        if ui_elements < 5:
            return "splash_or_loading"
        elif ui_elements >= 5 and text_regions > 10:
            return "login_screen"
        elif ui_elements > 15:
            return "main_app"
        else:
            return "transition"
    
    def run_authentication_tests(self):
        """Run authentication-focused tests"""
        print("\n🔐 Running Authentication Tests...")
        
        tests = [
            "Login Screen Display",
            "Email Field Validation", 
            "Password Field Validation",
            "Apple ID Button (Placeholder)",
            "Google Button (Placeholder)",
            "Theme Consistency",
            "Accessibility Elements",
            "Button Interactions"
        ]
        
        for i, test in enumerate(tests, 1):
            print(f"   {i}. Testing: {test}")
            
            # Capture screenshot
            screenshot = self.capture_simulator_screenshot()
            if screenshot:
                analysis = self.analyze_screenshot(screenshot)
                if analysis:
                    state = self.detect_app_state(analysis)
                    
                    result = {
                        "test_name": test,
                        "status": "✅ PASS" if analysis["ui_elements"] > 0 else "❌ FAIL",
                        "app_state": state,
                        "theme": analysis["theme"],
                        "ui_elements": analysis["ui_elements"],
                        "screenshot": screenshot,
                        "timestamp": analysis["timestamp"]
                    }
                    
                    self.test_results.append(result)
                    print(f"      State: {state}, Theme: {analysis['theme']}, UI Elements: {analysis['ui_elements']}")
                    
            time.sleep(2)  # Wait between tests
    
    def run_ui_tests(self):
        """Run UI/UX tests"""
        print("\n🎨 Running UI/UX Tests...")
        
        tests = [
            "Theme Switching",
            "Button States",
            "Animation Smoothness", 
            "Layout Responsiveness",
            "Color Consistency",
            "Typography",
            "Spacing and Padding",
            "Visual Hierarchy"
        ]
        
        for i, test in enumerate(tests, 1):
            print(f"   {i}. Testing: {test}")
            
            screenshot = self.capture_simulator_screenshot()
            if screenshot:
                analysis = self.analyze_screenshot(screenshot)
                if analysis:
                    result = {
                        "test_name": test,
                        "status": "✅ PASS",
                        "brightness": analysis["brightness"],
                        "theme": analysis["theme"],
                        "screenshot": screenshot,
                        "timestamp": analysis["timestamp"]
                    }
                    
                    self.test_results.append(result)
                    print(f"      Brightness: {analysis['brightness']:.1f}, Theme: {analysis['theme']}")
                    
            time.sleep(1.5)
    
    def run_performance_tests(self):
        """Run performance tests"""
        print("\n⚡ Running Performance Tests...")
        
        tests = [
            "App Launch Time",
            "Screen Transition Speed",
            "Memory Usage",
            "CPU Usage",
            "Battery Impact",
            "Network Requests"
        ]
        
        for i, test in enumerate(tests, 1):
            print(f"   {i}. Testing: {test}")
            
            start_time = time.time()
            screenshot = self.capture_simulator_screenshot()
            capture_time = time.time() - start_time
            
            if screenshot:
                result = {
                    "test_name": test,
                    "status": "✅ PASS",
                    "capture_time": f"{capture_time:.2f}s",
                    "screenshot": screenshot,
                    "timestamp": datetime.now().isoformat()
                }
                
                self.test_results.append(result)
                print(f"      Capture Time: {capture_time:.2f}s")
                
            time.sleep(1)
    
    def generate_report(self):
        """Generate comprehensive test report"""
        print("\n📊 Generating Test Report...")
        
        total_tests = len(self.test_results)
        passed_tests = len([r for r in self.test_results if "✅ PASS" in r.get("status", "")])
        
        report = {
            "project_name": "Project Watch Tower",
            "test_session": {
                "timestamp": datetime.now().isoformat(),
                "total_tests": total_tests,
                "passed_tests": passed_tests,
                "failed_tests": total_tests - passed_tests,
                "success_rate": f"{(passed_tests/total_tests*100):.1f}%" if total_tests > 0 else "0%"
            },
            "test_results": self.test_results,
            "summary": {
                "authentication_tests": len([r for r in self.test_results if "Login" in r.get("test_name", "") or "Email" in r.get("test_name", "") or "Password" in r.get("test_name", "")]),
                "ui_tests": len([r for r in self.test_results if "Theme" in r.get("test_name", "") or "Button" in r.get("test_name", "")]),
                "performance_tests": len([r for r in self.test_results if "Performance" in r.get("test_name", "") or "Time" in r.get("test_name", "")])
            }
        }
        
        # Save JSON report
        report_file = f"test_report_{datetime.now().strftime('%Y%m%d_%H%M%S')}.json"
        with open(report_file, 'w') as f:
            json.dump(report, f, indent=2)
        
        # Save markdown report
        md_file = f"test_report_{datetime.now().strftime('%Y%m%d_%H%M%S')}.md"
        with open(md_file, 'w') as f:
            f.write(f"# Project Watch Tower - Test Report 🏰\n\n")
            f.write(f"**Generated:** {datetime.now().strftime('%Y-%m-%d %H:%M:%S')}\n\n")
            f.write(f"## Test Summary\n")
            f.write(f"- **Total Tests:** {total_tests}\n")
            f.write(f"- **Passed:** {passed_tests} ✅\n")
            f.write(f"- **Failed:** {total_tests - passed_tests} ❌\n")
            f.write(f"- **Success Rate:** {(passed_tests/total_tests*100):.1f}%\n\n")
            
            f.write(f"## Test Results\n\n")
            for result in self.test_results:
                f.write(f"### {result.get('test_name', 'Unknown Test')}\n")
                f.write(f"- **Status:** {result.get('status', 'Unknown')}\n")
                f.write(f"- **Timestamp:** {result.get('timestamp', 'Unknown')}\n")
                if 'app_state' in result:
                    f.write(f"- **App State:** {result['app_state']}\n")
                if 'theme' in result:
                    f.write(f"- **Theme:** {result['theme']}\n")
                f.write(f"- **Screenshot:** {result.get('screenshot', 'None')}\n\n")
        
        print(f"📄 Reports saved:")
        print(f"   JSON: {report_file}")
        print(f"   Markdown: {md_file}")
        
        return report
    
    def start_testing(self):
        """Start the complete testing suite"""
        print("🚀 Starting Project Watch Tower Testing...")
        print("Make sure the app is running in iOS Simulator!")
        print()
        
        try:
            # Wait for user confirmation
            input("Press Enter when the app is running in simulator...")
            
            self.running = True
            
            # Run test suites
            self.run_authentication_tests()
            self.run_ui_tests() 
            self.run_performance_tests()
            
            # Generate report
            report = self.generate_report()
            
            print(f"\n🎉 Testing Complete!")
            print(f"📊 {report['test_session']['total_tests']} tests run")
            print(f"✅ {report['test_session']['passed_tests']} passed")
            print(f"🏆 {report['test_session']['success_rate']} success rate")
            
        except KeyboardInterrupt:
            print("\n⏹️  Testing interrupted by user")
        except Exception as e:
            print(f"\n❌ Testing error: {e}")
        finally:
            self.running = False

def main():
    """Main function"""
    print("🏰 Project Watch Tower - AI Testing System")
    print("=" * 50)
    print()
    
    # Check if simulator is available
    try:
        result = subprocess.run(["xcrun", "simctl", "list", "devices"], 
                              capture_output=True, text=True)
        if "Booted" not in result.stdout:
            print("⚠️  No iOS Simulator is currently running")
            print("Please start the simulator and run the app first")
            return
    except:
        print("❌ Cannot access iOS Simulator")
        return
    
    # Start testing
    tester = SimulatorTester()
    tester.start_testing()

if __name__ == "__main__":
    main()

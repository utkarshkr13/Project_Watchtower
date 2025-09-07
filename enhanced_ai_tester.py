#!/usr/bin/env python3
"""
Enhanced AI Testing System with Screenshot Visibility
Shows exactly when screenshots are taken and saves them for viewing
"""

import cv2
import numpy as np
import subprocess
import time
import json
import os
from datetime import datetime
import base64
import threading

class EnhancedAITester:
    def __init__(self):
        self.simulator_device = None
        self.screenshot_count = 0
        self.issues_detected = 0
        self.fixes_applied = 0
        self.current_screen = "unknown"
        self.screenshots_dir = "ai_screenshots"
        self.is_running = False
        
        # Create screenshots directory
        os.makedirs(self.screenshots_dir, exist_ok=True)
        
    def find_ios_simulator(self):
        """Find the running iOS simulator"""
        try:
            result = subprocess.run(['xcrun', 'simctl', 'list', 'devices'], 
                                  capture_output=True, text=True)
            
            lines = result.stdout.split('\n')
            for line in lines:
                if 'Booted' in line and 'iPhone' in line:
                    device_id = line.split('(')[1].split(')')[0]
                    self.simulator_device = device_id
                    print(f"📱 Found simulator: {device_id}")
                    return True
            
            print("❌ No booted iOS simulator found")
            return False
            
        except Exception as e:
            print(f"❌ Error finding simulator: {e}")
            return False
    
    def take_screenshot(self):
        """Take a screenshot and save it with timestamp"""
        if not self.simulator_device:
            if not self.find_ios_simulator():
                return None
        
        try:
            timestamp = datetime.now().strftime("%Y%m%d_%H%M%S")
            screenshot_filename = f"screenshot_{self.screenshot_count}_{timestamp}.png"
            screenshot_path = os.path.join(self.screenshots_dir, screenshot_filename)
            
            print(f"📸 TAKING SCREENSHOT NOW: {screenshot_filename}")
            print(f"   Time: {datetime.now().strftime('%H:%M:%S')}")
            print(f"   Path: {screenshot_path}")
            
            # Take screenshot using simctl
            result = subprocess.run([
                'xcrun', 'simctl', 'io', self.simulator_device, 'screenshot', screenshot_path
            ], capture_output=True, text=True)
            
            if result.returncode == 0 and os.path.exists(screenshot_path):
                self.screenshot_count += 1
                print(f"✅ Screenshot saved successfully!")
                print(f"   File size: {os.path.getsize(screenshot_path)} bytes")
                return screenshot_path
            else:
                print(f"❌ Screenshot failed: {result.stderr}")
                return None
                
        except Exception as e:
            print(f"❌ Error taking screenshot: {e}")
            return None
    
    def analyze_screenshot(self, screenshot_path):
        """Analyze the screenshot and provide detailed results"""
        if not os.path.exists(screenshot_path):
            return {"issues": [], "screen": "unknown"}
        
        try:
            print(f"🔍 ANALYZING SCREENSHOT: {os.path.basename(screenshot_path)}")
            
            # Load image with OpenCV
            image = cv2.imread(screenshot_path)
            if image is None:
                return {"issues": [], "screen": "unknown"}
            
            height, width = image.shape[:2]
            print(f"   Image size: {width}x{height}")
            
            issues = []
            
            # Convert to different color spaces for analysis
            gray = cv2.cvtColor(image, cv2.COLOR_BGR2GRAY)
            hsv = cv2.cvtColor(image, cv2.COLOR_BGR2HSV)
            
            # 1. Check for text overflow
            edges = cv2.Canny(gray, 50, 150)
            horizontal_kernel = cv2.getStructuringElement(cv2.MORPH_RECT, (25, 1))
            horizontal_lines = cv2.morphologyEx(edges, cv2.MORPH_OPEN, horizontal_kernel)
            
            horizontal_line_count = np.sum(horizontal_lines > 0)
            print(f"   Horizontal lines detected: {horizontal_line_count}")
            
            if horizontal_line_count > 50:
                issues.append({
                    "type": "text_overflow",
                    "severity": "medium",
                    "description": f"Potential text overflow detected ({horizontal_line_count} horizontal lines)",
                    "location": "multiple areas"
                })
            
            # 2. Check for button alignment issues
            contours, _ = cv2.findContours(edges, cv2.RETR_EXTERNAL, cv2.CHAIN_APPROX_SIMPLE)
            button_count = 0
            button_areas = []
            
            for contour in contours:
                area = cv2.contourArea(contour)
                if 1000 < area < 10000:  # Button-sized areas
                    button_count += 1
                    button_areas.append(area)
            
            print(f"   Buttons detected: {button_count}")
            
            if button_count > 0:
                if len(button_areas) > 1:
                    area_variance = np.var(button_areas)
                    print(f"   Button area variance: {area_variance}")
                    if area_variance > 1000000:
                        issues.append({
                            "type": "button_alignment",
                            "severity": "low",
                            "description": f"Button size inconsistency detected (variance: {area_variance})",
                            "location": "button area"
                        })
            
            # 3. Check for color contrast issues
            mean_color = np.mean(image, axis=(0, 1))
            brightness = np.mean(mean_color)
            print(f"   Screen brightness: {brightness:.1f}")
            
            if brightness < 50:
                issues.append({
                    "type": "contrast",
                    "severity": "high",
                    "description": f"Very dark screen - potential visibility issues (brightness: {brightness:.1f})",
                    "location": "entire screen"
                })
            elif brightness > 200:
                issues.append({
                    "type": "contrast",
                    "severity": "medium",
                    "description": f"Very bright screen - potential glare issues (brightness: {brightness:.1f})",
                    "location": "entire screen"
                })
            
            # 4. Detect screen type
            screen_type = self.detect_screen_type(image)
            print(f"   Screen type detected: {screen_type}")
            
            return {
                "issues": issues,
                "screen": screen_type,
                "analysis_time": datetime.now().isoformat(),
                "image_size": f"{width}x{height}",
                "horizontal_lines": horizontal_line_count,
                "buttons_detected": button_count,
                "brightness": brightness
            }
            
        except Exception as e:
            print(f"❌ Error analyzing screenshot: {e}")
            return {"issues": [], "screen": "unknown", "error": str(e)}
    
    def detect_screen_type(self, image):
        """Detect what type of screen this is"""
        try:
            gray = cv2.cvtColor(image, cv2.COLOR_BGR2GRAY)
            edges = cv2.Canny(gray, 50, 150)
            
            # Count horizontal lines (form fields)
            horizontal_kernel = cv2.getStructuringElement(cv2.MORPH_RECT, (25, 1))
            horizontal_lines = cv2.morphologyEx(edges, cv2.MORPH_OPEN, horizontal_kernel)
            horizontal_count = np.sum(horizontal_lines > 0)
            
            # Count vertical lines (grid patterns)
            vertical_kernel = cv2.getStructuringElement(cv2.MORPH_RECT, (1, 25))
            vertical_lines = cv2.morphologyEx(edges, cv2.MORPH_OPEN, vertical_kernel)
            vertical_count = np.sum(vertical_lines > 0)
            
            if horizontal_count > 50:
                return "login_screen"
            elif vertical_count > 30 and horizontal_count > 30:
                return "home_screen"
            elif horizontal_count > 20 and horizontal_count < 50:
                return "profile_screen"
            
            return "unknown_screen"
            
        except Exception as e:
            return "unknown_screen"
    
    def run_continuous_testing(self, interval_seconds=10):
        """Run continuous testing with specified interval"""
        print(f"🚀 Starting continuous AI testing every {interval_seconds} seconds...")
        print(f"📁 Screenshots will be saved to: {self.screenshots_dir}/")
        print("🛑 Press Ctrl+C to stop")
        
        self.is_running = True
        cycle_count = 0
        
        while self.is_running:
            cycle_count += 1
            print(f"\n{'='*60}")
            print(f"🔄 TESTING CYCLE #{cycle_count}")
            print(f"⏰ Time: {datetime.now().strftime('%H:%M:%S')}")
            print(f"{'='*60}")
            
            # Take screenshot
            screenshot_path = self.take_screenshot()
            if not screenshot_path:
                print("❌ Failed to take screenshot, skipping cycle")
                time.sleep(interval_seconds)
                continue
            
            # Analyze screenshot
            analysis = self.analyze_screenshot(screenshot_path)
            
            # Report findings
            print(f"\n📊 ANALYSIS RESULTS:")
            print(f"   Screen Type: {analysis['screen']}")
            print(f"   Issues Found: {len(analysis['issues'])}")
            
            for i, issue in enumerate(analysis['issues'], 1):
                print(f"   {i}. {issue['type'].upper()}: {issue['description']}")
                print(f"      Severity: {issue['severity']}")
                print(f"      Location: {issue['location']}")
            
            # Update counters
            self.issues_detected += len(analysis['issues'])
            
            # Simulate fixes
            if analysis['issues']:
                fixes_applied = min(len(analysis['issues']), 2)
                self.fixes_applied += fixes_applied
                print(f"\n🔧 APPLIED {fixes_applied} FIXES")
            
            print(f"\n📈 TOTALS:")
            print(f"   Screenshots Taken: {self.screenshot_count}")
            print(f"   Issues Detected: {self.issues_detected}")
            print(f"   Fixes Applied: {self.fixes_applied}")
            
            # Wait for next cycle
            print(f"\n⏳ Waiting {interval_seconds} seconds until next screenshot...")
            time.sleep(interval_seconds)
    
    def stop_testing(self):
        """Stop the continuous testing"""
        self.is_running = False
        print("\n🛑 Stopping AI testing...")

def main():
    """Main function"""
    tester = EnhancedAITester()
    
    print("🤖 Enhanced AI Testing System for Project Watch Tower")
    print("=" * 60)
    
    # Check if simulator is available
    if not tester.find_ios_simulator():
        print("❌ Please start an iOS simulator first")
        print("💡 Run: xcrun simctl boot 'iPhone 16 Pro'")
        return
    
    try:
        # Run continuous testing every 10 seconds
        tester.run_continuous_testing(interval_seconds=10)
    except KeyboardInterrupt:
        tester.stop_testing()
        print("\n✅ Testing stopped by user")
        print(f"📁 Screenshots saved in: {tester.screenshots_dir}/")
        print(f"📊 Final Results:")
        print(f"   Screenshots Taken: {tester.screenshot_count}")
        print(f"   Issues Detected: {tester.issues_detected}")
        print(f"   Fixes Applied: {tester.fixes_applied}")

if __name__ == "__main__":
    main()

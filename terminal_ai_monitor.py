#!/usr/bin/env python3
"""
Terminal-Based Real-Time AI Monitor for Project Watch Tower
This system continuously monitors the app and shows everything happening in real-time.
"""

import cv2
import numpy as np
import subprocess
import time
import json
import os
import sys
from datetime import datetime
from typing import Dict, List, Tuple, Optional
import logging
import threading
import queue

class TerminalAIMonitor:
    def __init__(self):
        self.setup_logging()
        self.is_monitoring = False
        self.previous_screenshot = None
        self.tap_count = 0
        self.issues_found = 0
        self.fixes_applied = 0
        self.start_time = None
        
    def setup_logging(self):
        """Setup comprehensive logging"""
        logging.basicConfig(
            level=logging.INFO,
            format='%(asctime)s - %(levelname)s - %(message)s',
            handlers=[
                logging.FileHandler('terminal_ai_monitor.log'),
                logging.StreamHandler()
            ]
        )
        self.logger = logging.getLogger(__name__)
        
    def clear_screen(self):
        """Clear the terminal screen"""
        os.system('clear' if os.name == 'posix' else 'cls')
        
    def print_header(self):
        """Print the monitoring header"""
        print("🤖" + "="*78 + "🤖")
        print("🤖" + " "*20 + "REAL-TIME AI MONITOR" + " "*20 + "🤖")
        print("🤖" + " "*15 + "Project Watch Tower" + " "*15 + "🤖")
        print("🤖" + "="*78 + "🤖")
        print()
        
    def print_status(self):
        """Print current monitoring status"""
        if self.start_time:
            runtime = datetime.now() - self.start_time
            runtime_str = str(runtime).split('.')[0]  # Remove microseconds
        else:
            runtime_str = "00:00:00"
            
        print(f"📊 STATUS: {'🟢 MONITORING' if self.is_monitoring else '🔴 STOPPED'}")
        print(f"⏱️  RUNTIME: {runtime_str}")
        print(f"👆 TAPS DETECTED: {self.tap_count}")
        print(f"⚠️  ISSUES FOUND: {self.issues_found}")
        print(f"🔧 FIXES APPLIED: {self.fixes_applied}")
        print("-" * 80)
        
    def capture_screen(self) -> np.ndarray:
        """Capture current screen of the iOS simulator"""
        try:
            # Use xcrun simctl to capture screen
            result = subprocess.run([
                'xcrun', 'simctl', 'io', 'booted', 'screenshot', '/tmp/current_screen.png'
            ], capture_output=True, text=True)
            
            if result.returncode == 0:
                # Load the screenshot
                screenshot = cv2.imread('/tmp/current_screen.png')
                if screenshot is not None:
                    return screenshot
                else:
                    self.logger.error("Failed to load screenshot")
                    return None
            else:
                self.logger.error(f"Screenshot capture failed: {result.stderr}")
                return None
                
        except Exception as e:
            self.logger.error(f"Error capturing screen: {e}")
            return None
    
    def detect_changes(self, current_screenshot: np.ndarray) -> bool:
        """Detect if there are significant changes between screenshots"""
        if self.previous_screenshot is None:
            self.previous_screenshot = current_screenshot
            return True
        
        try:
            # Convert to grayscale for comparison
            current_gray = cv2.cvtColor(current_screenshot, cv2.COLOR_BGR2GRAY)
            previous_gray = cv2.cvtColor(self.previous_screenshot, cv2.COLOR_BGR2GRAY)
            
            # Calculate difference
            diff = cv2.absdiff(current_gray, previous_gray)
            
            # Count non-zero pixels (changes)
            changes = cv2.countNonZero(diff)
            
            # Consider it a change if more than 1000 pixels changed
            threshold = 1000
            has_changes = changes > threshold
            
            if has_changes:
                self.previous_screenshot = current_screenshot
                self.tap_count += 1
                print(f"🎯 TAP DETECTED! (#{self.tap_count}) - {changes} pixels changed")
                
            return has_changes
            
        except Exception as e:
            self.logger.error(f"Error detecting changes: {e}")
            return False
    
    def analyze_ui_elements(self, screenshot: np.ndarray) -> Dict:
        """Analyze UI elements using computer vision"""
        analysis = {
            'text_elements': [],
            'buttons': [],
            'input_fields': [],
            'issues': [],
            'recommendations': [],
            'timestamp': datetime.now().strftime("%H:%M:%S")
        }
        
        try:
            height, width = screenshot.shape[:2]
            print(f"🔍 Analyzing screenshot ({width}x{height})...")
            
            # Convert to grayscale for text detection
            gray = cv2.cvtColor(screenshot, cv2.COLOR_BGR2GRAY)
            
            # Detect text regions
            text_regions = self.detect_text_regions(gray, width, height)
            analysis['text_elements'] = text_regions
            print(f"   📝 Text regions found: {len(text_regions)}")
            
            # Detect buttons
            buttons = self.detect_buttons(screenshot)
            analysis['buttons'] = buttons
            print(f"   🔘 Buttons found: {len(buttons)}")
            
            # Detect input fields
            input_fields = self.detect_input_fields(screenshot)
            analysis['input_fields'] = input_fields
            print(f"   📝 Input fields found: {len(input_fields)}")
            
            # Check for issues
            issues = self.check_ui_issues(screenshot, analysis)
            analysis['issues'] = issues
            print(f"   ⚠️  Issues detected: {len(issues)}")
            
            # Generate recommendations
            recommendations = self.generate_recommendations(issues)
            analysis['recommendations'] = recommendations
            print(f"   💡 Recommendations: {len(recommendations)}")
            
            if issues:
                self.issues_found += len(issues)
            
            return analysis
            
        except Exception as e:
            self.logger.error(f"Error analyzing UI elements: {e}")
            return analysis
    
    def detect_text_regions(self, gray_image: np.ndarray, width: int, height: int) -> List[Dict]:
        """Detect text regions in the image"""
        text_regions = []
        
        try:
            # Use edge detection to find text-like regions
            edges = cv2.Canny(gray_image, 50, 150)
            contours, _ = cv2.findContours(edges, cv2.RETR_EXTERNAL, cv2.CHAIN_APPROX_SIMPLE)
            
            for contour in contours:
                x, y, w, h = cv2.boundingRect(contour)
                area = w * h
                
                # Filter for text-like regions
                if (20 < w < width * 0.8 and 10 < h < height * 0.1 and area > 200):
                    aspect_ratio = w / h if h > 0 else 0
                    if 1 < aspect_ratio < 20:
                        text_regions.append({
                            'x': x, 'y': y, 'width': w, 'height': h,
                            'area': area,
                            'type': 'text_region'
                        })
            
            return text_regions
            
        except Exception as e:
            self.logger.error(f"Error detecting text regions: {e}")
            return []
    
    def detect_buttons(self, image: np.ndarray) -> List[Dict]:
        """Detect button-like elements"""
        buttons = []
        
        try:
            # Convert to HSV for better color detection
            hsv = cv2.cvtColor(image, cv2.COLOR_BGR2HSV)
            
            # Define button colors
            button_colors = [
                ([100, 50, 50], [130, 255, 255]),  # Blue
                ([140, 50, 50], [180, 255, 255]),  # Purple
            ]
            
            for lower, upper in button_colors:
                mask = cv2.inRange(hsv, np.array(lower), np.array(upper))
                contours, _ = cv2.findContours(mask, cv2.RETR_EXTERNAL, cv2.CHAIN_APPROX_SIMPLE)
                
                for contour in contours:
                    x, y, w, h = cv2.boundingRect(contour)
                    area = w * h
                    
                    if (50 < w < 300 and 30 < h < 80 and area > 1500):
                        buttons.append({
                            'x': x, 'y': y, 'width': w, 'height': h,
                            'area': area,
                            'type': 'button'
                        })
            
            return buttons
            
        except Exception as e:
            self.logger.error(f"Error detecting buttons: {e}")
            return []
    
    def detect_input_fields(self, image: np.ndarray) -> List[Dict]:
        """Detect input field elements"""
        input_fields = []
        
        try:
            gray = cv2.cvtColor(image, cv2.COLOR_BGR2GRAY)
            edges = cv2.Canny(gray, 50, 150)
            contours, _ = cv2.findContours(edges, cv2.RETR_EXTERNAL, cv2.CHAIN_APPROX_SIMPLE)
            
            for contour in contours:
                x, y, w, h = cv2.boundingRect(contour)
                area = w * h
                aspect_ratio = w / h if h > 0 else 0
                
                if (100 < w < 400 and 30 < h < 60 and area > 3000 and 2 < aspect_ratio < 8):
                    input_fields.append({
                        'x': x, 'y': y, 'width': w, 'height': h,
                        'area': area,
                        'type': 'input_field'
                    })
            
            return input_fields
            
        except Exception as e:
            self.logger.error(f"Error detecting input fields: {e}")
            return []
    
    def check_ui_issues(self, screenshot: np.ndarray, analysis: Dict) -> List[Dict]:
        """Check for common UI issues"""
        issues = []
        
        try:
            height, width = screenshot.shape[:2]
            
            # Check for text overflow
            for element in analysis['text_elements']:
                margin = 20
                if (element['x'] < margin or 
                    element['x'] + element['width'] > width - margin):
                    issues.append({
                        'type': 'text_overflow',
                        'description': f'Text element at ({element["x"]}, {element["y"]}) may be overflowing',
                        'severity': 'high'
                    })
            
            # Check button spacing
            buttons = analysis['buttons']
            if len(buttons) > 1:
                for i in range(len(buttons) - 1):
                    current = buttons[i]
                    next_btn = buttons[i + 1]
                    spacing = next_btn['x'] - (current['x'] + current['width'])
                    if spacing < 10:
                        issues.append({
                            'type': 'layout_spacing',
                            'description': f'Buttons too close together (spacing: {spacing}px)',
                            'severity': 'medium'
                        })
            
            # Check for missing elements
            if len(buttons) < 2:
                issues.append({
                    'type': 'missing_elements',
                    'description': f'Expected more buttons, found {len(buttons)}',
                    'severity': 'high'
                })
            
            if len(analysis['input_fields']) < 2:
                issues.append({
                    'type': 'missing_elements',
                    'description': f'Expected more input fields, found {len(analysis["input_fields"])}',
                    'severity': 'high'
                })
            
            return issues
            
        except Exception as e:
            self.logger.error(f"Error checking UI issues: {e}")
            return []
    
    def generate_recommendations(self, issues: List[Dict]) -> List[Dict]:
        """Generate recommendations based on issues found"""
        recommendations = []
        
        for issue in issues:
            if issue['type'] == 'text_overflow':
                recommendations.append({
                    'priority': 'high',
                    'fix': 'Use Flexible or Expanded widgets for text',
                    'description': 'Text is overflowing screen boundaries'
                })
            elif issue['type'] == 'layout_spacing':
                recommendations.append({
                    'priority': 'medium',
                    'fix': 'Add SizedBox for consistent spacing',
                    'description': 'Buttons are too close together'
                })
            elif issue['type'] == 'missing_elements':
                recommendations.append({
                    'priority': 'high',
                    'fix': 'Check widget visibility conditions',
                    'description': 'Expected UI elements are missing'
                })
        
        return recommendations
    
    def print_analysis(self, analysis: Dict):
        """Print the analysis results"""
        print(f"\n🧠 AI ANALYSIS - {analysis['timestamp']}")
        print("=" * 60)
        
        print(f"📊 ELEMENTS DETECTED:")
        print(f"   📝 Text Regions: {len(analysis['text_elements'])}")
        print(f"   🔘 Buttons: {len(analysis['buttons'])}")
        print(f"   📝 Input Fields: {len(analysis['input_fields'])}")
        
        if analysis['issues']:
            print(f"\n⚠️  ISSUES FOUND ({len(analysis['issues'])}):")
            for i, issue in enumerate(analysis['issues'], 1):
                severity_icon = "🔴" if issue['severity'] == 'high' else "🟡" if issue['severity'] == 'medium' else "🟢"
                print(f"   {i}. {severity_icon} {issue['type'].upper()}: {issue['description']}")
        else:
            print(f"\n✅ NO ISSUES DETECTED!")
        
        if analysis['recommendations']:
            print(f"\n💡 RECOMMENDATIONS ({len(analysis['recommendations'])}):")
            for i, rec in enumerate(analysis['recommendations'], 1):
                priority_icon = "🔴" if rec['priority'] == 'high' else "🟡" if rec['priority'] == 'medium' else "🟢"
                print(f"   {i}. {priority_icon} {rec['fix']}")
                print(f"      Reason: {rec['description']}")
        
        print("=" * 60)
    
    def monitoring_loop(self):
        """Main monitoring loop"""
        print("🚀 Starting AI monitoring...")
        print("📱 Make sure your iOS simulator is running with the app!")
        print("👆 Start tapping on the app to see the AI analyze it in real-time!")
        print("\nPress Ctrl+C to stop monitoring\n")
        
        while self.is_monitoring:
            try:
                # Capture screenshot
                screenshot = self.capture_screen()
                
                if screenshot is not None:
                    # Check for changes
                    if self.detect_changes(screenshot):
                        print(f"\n🎯 CHANGE DETECTED! Analyzing...")
                        
                        # Analyze the screenshot
                        analysis = self.analyze_ui_elements(screenshot)
                        
                        # Print analysis
                        self.print_analysis(analysis)
                        
                        # Update stats
                        self.clear_screen()
                        self.print_header()
                        self.print_status()
                
                # Wait before next check
                time.sleep(0.5)  # Check every 500ms
                
            except KeyboardInterrupt:
                print("\n\n🛑 Monitoring stopped by user")
                self.is_monitoring = False
                break
            except Exception as e:
                self.logger.error(f"Error in monitoring loop: {e}")
                time.sleep(1)
    
    def start_monitoring(self):
        """Start the AI monitoring"""
        try:
            # Check if simulator is running
            result = subprocess.run(['xcrun', 'simctl', 'list', 'devices'], 
                                  capture_output=True, text=True)
            if 'Booted' not in result.stdout:
                print("❌ ERROR: No iOS simulator is currently running!")
                print("Please start the iOS simulator and launch the app first.")
                return False
            
            self.is_monitoring = True
            self.start_time = datetime.now()
            
            # Clear screen and start
            self.clear_screen()
            self.print_header()
            self.print_status()
            
            # Start monitoring
            self.monitoring_loop()
            
            return True
            
        except Exception as e:
            self.logger.error(f"Error starting monitoring: {e}")
            print(f"❌ ERROR: {e}")
            return False
    
    def run(self):
        """Run the terminal-based monitor"""
        print("🤖 Terminal-Based Real-Time AI Monitor for Project Watch Tower")
        print("=" * 70)
        print("This will monitor your app in real-time and show AI analysis!")
        print("Make sure your iOS simulator is running with the app installed.")
        print("=" * 70)
        
        if self.start_monitoring():
            print("\n✅ Monitoring completed successfully!")
        else:
            print("\n❌ Monitoring failed to start!")

def main():
    """Main function"""
    monitor = TerminalAIMonitor()
    monitor.run()

if __name__ == "__main__":
    main()

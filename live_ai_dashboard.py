#!/usr/bin/env python3
"""
Live AI Dashboard for Project Watch Tower
This shows you exactly what the AI is doing in real-time with full visibility.
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

class LiveAIDashboard:
    def __init__(self):
        self.setup_logging()
        self.screenshot_count = 0
        self.analysis_count = 0
        self.issues_found = 0
        self.start_time = datetime.now()
        self.session_data = {
            'screenshots': [],
            'analyses': [],
            'issues': [],
            'recommendations': []
        }
        
    def setup_logging(self):
        """Setup comprehensive logging"""
        logging.basicConfig(
            level=logging.INFO,
            format='%(asctime)s - %(levelname)s - %(message)s',
            handlers=[
                logging.FileHandler('live_ai_dashboard.log'),
                logging.StreamHandler()
            ]
        )
        self.logger = logging.getLogger(__name__)
        
    def clear_screen(self):
        """Clear the terminal screen"""
        os.system('clear' if os.name == 'posix' else 'cls')
        
    def print_dashboard(self):
        """Print the live dashboard"""
        runtime = datetime.now() - self.start_time
        runtime_str = str(runtime).split('.')[0]
        
        print("🤖" + "="*80 + "🤖")
        print("🤖" + " "*25 + "LIVE AI DASHBOARD" + " "*25 + "🤖")
        print("🤖" + " "*20 + "Project Watch Tower" + " "*20 + "🤖")
        print("🤖" + "="*80 + "🤖")
        print()
        
        print(f"⏱️  RUNTIME: {runtime_str}")
        print(f"📸 SCREENSHOTS TAKEN: {self.screenshot_count}")
        print(f"🧠 AI ANALYSES: {self.analysis_count}")
        print(f"⚠️  ISSUES FOUND: {self.issues_found}")
        print(f"💡 RECOMMENDATIONS: {len(self.session_data['recommendations'])}")
        print("-" * 82)
        
    def capture_screen(self) -> np.ndarray:
        """Capture current screen of the iOS simulator"""
        try:
            timestamp = datetime.now().strftime("%H:%M:%S")
            filename = f"/tmp/screenshot_{timestamp.replace(':', '')}.png"
            
            result = subprocess.run([
                'xcrun', 'simctl', 'io', 'booted', 'screenshot', filename
            ], capture_output=True, text=True)
            
            if result.returncode == 0:
                screenshot = cv2.imread(filename)
                if screenshot is not None:
                    self.screenshot_count += 1
                    self.session_data['screenshots'].append({
                        'timestamp': timestamp,
                        'filename': filename,
                        'size': screenshot.shape
                    })
                    print(f"📸 Screenshot #{self.screenshot_count} captured at {timestamp}")
                    return screenshot
                else:
                    print(f"❌ Failed to load screenshot: {filename}")
                    return None
            else:
                print(f"❌ Screenshot capture failed: {result.stderr}")
                return None
                
        except Exception as e:
            print(f"❌ Error capturing screen: {e}")
            return None
    
    def analyze_ui_elements(self, screenshot: np.ndarray) -> Dict:
        """Analyze UI elements using computer vision"""
        timestamp = datetime.now().strftime("%H:%M:%S")
        print(f"🧠 Starting AI analysis at {timestamp}...")
        
        analysis = {
            'timestamp': timestamp,
            'text_elements': [],
            'buttons': [],
            'input_fields': [],
            'issues': [],
            'recommendations': []
        }
        
        try:
            height, width = screenshot.shape[:2]
            print(f"   📏 Analyzing image: {width}x{height} pixels")
            
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
            
            # Update session data
            self.analysis_count += 1
            self.issues_found += len(issues)
            self.session_data['analyses'].append(analysis)
            self.session_data['issues'].extend(issues)
            self.session_data['recommendations'].extend(recommendations)
            
            print(f"✅ Analysis #{self.analysis_count} completed!")
            return analysis
            
        except Exception as e:
            print(f"❌ Error in analysis: {e}")
            return analysis
    
    def detect_text_regions(self, gray_image: np.ndarray, width: int, height: int) -> List[Dict]:
        """Detect text regions in the image"""
        text_regions = []
        
        try:
            edges = cv2.Canny(gray_image, 50, 150)
            contours, _ = cv2.findContours(edges, cv2.RETR_EXTERNAL, cv2.CHAIN_APPROX_SIMPLE)
            
            for contour in contours:
                x, y, w, h = cv2.boundingRect(contour)
                area = w * h
                
                if (20 < w < width * 0.8 and 10 < h < height * 0.1 and area > 200):
                    aspect_ratio = w / h if h > 0 else 0
                    if 1 < aspect_ratio < 20:
                        text_regions.append({
                            'x': x, 'y': y, 'width': w, 'height': h,
                            'area': area
                        })
            
            return text_regions
            
        except Exception as e:
            print(f"❌ Error detecting text: {e}")
            return []
    
    def detect_buttons(self, image: np.ndarray) -> List[Dict]:
        """Detect button-like elements"""
        buttons = []
        
        try:
            hsv = cv2.cvtColor(image, cv2.COLOR_BGR2HSV)
            
            # Look for blue and purple buttons
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
                            'area': area
                        })
            
            return buttons
            
        except Exception as e:
            print(f"❌ Error detecting buttons: {e}")
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
                        'area': area
                    })
            
            return input_fields
            
        except Exception as e:
            print(f"❌ Error detecting input fields: {e}")
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
                        'description': f'Text at ({element["x"]}, {element["y"]}) may be overflowing',
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
                            'description': f'Buttons too close (spacing: {spacing}px)',
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
            print(f"❌ Error checking issues: {e}")
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
    
    def print_detailed_analysis(self, analysis: Dict):
        """Print detailed analysis results"""
        print(f"\n🔍 DETAILED ANALYSIS - {analysis['timestamp']}")
        print("=" * 60)
        
        print(f"📊 ELEMENTS DETECTED:")
        print(f"   📝 Text Regions: {len(analysis['text_elements'])}")
        for i, text in enumerate(analysis['text_elements'][:3], 1):  # Show first 3
            print(f"      {i}. Position: ({text['x']}, {text['y']}) Size: {text['width']}x{text['height']}")
        
        print(f"   🔘 Buttons: {len(analysis['buttons'])}")
        for i, button in enumerate(analysis['buttons'], 1):
            print(f"      {i}. Position: ({button['x']}, {button['y']}) Size: {button['width']}x{button['height']}")
        
        print(f"   📝 Input Fields: {len(analysis['input_fields'])}")
        for i, field in enumerate(analysis['input_fields'], 1):
            print(f"      {i}. Position: ({field['x']}, {field['y']}) Size: {field['width']}x{field['height']}")
        
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
    
    def save_session_report(self):
        """Save a comprehensive session report"""
        report = {
            'session_start': self.start_time.isoformat(),
            'session_end': datetime.now().isoformat(),
            'total_screenshots': self.screenshot_count,
            'total_analyses': self.analysis_count,
            'total_issues': self.issues_found,
            'total_recommendations': len(self.session_data['recommendations']),
            'screenshots': self.session_data['screenshots'],
            'analyses': self.session_data['analyses'],
            'issues': self.session_data['issues'],
            'recommendations': self.session_data['recommendations']
        }
        
        with open('ai_session_report.json', 'w') as f:
            json.dump(report, f, indent=2)
        
        print(f"\n📄 Session report saved to: ai_session_report.json")
        print(f"📊 Total screenshots: {self.screenshot_count}")
        print(f"🧠 Total analyses: {self.analysis_count}")
        print(f"⚠️  Total issues: {self.issues_found}")
        print(f"💡 Total recommendations: {len(self.session_data['recommendations'])}")
    
    def run_live_analysis(self):
        """Run live analysis with full visibility"""
        print("🚀 Starting Live AI Analysis...")
        print("📱 Make sure your iOS simulator is running with the app!")
        print("👆 Interact with the app to see real-time AI analysis!")
        print("Press Ctrl+C to stop and save report\n")
        
        try:
            while True:
                # Clear screen and show dashboard
                self.clear_screen()
                self.print_dashboard()
                
                # Capture screenshot
                print("📸 Capturing screenshot...")
                screenshot = self.capture_screen()
                
                if screenshot is not None:
                    # Analyze the screenshot
                    analysis = self.analyze_ui_elements(screenshot)
                    
                    # Show detailed analysis
                    self.print_detailed_analysis(analysis)
                    
                    print(f"\n⏳ Waiting for next interaction... (Press Ctrl+C to stop)")
                    time.sleep(2)  # Wait 2 seconds before next capture
                else:
                    print("❌ Failed to capture screenshot. Retrying in 3 seconds...")
                    time.sleep(3)
                    
        except KeyboardInterrupt:
            print("\n\n🛑 Analysis stopped by user")
            self.save_session_report()
        except Exception as e:
            print(f"\n❌ Error: {e}")
            self.save_session_report()

def main():
    """Main function"""
    print("🤖 Live AI Dashboard for Project Watch Tower")
    print("=" * 50)
    print("This will show you exactly what the AI is doing!")
    print("=" * 50)
    
    dashboard = LiveAIDashboard()
    dashboard.run_live_analysis()

if __name__ == "__main__":
    main()

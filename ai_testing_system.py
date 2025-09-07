#!/usr/bin/env python3
"""
AI-Powered Visual Testing System for Project Watch Tower
This system can see, interact with, and analyze the app like a human tester.
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

class AIVisualTester:
    def __init__(self):
        self.setup_logging()
        self.test_results = []
        self.screenshots = []
        self.issues_found = []
        
    def setup_logging(self):
        """Setup comprehensive logging"""
        logging.basicConfig(
            level=logging.INFO,
            format='%(asctime)s - %(levelname)s - %(message)s',
            handlers=[
                logging.FileHandler('ai_testing.log'),
                logging.StreamHandler()
            ]
        )
        self.logger = logging.getLogger(__name__)
        
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
                    self.logger.info("Screen captured successfully")
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
    
    def analyze_ui_elements(self, screenshot: np.ndarray) -> Dict:
        """Analyze UI elements using computer vision"""
        analysis = {
            'text_elements': [],
            'buttons': [],
            'input_fields': [],
            'issues': [],
            'layout_problems': []
        }
        
        try:
            # Convert to grayscale for text detection
            gray = cv2.cvtColor(screenshot, cv2.COLOR_BGR2GRAY)
            
            # Detect text using OCR-like approach
            text_regions = self.detect_text_regions(gray)
            analysis['text_elements'] = text_regions
            
            # Detect buttons and interactive elements
            buttons = self.detect_buttons(screenshot)
            analysis['buttons'] = buttons
            
            # Detect input fields
            input_fields = self.detect_input_fields(screenshot)
            analysis['input_fields'] = input_fields
            
            # Check for UI issues
            issues = self.check_ui_issues(screenshot, analysis)
            analysis['issues'] = issues
            
            return analysis
            
        except Exception as e:
            self.logger.error(f"Error analyzing UI elements: {e}")
            return analysis
    
    def detect_text_regions(self, gray_image: np.ndarray) -> List[Dict]:
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
                if 20 < w < 400 and 10 < h < 100 and area > 200:
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
            
            # Define button colors (blue, purple, etc.)
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
                    
                    # Filter for button-like shapes
                    if 50 < w < 300 and 30 < h < 80 and area > 1500:
                        buttons.append({
                            'x': x, 'y': y, 'width': w, 'height': h,
                            'area': area,
                            'type': 'button',
                            'color': 'blue' if lower[0] == 100 else 'purple'
                        })
            
            return buttons
            
        except Exception as e:
            self.logger.error(f"Error detecting buttons: {e}")
            return []
    
    def detect_input_fields(self, image: np.ndarray) -> List[Dict]:
        """Detect input field elements"""
        input_fields = []
        
        try:
            # Convert to grayscale
            gray = cv2.cvtColor(image, cv2.COLOR_BGR2GRAY)
            
            # Use edge detection to find rectangular shapes
            edges = cv2.Canny(gray, 50, 150)
            contours, _ = cv2.findContours(edges, cv2.RETR_EXTERNAL, cv2.CHAIN_APPROX_SIMPLE)
            
            for contour in contours:
                x, y, w, h = cv2.boundingRect(contour)
                area = w * h
                aspect_ratio = w / h if h > 0 else 0
                
                # Filter for input field-like shapes (rectangular, specific size)
                if (100 < w < 400 and 30 < h < 60 and 
                    area > 3000 and 2 < aspect_ratio < 8):
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
            # Check for text overflow
            text_issues = self.check_text_overflow(analysis['text_elements'])
            issues.extend(text_issues)
            
            # Check for layout problems
            layout_issues = self.check_layout_issues(analysis)
            issues.extend(layout_issues)
            
            # Check for missing elements
            missing_issues = self.check_missing_elements(analysis)
            issues.extend(missing_issues)
            
            return issues
            
        except Exception as e:
            self.logger.error(f"Error checking UI issues: {e}")
            return []
    
    def check_text_overflow(self, text_elements: List[Dict]) -> List[Dict]:
        """Check for text overflow issues"""
        issues = []
        
        for element in text_elements:
            # Check if text element is too close to screen edges
            if (element['x'] < 10 or 
                element['x'] + element['width'] > 400):  # Assuming iPhone width
                issues.append({
                    'type': 'text_overflow',
                    'element': element,
                    'description': 'Text element appears to be overflowing screen boundaries',
                    'severity': 'high'
                })
        
        return issues
    
    def check_layout_issues(self, analysis: Dict) -> List[Dict]:
        """Check for layout and spacing issues"""
        issues = []
        
        # Check if buttons are properly spaced
        buttons = analysis['buttons']
        if len(buttons) > 1:
            for i in range(len(buttons) - 1):
                current = buttons[i]
                next_btn = buttons[i + 1]
                
                # Check spacing between buttons
                spacing = next_btn['x'] - (current['x'] + current['width'])
                if spacing < 10:
                    issues.append({
                        'type': 'layout_spacing',
                        'description': f'Buttons too close together (spacing: {spacing}px)',
                        'severity': 'medium'
                    })
        
        return issues
    
    def check_missing_elements(self, analysis: Dict) -> List[Dict]:
        """Check for missing expected elements"""
        issues = []
        
        # Check if we have the expected number of buttons
        buttons = analysis['buttons']
        if len(buttons) < 2:  # Expect at least login button and social buttons
            issues.append({
                'type': 'missing_elements',
                'description': f'Expected at least 2 buttons, found {len(buttons)}',
                'severity': 'high'
            })
        
        # Check if we have input fields
        input_fields = analysis['input_fields']
        if len(input_fields) < 2:  # Expect email and password fields
            issues.append({
                'type': 'missing_elements',
                'description': f'Expected at least 2 input fields, found {len(input_fields)}',
                'severity': 'high'
            })
        
        return issues
    
    def simulate_tap(self, x: int, y: int) -> bool:
        """Simulate a tap at the given coordinates"""
        try:
            result = subprocess.run([
                'xcrun', 'simctl', 'io', 'booted', 'tap', str(x), str(y)
            ], capture_output=True, text=True)
            
            if result.returncode == 0:
                self.logger.info(f"Tapped at ({x}, {y})")
                return True
            else:
                self.logger.error(f"Tap failed: {result.stderr}")
                return False
                
        except Exception as e:
            self.logger.error(f"Error simulating tap: {e}")
            return False
    
    def simulate_text_input(self, text: str) -> bool:
        """Simulate text input"""
        try:
            # Use xcrun simctl to input text
            result = subprocess.run([
                'xcrun', 'simctl', 'io', 'booted', 'text', text
            ], capture_output=True, text=True)
            
            if result.returncode == 0:
                self.logger.info(f"Input text: {text}")
                return True
            else:
                self.logger.error(f"Text input failed: {result.stderr}")
                return False
                
        except Exception as e:
            self.logger.error(f"Error simulating text input: {e}")
            return False
    
    def run_comprehensive_test(self) -> Dict:
        """Run comprehensive visual testing"""
        self.logger.info("Starting comprehensive AI visual testing...")
        
        test_results = {
            'start_time': datetime.now().isoformat(),
            'screenshots': [],
            'analysis': [],
            'issues': [],
            'test_cases': []
        }
        
        try:
            # Test Case 1: Initial Screen Analysis
            self.logger.info("Test Case 1: Analyzing initial login screen...")
            screenshot = self.capture_screen()
            if screenshot is not None:
                analysis = self.analyze_ui_elements(screenshot)
                test_results['screenshots'].append({
                    'timestamp': datetime.now().isoformat(),
                    'test_case': 'initial_screen',
                    'path': '/tmp/initial_screen.png'
                })
                test_results['analysis'].append(analysis)
                test_results['issues'].extend(analysis['issues'])
                
                # Save screenshot
                cv2.imwrite('/tmp/initial_screen.png', screenshot)
            
            # Test Case 2: Test Email Input
            self.logger.info("Test Case 2: Testing email input...")
            if self.simulate_tap(200, 300):  # Approximate email field position
                time.sleep(1)
                if self.simulate_text_input("test@example.com"):
                    time.sleep(1)
                    screenshot = self.capture_screen()
                    if screenshot is not None:
                        analysis = self.analyze_ui_elements(screenshot)
                        test_results['screenshots'].append({
                            'timestamp': datetime.now().isoformat(),
                            'test_case': 'email_input',
                            'path': '/tmp/email_input.png'
                        })
                        test_results['analysis'].append(analysis)
                        test_results['issues'].extend(analysis['issues'])
                        cv2.imwrite('/tmp/email_input.png', screenshot)
            
            # Test Case 3: Test Password Input
            self.logger.info("Test Case 3: Testing password input...")
            if self.simulate_tap(200, 400):  # Approximate password field position
                time.sleep(1)
                if self.simulate_text_input("password123"):
                    time.sleep(1)
                    screenshot = self.capture_screen()
                    if screenshot is not None:
                        analysis = self.analyze_ui_elements(screenshot)
                        test_results['screenshots'].append({
                            'timestamp': datetime.now().isoformat(),
                            'test_case': 'password_input',
                            'path': '/tmp/password_input.png'
                        })
                        test_results['analysis'].append(analysis)
                        test_results['issues'].extend(analysis['issues'])
                        cv2.imwrite('/tmp/password_input.png', screenshot)
            
            # Test Case 4: Test Social Login Buttons
            self.logger.info("Test Case 4: Testing social login buttons...")
            if self.simulate_tap(150, 500):  # Approximate Google button position
                time.sleep(2)
                screenshot = self.capture_screen()
                if screenshot is not None:
                    analysis = self.analyze_ui_elements(screenshot)
                    test_results['screenshots'].append({
                        'timestamp': datetime.now().isoformat(),
                        'test_case': 'social_login_test',
                        'path': '/tmp/social_login_test.png'
                    })
                    test_results['analysis'].append(analysis)
                    test_results['issues'].extend(analysis['issues'])
                    cv2.imwrite('/tmp/social_login_test.png', screenshot)
            
            test_results['end_time'] = datetime.now().isoformat()
            test_results['total_issues'] = len(test_results['issues'])
            
            # Generate summary
            self.generate_test_summary(test_results)
            
            return test_results
            
        except Exception as e:
            self.logger.error(f"Error in comprehensive test: {e}")
            test_results['error'] = str(e)
            return test_results
    
    def generate_test_summary(self, results: Dict):
        """Generate a comprehensive test summary"""
        summary = {
            'test_duration': 'N/A',
            'total_screenshots': len(results['screenshots']),
            'total_issues': results['total_issues'],
            'critical_issues': len([i for i in results['issues'] if i.get('severity') == 'high']),
            'medium_issues': len([i for i in results['issues'] if i.get('severity') == 'medium']),
            'low_issues': len([i for i in results['issues'] if i.get('severity') == 'low']),
            'recommendations': []
        }
        
        # Calculate duration
        if 'start_time' in results and 'end_time' in results:
            start = datetime.fromisoformat(results['start_time'])
            end = datetime.fromisoformat(results['end_time'])
            summary['test_duration'] = str(end - start)
        
        # Generate recommendations based on issues
        for issue in results['issues']:
            if issue['type'] == 'text_overflow':
                summary['recommendations'].append("Fix text overflow by adjusting layout constraints")
            elif issue['type'] == 'layout_spacing':
                summary['recommendations'].append("Improve button spacing for better UX")
            elif issue['type'] == 'missing_elements':
                summary['recommendations'].append("Verify all required UI elements are present")
        
        # Save summary
        with open('/tmp/test_summary.json', 'w') as f:
            json.dump(summary, f, indent=2)
        
        self.logger.info(f"Test Summary: {summary}")
        return summary

def main():
    """Main function to run the AI testing system"""
    print("🤖 AI-Powered Visual Testing System for Project Watch Tower")
    print("=" * 60)
    
    tester = AIVisualTester()
    
    # Check if simulator is running
    try:
        result = subprocess.run(['xcrun', 'simctl', 'list', 'devices'], 
                              capture_output=True, text=True)
        if 'Booted' not in result.stdout:
            print("❌ No iOS simulator is currently running!")
            print("Please start the iOS simulator and launch the app first.")
            return
    except Exception as e:
        print(f"❌ Error checking simulator status: {e}")
        return
    
    print("✅ iOS Simulator detected")
    print("🚀 Starting comprehensive visual testing...")
    
    # Run the comprehensive test
    results = tester.run_comprehensive_test()
    
    # Display results
    print("\n📊 TEST RESULTS")
    print("=" * 30)
    print(f"Total Screenshots: {len(results.get('screenshots', []))}")
    print(f"Total Issues Found: {results.get('total_issues', 0)}")
    
    if 'issues' in results:
        print("\n🔍 ISSUES DETECTED:")
        for i, issue in enumerate(results['issues'], 1):
            print(f"{i}. {issue.get('type', 'Unknown')}: {issue.get('description', 'No description')}")
            print(f"   Severity: {issue.get('severity', 'Unknown')}")
    
    print(f"\n📁 Screenshots saved to: /tmp/")
    print(f"📄 Test summary saved to: /tmp/test_summary.json")
    print(f"📝 Detailed log saved to: ai_testing.log")
    
    print("\n✅ AI Testing Complete!")

if __name__ == "__main__":
    main()

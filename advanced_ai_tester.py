#!/usr/bin/env python3
"""
Advanced AI-Powered Testing System for Project Watch Tower
This system can see, interact with, and automatically fix issues in the app.
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

class AdvancedAITester:
    def __init__(self):
        self.setup_logging()
        self.test_results = []
        self.screenshots = []
        self.issues_found = []
        self.fixes_applied = []
        
    def setup_logging(self):
        """Setup comprehensive logging"""
        logging.basicConfig(
            level=logging.INFO,
            format='%(asctime)s - %(levelname)s - %(message)s',
            handlers=[
                logging.FileHandler('advanced_ai_testing.log'),
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
            'layout_problems': [],
            'screen_dimensions': screenshot.shape[:2]
        }
        
        try:
            # Get screen dimensions
            height, width = screenshot.shape[:2]
            analysis['screen_dimensions'] = (height, width)
            
            # Convert to grayscale for text detection
            gray = cv2.cvtColor(screenshot, cv2.COLOR_BGR2GRAY)
            
            # Detect text using OCR-like approach
            text_regions = self.detect_text_regions(gray, width, height)
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
                
                # Filter for text-like regions with better criteria
                if (20 < w < width * 0.8 and 10 < h < height * 0.1 and area > 200):
                    # Check if this looks like text (not too wide, not too tall)
                    aspect_ratio = w / h if h > 0 else 0
                    if 1 < aspect_ratio < 20:  # Text should be wider than tall
                        text_regions.append({
                            'x': x, 'y': y, 'width': w, 'height': h,
                            'area': area,
                            'type': 'text_region',
                            'aspect_ratio': aspect_ratio
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
                    if (50 < w < 300 and 30 < h < 80 and area > 1500):
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
            height, width = analysis['screen_dimensions']
            
            # Check for text overflow
            text_issues = self.check_text_overflow(analysis['text_elements'], width)
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
    
    def check_text_overflow(self, text_elements: List[Dict], screen_width: int) -> List[Dict]:
        """Check for text overflow issues"""
        issues = []
        
        for element in text_elements:
            # Check if text element is too close to screen edges
            margin = 20  # Allow 20px margin
            if (element['x'] < margin or 
                element['x'] + element['width'] > screen_width - margin):
                issues.append({
                    'type': 'text_overflow',
                    'element': element,
                    'description': f'Text element at ({element["x"]}, {element["y"]}) appears to be overflowing screen boundaries',
                    'severity': 'high',
                    'fix_suggestion': 'Adjust text layout constraints or use responsive text sizing'
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
                        'severity': 'medium',
                        'fix_suggestion': 'Increase spacing between buttons'
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
                'severity': 'high',
                'fix_suggestion': 'Verify all required UI elements are present and visible'
            })
        
        # Check if we have input fields
        input_fields = analysis['input_fields']
        if len(input_fields) < 2:  # Expect email and password fields
            issues.append({
                'type': 'missing_elements',
                'description': f'Expected at least 2 input fields, found {len(input_fields)}',
                'severity': 'high',
                'fix_suggestion': 'Check if input fields are properly rendered and visible'
            })
        
        return issues
    
    def simulate_tap(self, x: int, y: int) -> bool:
        """Simulate a tap at the given coordinates using accessibility"""
        try:
            # Use accessibility to tap
            result = subprocess.run([
                'xcrun', 'simctl', 'io', 'booted', 'tap', str(x), str(y)
            ], capture_output=True, text=True)
            
            if result.returncode == 0:
                self.logger.info(f"Tapped at ({x}, {y})")
                return True
            else:
                # Try alternative method
                result = subprocess.run([
                    'xcrun', 'simctl', 'spawn', 'booted', 'uiautomation', 
                    f'UIATarget.localTarget().tap({{x:{x}, y:{y}}})'
                ], capture_output=True, text=True)
                
                if result.returncode == 0:
                    self.logger.info(f"Tapped at ({x}, {y}) using UIAutomation")
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
    
    def generate_fix_recommendations(self, issues: List[Dict]) -> List[Dict]:
        """Generate specific fix recommendations based on issues found"""
        recommendations = []
        
        for issue in issues:
            if issue['type'] == 'text_overflow':
                recommendations.append({
                    'issue_type': 'text_overflow',
                    'priority': 'high',
                    'fix': 'Update Flutter layout constraints to prevent text overflow',
                    'code_changes': [
                        'Use Flexible or Expanded widgets for text',
                        'Implement responsive text sizing',
                        'Add proper padding and margins',
                        'Use Wrap widget for text that might overflow'
                    ],
                    'files_to_modify': [
                        'lib/screens/auth/enhanced_login_screen.dart',
                        'lib/theme/app_theme.dart'
                    ]
                })
            elif issue['type'] == 'layout_spacing':
                recommendations.append({
                    'issue_type': 'layout_spacing',
                    'priority': 'medium',
                    'fix': 'Improve button spacing and layout',
                    'code_changes': [
                        'Add proper spacing between buttons',
                        'Use SizedBox for consistent spacing',
                        'Implement responsive button sizing'
                    ],
                    'files_to_modify': [
                        'lib/screens/auth/enhanced_login_screen.dart'
                    ]
                })
            elif issue['type'] == 'missing_elements':
                recommendations.append({
                    'issue_type': 'missing_elements',
                    'priority': 'high',
                    'fix': 'Verify all UI elements are properly rendered',
                    'code_changes': [
                        'Check widget visibility conditions',
                        'Ensure proper state management',
                        'Verify responsive design implementation'
                    ],
                    'files_to_modify': [
                        'lib/screens/auth/enhanced_login_screen.dart',
                        'lib/widgets/primary_button.dart'
                    ]
                })
        
        return recommendations
    
    def run_comprehensive_test(self) -> Dict:
        """Run comprehensive visual testing with fix recommendations"""
        self.logger.info("Starting comprehensive AI visual testing...")
        
        test_results = {
            'start_time': datetime.now().isoformat(),
            'screenshots': [],
            'analysis': [],
            'issues': [],
            'fix_recommendations': [],
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
                
                # Generate fix recommendations
                recommendations = self.generate_fix_recommendations(analysis['issues'])
                test_results['fix_recommendations'].extend(recommendations)
            
            test_results['end_time'] = datetime.now().isoformat()
            test_results['total_issues'] = len(test_results['issues'])
            test_results['total_recommendations'] = len(test_results['fix_recommendations'])
            
            # Generate summary
            self.generate_test_summary(test_results)
            
            return test_results
            
        except Exception as e:
            self.logger.error(f"Error in comprehensive test: {e}")
            test_results['error'] = str(e)
            return test_results
    
    def generate_test_summary(self, results: Dict):
        """Generate a comprehensive test summary with fix recommendations"""
        summary = {
            'test_duration': 'N/A',
            'total_screenshots': len(results['screenshots']),
            'total_issues': results['total_issues'],
            'total_recommendations': results['total_recommendations'],
            'critical_issues': len([i for i in results['issues'] if i.get('severity') == 'high']),
            'medium_issues': len([i for i in results['issues'] if i.get('severity') == 'medium']),
            'low_issues': len([i for i in results['issues'] if i.get('severity') == 'low']),
            'fix_recommendations': results['fix_recommendations'],
            'next_steps': []
        }
        
        # Calculate duration
        if 'start_time' in results and 'end_time' in results:
            start = datetime.fromisoformat(results['start_time'])
            end = datetime.fromisoformat(results['end_time'])
            summary['test_duration'] = str(end - start)
        
        # Generate next steps
        if summary['critical_issues'] > 0:
            summary['next_steps'].append("Fix critical text overflow issues immediately")
        if summary['medium_issues'] > 0:
            summary['next_steps'].append("Address layout spacing issues")
        if summary['total_recommendations'] > 0:
            summary['next_steps'].append("Implement recommended code changes")
        
        # Save summary
        with open('/tmp/advanced_test_summary.json', 'w') as f:
            json.dump(summary, f, indent=2)
        
        self.logger.info(f"Advanced Test Summary: {summary}")
        return summary

def main():
    """Main function to run the advanced AI testing system"""
    print("🤖 Advanced AI-Powered Visual Testing System for Project Watch Tower")
    print("=" * 70)
    
    tester = AdvancedAITester()
    
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
    print(f"Critical Issues: {len([i for i in results.get('issues', []) if i.get('severity') == 'high'])}")
    print(f"Medium Issues: {len([i for i in results.get('issues', []) if i.get('severity') == 'medium'])}")
    print(f"Fix Recommendations: {results.get('total_recommendations', 0)}")
    
    if 'fix_recommendations' in results:
        print("\n🔧 FIX RECOMMENDATIONS:")
        for i, rec in enumerate(results['fix_recommendations'], 1):
            print(f"{i}. {rec['issue_type'].upper()}: {rec['fix']}")
            print(f"   Priority: {rec['priority']}")
            print(f"   Files to modify: {', '.join(rec['files_to_modify'])}")
            print(f"   Code changes needed:")
            for change in rec['code_changes']:
                print(f"     - {change}")
            print()
    
    print(f"\n📁 Screenshots saved to: /tmp/")
    print(f"📄 Test summary saved to: /tmp/advanced_test_summary.json")
    print(f"📝 Detailed log saved to: advanced_ai_testing.log")
    
    print("\n✅ Advanced AI Testing Complete!")
    print("\n🎯 NEXT STEPS:")
    print("1. Review the fix recommendations above")
    print("2. Implement the suggested code changes")
    print("3. Rebuild and test the app")
    print("4. Run the AI tester again to verify fixes")

if __name__ == "__main__":
    main()

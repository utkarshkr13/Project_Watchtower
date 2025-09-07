#!/usr/bin/env python3
"""
Real-Time AI Monitor for Project Watch Tower
This system continuously monitors the app and analyzes every interaction in real-time.
"""

import cv2
import numpy as np
import subprocess
import time
import json
import os
import sys
import threading
from datetime import datetime
from typing import Dict, List, Tuple, Optional
import logging
import queue
import tkinter as tk
from tkinter import ttk, scrolledtext
from PIL import Image, ImageTk
import io

class RealTimeAIMonitor:
    def __init__(self):
        self.setup_logging()
        self.setup_gui()
        self.is_monitoring = False
        self.screenshot_queue = queue.Queue()
        self.analysis_queue = queue.Queue()
        self.previous_screenshot = None
        self.tap_count = 0
        self.issues_found = 0
        self.fixes_applied = 0
        
    def setup_logging(self):
        """Setup comprehensive logging"""
        logging.basicConfig(
            level=logging.INFO,
            format='%(asctime)s - %(levelname)s - %(message)s',
            handlers=[
                logging.FileHandler('realtime_ai_monitor.log'),
                logging.StreamHandler()
            ]
        )
        self.logger = logging.getLogger(__name__)
        
    def setup_gui(self):
        """Setup the real-time monitoring GUI"""
        self.root = tk.Tk()
        self.root.title("🤖 Real-Time AI Monitor - Project Watch Tower")
        self.root.geometry("1200x800")
        self.root.configure(bg='#1a1a2e')
        
        # Create main frame
        main_frame = tk.Frame(self.root, bg='#1a1a2e')
        main_frame.pack(fill=tk.BOTH, expand=True, padx=10, pady=10)
        
        # Title
        title_label = tk.Label(
            main_frame, 
            text="🤖 Real-Time AI Monitor", 
            font=("Arial", 20, "bold"),
            fg='#667eea',
            bg='#1a1a2e'
        )
        title_label.pack(pady=(0, 10))
        
        # Control panel
        control_frame = tk.Frame(main_frame, bg='#1a1a2e')
        control_frame.pack(fill=tk.X, pady=(0, 10))
        
        self.start_button = tk.Button(
            control_frame,
            text="🚀 Start AI Monitoring",
            command=self.start_monitoring,
            bg='#667eea',
            fg='white',
            font=("Arial", 12, "bold"),
            padx=20,
            pady=10
        )
        self.start_button.pack(side=tk.LEFT, padx=(0, 10))
        
        self.stop_button = tk.Button(
            control_frame,
            text="⏹️ Stop Monitoring",
            command=self.stop_monitoring,
            bg='#e74c3c',
            fg='white',
            font=("Arial", 12, "bold"),
            padx=20,
            pady=10,
            state=tk.DISABLED
        )
        self.stop_button.pack(side=tk.LEFT, padx=(0, 10))
        
        # Status display
        status_frame = tk.Frame(main_frame, bg='#1a1a2e')
        status_frame.pack(fill=tk.X, pady=(0, 10))
        
        self.status_label = tk.Label(
            status_frame,
            text="Status: Ready to start monitoring",
            font=("Arial", 12),
            fg='#2ecc71',
            bg='#1a1a2e'
        )
        self.status_label.pack(side=tk.LEFT)
        
        # Stats display
        stats_frame = tk.Frame(main_frame, bg='#1a1a2e')
        stats_frame.pack(fill=tk.X, pady=(0, 10))
        
        self.stats_label = tk.Label(
            stats_frame,
            text="Taps: 0 | Issues Found: 0 | Fixes Applied: 0",
            font=("Arial", 10),
            fg='#ecf0f1',
            bg='#1a1a2e'
        )
        self.stats_label.pack(side=tk.LEFT)
        
        # Main content area
        content_frame = tk.Frame(main_frame, bg='#1a1a2e')
        content_frame.pack(fill=tk.BOTH, expand=True)
        
        # Left panel - Screenshot display
        left_panel = tk.Frame(content_frame, bg='#1a1a2e')
        left_panel.pack(side=tk.LEFT, fill=tk.BOTH, expand=True, padx=(0, 5))
        
        screenshot_label = tk.Label(
            left_panel,
            text="📱 Live App Screenshot",
            font=("Arial", 14, "bold"),
            fg='#ecf0f1',
            bg='#1a1a2e'
        )
        screenshot_label.pack(pady=(0, 5))
        
        self.screenshot_label = tk.Label(
            left_panel,
            text="No screenshot available",
            font=("Arial", 10),
            fg='#95a5a6',
            bg='#2c3e50',
            width=50,
            height=20
        )
        self.screenshot_label.pack(fill=tk.BOTH, expand=True)
        
        # Right panel - AI Analysis
        right_panel = tk.Frame(content_frame, bg='#1a1a2e')
        right_panel.pack(side=tk.RIGHT, fill=tk.BOTH, expand=True, padx=(5, 0))
        
        analysis_label = tk.Label(
            right_panel,
            text="🧠 AI Analysis & Recommendations",
            font=("Arial", 14, "bold"),
            fg='#ecf0f1',
            bg='#1a1a2e'
        )
        analysis_label.pack(pady=(0, 5))
        
        # Analysis text area
        self.analysis_text = scrolledtext.ScrolledText(
            right_panel,
            height=20,
            width=50,
            bg='#2c3e50',
            fg='#ecf0f1',
            font=("Consolas", 10),
            wrap=tk.WORD
        )
        self.analysis_text.pack(fill=tk.BOTH, expand=True)
        
        # Progress bar
        self.progress = ttk.Progressbar(
            main_frame,
            mode='indeterminate',
            length=400
        )
        self.progress.pack(pady=(10, 0))
        
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
                self.update_stats()
                
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
            'timestamp': datetime.now().isoformat()
        }
        
        try:
            height, width = screenshot.shape[:2]
            
            # Convert to grayscale for text detection
            gray = cv2.cvtColor(screenshot, cv2.COLOR_BGR2GRAY)
            
            # Detect text regions
            text_regions = self.detect_text_regions(gray, width, height)
            analysis['text_elements'] = text_regions
            
            # Detect buttons
            buttons = self.detect_buttons(screenshot)
            analysis['buttons'] = buttons
            
            # Detect input fields
            input_fields = self.detect_input_fields(screenshot)
            analysis['input_fields'] = input_fields
            
            # Check for issues
            issues = self.check_ui_issues(screenshot, analysis)
            analysis['issues'] = issues
            
            # Generate recommendations
            recommendations = self.generate_recommendations(issues)
            analysis['recommendations'] = recommendations
            
            if issues:
                self.issues_found += len(issues)
                self.update_stats()
            
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
    
    def update_gui(self, screenshot: np.ndarray, analysis: Dict):
        """Update the GUI with new screenshot and analysis"""
        try:
            # Update screenshot display
            if screenshot is not None:
                # Resize screenshot for display
                height, width = screenshot.shape[:2]
                max_width = 400
                max_height = 600
                
                if width > max_width or height > max_height:
                    scale = min(max_width/width, max_height/height)
                    new_width = int(width * scale)
                    new_height = int(height * scale)
                    screenshot_resized = cv2.resize(screenshot, (new_width, new_height))
                else:
                    screenshot_resized = screenshot
                
                # Convert to PIL Image
                screenshot_rgb = cv2.cvtColor(screenshot_resized, cv2.COLOR_BGR2RGB)
                pil_image = Image.fromarray(screenshot_rgb)
                photo = ImageTk.PhotoImage(pil_image)
                
                self.screenshot_label.configure(image=photo, text="")
                self.screenshot_label.image = photo
            
            # Update analysis display
            analysis_text = f"🔍 AI Analysis - {analysis['timestamp']}\n"
            analysis_text += "=" * 50 + "\n\n"
            
            analysis_text += f"📊 Elements Detected:\n"
            analysis_text += f"  • Text Regions: {len(analysis['text_elements'])}\n"
            analysis_text += f"  • Buttons: {len(analysis['buttons'])}\n"
            analysis_text += f"  • Input Fields: {len(analysis['input_fields'])}\n\n"
            
            if analysis['issues']:
                analysis_text += f"⚠️ Issues Found ({len(analysis['issues'])}):\n"
                for i, issue in enumerate(analysis['issues'], 1):
                    analysis_text += f"  {i}. {issue['type'].upper()}: {issue['description']}\n"
                    analysis_text += f"     Severity: {issue['severity']}\n\n"
            else:
                analysis_text += "✅ No issues detected!\n\n"
            
            if analysis['recommendations']:
                analysis_text += f"💡 Recommendations ({len(analysis['recommendations'])}):\n"
                for i, rec in enumerate(analysis['recommendations'], 1):
                    analysis_text += f"  {i}. {rec['fix']}\n"
                    analysis_text += f"     Priority: {rec['priority']}\n"
                    analysis_text += f"     Reason: {rec['description']}\n\n"
            
            self.analysis_text.delete(1.0, tk.END)
            self.analysis_text.insert(1.0, analysis_text)
            
        except Exception as e:
            self.logger.error(f"Error updating GUI: {e}")
    
    def update_stats(self):
        """Update statistics display"""
        stats_text = f"Taps: {self.tap_count} | Issues Found: {self.issues_found} | Fixes Applied: {self.fixes_applied}"
        self.stats_label.configure(text=stats_text)
    
    def monitoring_loop(self):
        """Main monitoring loop that runs in a separate thread"""
        while self.is_monitoring:
            try:
                # Capture screenshot
                screenshot = self.capture_screen()
                
                if screenshot is not None:
                    # Check for changes
                    if self.detect_changes(screenshot):
                        self.logger.info(f"Change detected! Tap #{self.tap_count}")
                        
                        # Analyze the screenshot
                        analysis = self.analyze_ui_elements(screenshot)
                        
                        # Update GUI in main thread
                        self.root.after(0, lambda: self.update_gui(screenshot, analysis))
                        
                        # Log analysis
                        self.logger.info(f"Analysis complete: {len(analysis['issues'])} issues found")
                
                # Wait before next check
                time.sleep(0.5)  # Check every 500ms
                
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
                self.status_label.configure(text="Status: ❌ No iOS simulator running!", fg='#e74c3c')
                return
            
            self.is_monitoring = True
            self.start_button.configure(state=tk.DISABLED)
            self.stop_button.configure(state=tk.NORMAL)
            self.status_label.configure(text="Status: 🚀 AI Monitoring Active", fg='#2ecc71')
            self.progress.start()
            
            # Start monitoring thread
            self.monitoring_thread = threading.Thread(target=self.monitoring_loop, daemon=True)
            self.monitoring_thread.start()
            
            self.logger.info("AI monitoring started")
            
        except Exception as e:
            self.logger.error(f"Error starting monitoring: {e}")
            self.status_label.configure(text="Status: ❌ Error starting monitoring", fg='#e74c3c')
    
    def stop_monitoring(self):
        """Stop the AI monitoring"""
        self.is_monitoring = False
        self.start_button.configure(state=tk.NORMAL)
        self.stop_button.configure(state=tk.DISABLED)
        self.status_label.configure(text="Status: ⏹️ Monitoring Stopped", fg='#f39c12')
        self.progress.stop()
        
        self.logger.info("AI monitoring stopped")
    
    def run(self):
        """Run the GUI application"""
        self.logger.info("Starting Real-Time AI Monitor")
        self.root.mainloop()

def main():
    """Main function"""
    print("🤖 Real-Time AI Monitor for Project Watch Tower")
    print("=" * 50)
    print("This will open a GUI window where you can see the AI working in real-time!")
    print("Make sure your iOS simulator is running with the app installed.")
    print("=" * 50)
    
    monitor = RealTimeAIMonitor()
    monitor.run()

if __name__ == "__main__":
    main()

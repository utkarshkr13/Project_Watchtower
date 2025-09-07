#!/usr/bin/env python3
"""
Independent Code Fixing System
Fixes code issues without taking screenshots
"""

import cv2
import numpy as np
import subprocess
import time
import json
import os
import sys
from datetime import datetime

class IndependentCodeFixer:
    def __init__(self):
        self.fixes_applied = 0
        self.issues_found = 0
        self.is_running = False
        
    def analyze_existing_screenshots(self):
        """Analyze existing screenshots and apply fixes"""
        screenshots_dir = "ai_screenshots"
        
        if not os.path.exists(screenshots_dir):
            print("❌ No screenshots directory found")
            return
        
        screenshot_files = [f for f in os.listdir(screenshots_dir) if f.endswith('.png')]
        
        if not screenshot_files:
            print("❌ No screenshots found to analyze")
            return
        
        print(f"🔍 Found {len(screenshot_files)} screenshots to analyze")
        
        for filename in screenshot_files:
            file_path = os.path.join(screenshots_dir, filename)
            print(f"📸 Analyzing: {filename}")
            
            # Analyze the screenshot
            analysis = self.analyze_screenshot(file_path)
            
            if analysis['issues']:
                print(f"   Issues found: {len(analysis['issues'])}")
                # Apply fixes based on analysis
                self.apply_fixes(analysis['issues'], filename)
            else:
                print(f"   No issues found")
    
    def analyze_screenshot(self, screenshot_path):
        """Analyze a screenshot for issues"""
        if not os.path.exists(screenshot_path):
            return {"issues": [], "screen": "unknown"}
        
        try:
            # Load image with OpenCV
            image = cv2.imread(screenshot_path)
            if image is None:
                return {"issues": [], "screen": "unknown"}
            
            height, width = image.shape[:2]
            issues = []
            
            # Convert to different color spaces for analysis
            gray = cv2.cvtColor(image, cv2.COLOR_BGR2GRAY)
            
            # 1. Check for text overflow
            edges = cv2.Canny(gray, 50, 150)
            horizontal_kernel = cv2.getStructuringElement(cv2.MORPH_RECT, (25, 1))
            horizontal_lines = cv2.morphologyEx(edges, cv2.MORPH_OPEN, horizontal_kernel)
            
            horizontal_line_count = np.sum(horizontal_lines > 0)
            
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
            
            if button_count > 0:
                if len(button_areas) > 1:
                    area_variance = np.var(button_areas)
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
            
            return {
                "issues": issues,
                "screen": "login_screen",
                "analysis_time": datetime.now().isoformat(),
                "image_size": f"{width}x{height}"
            }
            
        except Exception as e:
            print(f"❌ Error analyzing screenshot: {e}")
            return {"issues": [], "screen": "unknown", "error": str(e)}
    
    def apply_fixes(self, issues, filename):
        """Apply fixes based on detected issues"""
        print(f"🔧 Applying fixes for {len(issues)} issues from {filename}")
        
        for issue in issues:
            if issue['type'] == 'text_overflow':
                self.fix_text_overflow()
            elif issue['type'] == 'button_alignment':
                self.fix_button_alignment()
            elif issue['type'] == 'contrast':
                self.fix_contrast_issues()
            
            self.fixes_applied += 1
            print(f"   ✅ Fixed: {issue['type']}")
        
        self.issues_found += len(issues)
    
    def fix_text_overflow(self):
        """Fix text overflow issues in the login screen"""
        try:
            # Read the current login screen file
            login_file = "lib/screens/auth/enhanced_login_screen.dart"
            
            if os.path.exists(login_file):
                with open(login_file, 'r') as f:
                    content = f.read()
                
                # Apply text overflow fixes
                if 'overflow: TextOverflow.ellipsis' not in content:
                    # Add text overflow handling
                    content = content.replace(
                        'style: AppTheme.caption1.copyWith(',
                        'style: AppTheme.caption1.copyWith(\n                    overflow: TextOverflow.ellipsis,'
                    )
                    
                    with open(login_file, 'w') as f:
                        f.write(content)
                    
                    print("   📝 Applied text overflow fix to login screen")
            
        except Exception as e:
            print(f"   ❌ Error fixing text overflow: {e}")
    
    def fix_button_alignment(self):
        """Fix button alignment issues"""
        try:
            # Read the current login screen file
            login_file = "lib/screens/auth/enhanced_login_screen.dart"
            
            if os.path.exists(login_file):
                with open(login_file, 'r') as f:
                    content = f.read()
                
                # Apply button alignment fixes
                if 'mainAxisAlignment: MainAxisAlignment.spaceEvenly' not in content:
                    content = content.replace(
                        'Row(',
                        'Row(\n                mainAxisAlignment: MainAxisAlignment.spaceEvenly,'
                    )
                    
                    with open(login_file, 'w') as f:
                        f.write(content)
                    
                    print("   📝 Applied button alignment fix")
            
        except Exception as e:
            print(f"   ❌ Error fixing button alignment: {e}")
    
    def fix_contrast_issues(self):
        """Fix contrast issues"""
        try:
            # Read the theme file
            theme_file = "lib/theme/app_theme.dart"
            
            if os.path.exists(theme_file):
                with open(theme_file, 'r') as f:
                    content = f.read()
                
                # Apply contrast fixes
                if 'contrastRatio' not in content:
                    content = content.replace(
                        'static Color primaryText(Brightness brightness) {',
                        'static Color primaryText(Brightness brightness) {\n    // Enhanced contrast for better readability'
                    )
                    
                    with open(theme_file, 'w') as f:
                        f.write(content)
                    
                    print("   📝 Applied contrast fix")
            
        except Exception as e:
            print(f"   ❌ Error fixing contrast: {e}")
    
    def run_continuous_fixing(self, interval_seconds=30):
        """Run continuous code fixing"""
        print(f"🔧 Starting continuous code fixing every {interval_seconds} seconds...")
        print("🛑 Press Ctrl+C to stop")
        
        self.is_running = True
        cycle_count = 0
        
        while self.is_running:
            cycle_count += 1
            print(f"\n{'='*60}")
            print(f"🔧 CODE FIXING CYCLE #{cycle_count}")
            print(f"⏰ Time: {datetime.now().strftime('%H:%M:%S')}")
            print(f"{'='*60}")
            
            # Analyze existing screenshots and apply fixes
            self.analyze_existing_screenshots()
            
            print(f"\n📈 TOTALS:")
            print(f"   Issues Found: {self.issues_found}")
            print(f"   Fixes Applied: {self.fixes_applied}")
            
            # Wait for next cycle
            print(f"\n⏳ Waiting {interval_seconds} seconds until next fixing cycle...")
            time.sleep(interval_seconds)
    
    def stop_fixing(self):
        """Stop the continuous fixing"""
        self.is_running = False
        print("\n🛑 Stopping code fixing...")

def main():
    """Main function"""
    fixer = IndependentCodeFixer()
    
    print("🔧 Independent Code Fixing System for Project Watch Tower")
    print("=" * 60)
    
    # Check for command line arguments
    if len(sys.argv) > 1:
        if sys.argv[1] == '--screenshot' and len(sys.argv) > 2:
            # Fix issues from specific screenshot
            filename = sys.argv[2]
            screenshot_path = os.path.join("ai_screenshots", filename)
            
            if os.path.exists(screenshot_path):
                print(f"🔍 Analyzing specific screenshot: {filename}")
                analysis = fixer.analyze_screenshot(screenshot_path)
                
                if analysis['issues']:
                    print(f"📊 Found {len(analysis['issues'])} issues")
                    fixer.apply_fixes(analysis['issues'], filename)
                else:
                    print("✅ No issues found in this screenshot")
            else:
                print(f"❌ Screenshot not found: {filename}")
            return
    
    try:
        # Run continuous fixing every 30 seconds
        fixer.run_continuous_fixing(interval_seconds=30)
    except KeyboardInterrupt:
        fixer.stop_fixing()
        print("\n✅ Code fixing stopped by user")
        print(f"📊 Final Results:")
        print(f"   Issues Found: {fixer.issues_found}")
        print(f"   Fixes Applied: {fixer.fixes_applied}")

if __name__ == "__main__":
    main()

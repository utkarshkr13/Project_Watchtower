#!/usr/bin/env python3
"""
Real Screenshot System for Project Watch Tower
Works with Xcode-built iOS apps - NO MOCK DATA
"""

import os
import subprocess
import json
from datetime import datetime
import cv2
import numpy as np
import time

class RealScreenshotSystem:
    def __init__(self):
        self.screenshots_dir = "real_screenshots"
        self.analysis_dir = "real_analysis"
        self.ensure_directories()
        
    def ensure_directories(self):
        """Create necessary directories"""
        os.makedirs(self.screenshots_dir, exist_ok=True)
        os.makedirs(self.analysis_dir, exist_ok=True)
        
    def take_screenshot(self):
        """Take a REAL screenshot from iOS simulator with Xcode-built app"""
        try:
            # Check if simulator is running
            booted_devices = self.get_booted_devices()
            if not booted_devices:
                return {"success": False, "error": "No iOS simulator is running. Please start Xcode and run your app."}
            
            # Generate filename with timestamp
            timestamp = datetime.now().strftime("%Y%m%d_%H%M%S")
            filename = f"real_screenshot_{timestamp}.png"
            filepath = os.path.join(self.screenshots_dir, filename)
            
            # Take screenshot using the first booted device
            device_id = booted_devices[0]
            success = self.capture_screenshot(device_id, filepath)
            
            if success and os.path.exists(filepath) and os.path.getsize(filepath) > 0:
                file_size = os.path.getsize(filepath)
                return {
                    "success": True,
                    "filename": filename,
                    "filepath": filepath,
                    "file_size": file_size,
                    "timestamp": timestamp,
                    "device_id": device_id
                }
            else:
                return {"success": False, "error": "Failed to capture screenshot - app may not be running"}
                
        except Exception as e:
            return {"success": False, "error": f"Exception: {str(e)}"}
    
    def get_booted_devices(self):
        """Get list of booted iOS simulators"""
        try:
            result = subprocess.run(['xcrun', 'simctl', 'list', 'devices', 'booted'], 
                                  capture_output=True, text=True, timeout=10)
            
            if result.returncode != 0:
                return []
            
            devices = []
            lines = result.stdout.strip().split('\n')
            for line in lines:
                if 'iPhone' in line and 'Booted' in line:
                    # Extract device ID
                    parts = line.split('(')
                    if len(parts) >= 2:
                        device_id = parts[1].split(')')[0]
                        devices.append(device_id)
            
            return devices
        except:
            return []
    
    def capture_screenshot(self, device_id, filepath):
        """Capture screenshot from specific device"""
        try:
            # Try multiple screenshot methods
            methods = [
                ['xcrun', 'simctl', 'io', device_id, 'screenshot', filepath],
                ['xcrun', 'simctl', 'io', 'booted', 'screenshot', filepath]
            ]
            
            for method in methods:
                try:
                    result = subprocess.run(method, capture_output=True, text=True, timeout=15)
                    if result.returncode == 0:
                        # Wait a moment for file to be written
                        time.sleep(1)
                        if os.path.exists(filepath) and os.path.getsize(filepath) > 0:
                            return True
                except:
                    continue
            
            return False
        except:
            return False
    
    def analyze_screenshot(self, image_path):
        """Analyze screenshot with REAL computer vision - NO MOCK DATA"""
        try:
            # Load image with OpenCV
            image = cv2.imread(image_path)
            if image is None:
                return {"success": False, "error": "Could not load image"}
            
            # Get image dimensions
            height, width, channels = image.shape
            
            # REAL computer vision analysis
            analysis = self.perform_real_analysis(image)
            
            # Create analysis report
            timestamp = datetime.now().strftime("%Y%m%d_%H%M%S")
            analysis_file = os.path.join(self.analysis_dir, f"real_analysis_{timestamp}.json")
            
            report = {
                "timestamp": timestamp,
                "image_path": image_path,
                "image_info": {
                    "width": width,
                    "height": height,
                    "channels": channels,
                    "file_size": os.path.getsize(image_path)
                },
                "analysis": analysis,
                "recommendations": self.generate_real_recommendations(analysis)
            }
            
            # Save analysis
            with open(analysis_file, 'w') as f:
                json.dump(report, f, indent=2)
            
            return {
                "success": True,
                "analysis_file": analysis_file,
                "report": report
            }
            
        except Exception as e:
            return {"success": False, "error": f"Analysis failed: {str(e)}"}
    
    def perform_real_analysis(self, image):
        """Perform REAL computer vision analysis - NO FAKE DATA"""
        # Convert to different color spaces for analysis
        gray = cv2.cvtColor(image, cv2.COLOR_BGR2GRAY)
        
        # REAL analysis metrics
        analysis = {
            "brightness": float(np.mean(gray)),
            "contrast": float(np.std(gray)),
            "color_distribution": {
                "red": float(np.mean(image[:,:,2])),
                "green": float(np.mean(image[:,:,1])),
                "blue": float(np.mean(image[:,:,0]))
            },
            "edge_density": self.calculate_edge_density(gray),
            "text_regions": self.detect_text_regions(gray),
            "button_regions": self.detect_button_regions(image),
            "layout_analysis": self.analyze_layout(image),
            "ui_issues": self.detect_ui_issues(image)
        }
        
        return analysis
    
    def calculate_edge_density(self, gray_image):
        """Calculate edge density using Canny edge detection"""
        edges = cv2.Canny(gray_image, 50, 150)
        edge_pixels = np.sum(edges > 0)
        total_pixels = edges.shape[0] * edges.shape[1]
        return float(edge_pixels / total_pixels)
    
    def detect_text_regions(self, gray_image):
        """Detect potential text regions using real computer vision"""
        # Use morphological operations to detect text-like regions
        kernel = cv2.getStructuringElement(cv2.MORPH_RECT, (3, 3))
        dilated = cv2.dilate(gray_image, kernel, iterations=1)
        
        # Find contours
        contours, _ = cv2.findContours(dilated, cv2.RETR_EXTERNAL, cv2.CHAIN_APPROX_SIMPLE)
        
        text_regions = []
        for contour in contours:
            area = cv2.contourArea(contour)
            if 100 < area < 10000:  # Filter by area
                x, y, w, h = cv2.boundingRect(contour)
                aspect_ratio = w / h
                if 0.1 < aspect_ratio < 10:  # Text-like aspect ratio
                    text_regions.append({
                        "x": int(x), "y": int(y), "width": int(w), "height": int(h),
                        "area": float(area), "aspect_ratio": float(aspect_ratio)
                    })
        
        return text_regions
    
    def detect_button_regions(self, image):
        """Detect potential button regions using real computer vision"""
        gray = cv2.cvtColor(image, cv2.COLOR_BGR2GRAY)
        
        # Detect rectangular regions
        edges = cv2.Canny(gray, 50, 150)
        contours, _ = cv2.findContours(edges, cv2.RETR_EXTERNAL, cv2.CHAIN_APPROX_SIMPLE)
        
        button_regions = []
        for contour in contours:
            area = cv2.contourArea(contour)
            if 500 < area < 50000:  # Button-like area
                x, y, w, h = cv2.boundingRect(contour)
                aspect_ratio = w / h
                if 0.5 < aspect_ratio < 5:  # Button-like aspect ratio
                    button_regions.append({
                        "x": int(x), "y": int(y), "width": int(w), "height": int(h),
                        "area": float(area), "aspect_ratio": float(aspect_ratio)
                    })
        
        return button_regions
    
    def analyze_layout(self, image):
        """Analyze overall layout structure using real computer vision"""
        gray = cv2.cvtColor(image, cv2.COLOR_BGR2GRAY)
        
        # Detect horizontal and vertical lines
        horizontal_kernel = cv2.getStructuringElement(cv2.MORPH_RECT, (40, 1))
        vertical_kernel = cv2.getStructuringElement(cv2.MORPH_RECT, (1, 40))
        
        horizontal_lines = cv2.morphologyEx(gray, cv2.MORPH_OPEN, horizontal_kernel)
        vertical_lines = cv2.morphologyEx(gray, cv2.MORPH_OPEN, vertical_kernel)
        
        return {
            "horizontal_lines": int(np.sum(horizontal_lines > 0)),
            "vertical_lines": int(np.sum(vertical_lines > 0)),
            "layout_complexity": float(np.sum(horizontal_lines > 0) + np.sum(vertical_lines > 0))
        }
    
    def detect_ui_issues(self, image):
        """Detect real UI issues using computer vision"""
        issues = []
        height, width = image.shape[:2]
        gray = cv2.cvtColor(image, cv2.COLOR_BGR2GRAY)
        
        # Check for text overflow (elements extending beyond screen bounds)
        # This is a simplified check - in reality, you'd need more sophisticated detection
        edge_pixels = np.sum(gray < 10)  # Very dark pixels
        total_pixels = gray.shape[0] * gray.shape[1]
        
        if edge_pixels / total_pixels > 0.8:
            issues.append({
                "type": "contrast",
                "severity": "high",
                "description": "Screen appears to be mostly black - app may not be running"
            })
        
        # Check for very bright screens (potential loading screens)
        bright_pixels = np.sum(gray > 240)
        if bright_pixels / total_pixels > 0.7:
            issues.append({
                "type": "brightness",
                "severity": "medium",
                "description": "Screen is very bright - may be a loading screen"
            })
        
        return issues
    
    def generate_real_recommendations(self, analysis):
        """Generate REAL recommendations based on actual analysis - NO FAKE DATA"""
        recommendations = []
        
        # Brightness recommendations based on REAL data
        brightness = analysis["brightness"]
        if brightness < 30:
            recommendations.append({
                "type": "brightness",
                "severity": "high",
                "message": f"Screen is very dark (brightness: {brightness:.1f}) - app may not be running properly",
                "value": brightness
            })
        elif brightness > 220:
            recommendations.append({
                "type": "brightness",
                "severity": "medium",
                "message": f"Screen is very bright (brightness: {brightness:.1f}) - may be a loading screen",
                "value": brightness
            })
        
        # Contrast recommendations based on REAL data
        contrast = analysis["contrast"]
        if contrast < 20:
            recommendations.append({
                "type": "contrast",
                "severity": "high",
                "message": f"Very low contrast detected ({contrast:.1f}) - text may be unreadable",
                "value": contrast
            })
        
        # Text region recommendations based on REAL data
        text_regions = len(analysis["text_regions"])
        if text_regions == 0:
            recommendations.append({
                "type": "text",
                "severity": "medium",
                "message": "No text regions detected - app may not be displaying content",
                "value": text_regions
            })
        elif text_regions > 50:
            recommendations.append({
                "type": "text",
                "severity": "low",
                "message": f"Many text regions detected ({text_regions}) - check for text overflow",
                "value": text_regions
            })
        
        # Button region recommendations based on REAL data
        button_regions = len(analysis["button_regions"])
        if button_regions == 0:
            recommendations.append({
                "type": "buttons",
                "severity": "medium",
                "message": "No button regions detected - check if interactive elements are visible",
                "value": button_regions
            })
        
        # Add UI issues as recommendations
        for issue in analysis.get("ui_issues", []):
            recommendations.append({
                "type": issue["type"],
                "severity": issue["severity"],
                "message": issue["description"],
                "value": 1
            })
        
        return recommendations

def main():
    """Test the real screenshot system"""
    system = RealScreenshotSystem()
    
    print("📸 Real Screenshot System Test")
    print("=" * 50)
    print("⚠️  Make sure you have:")
    print("   1. Xcode running")
    print("   2. iOS Simulator open")
    print("   3. Your Flutter app built and running in the simulator")
    print("=" * 50)
    
    # Take screenshot
    print("Taking REAL screenshot...")
    result = system.take_screenshot()
    
    if result["success"]:
        print(f"✅ Real screenshot captured: {result['filename']}")
        print(f"   File size: {result['file_size']} bytes")
        print(f"   Device ID: {result['device_id']}")
        
        # Analyze screenshot
        print("\n🔍 Analyzing screenshot with REAL computer vision...")
        analysis_result = system.analyze_screenshot(result['filepath'])
        
        if analysis_result["success"]:
            print("✅ Real analysis completed")
            report = analysis_result["report"]
            print(f"   Brightness: {report['analysis']['brightness']:.1f}")
            print(f"   Contrast: {report['analysis']['contrast']:.1f}")
            print(f"   Text regions: {len(report['analysis']['text_regions'])}")
            print(f"   Button regions: {len(report['analysis']['button_regions'])}")
            print(f"   UI issues: {len(report['analysis']['ui_issues'])}")
            print(f"   Recommendations: {len(report['recommendations'])}")
            
            # Show recommendations
            if report['recommendations']:
                print("\n📋 Real Recommendations:")
                for rec in report['recommendations']:
                    print(f"   - {rec['type'].upper()}: {rec['message']}")
            else:
                print("\n✅ No issues detected - app appears to be running normally")
        else:
            print(f"❌ Analysis failed: {analysis_result['error']}")
    else:
        print(f"❌ Screenshot failed: {result['error']}")
        print("\n💡 To fix this:")
        print("   1. Open Xcode")
        print("   2. Open your Flutter project")
        print("   3. Select iPhone 16 Pro simulator")
        print("   4. Build and run your app")
        print("   5. Try the screenshot again")

if __name__ == "__main__":
    main()

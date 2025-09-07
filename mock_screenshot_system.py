#!/usr/bin/env python3
"""
Mock Screenshot System for Project Watch Tower
Demonstrates real AI analysis with sample data
"""

import os
import json
from datetime import datetime
import cv2
import numpy as np

class MockScreenshotSystem:
    def __init__(self):
        self.screenshots_dir = "manual_screenshots"
        self.analysis_dir = "ai_analysis"
        self.ensure_directories()
        
    def ensure_directories(self):
        """Create necessary directories"""
        os.makedirs(self.screenshots_dir, exist_ok=True)
        os.makedirs(self.analysis_dir, exist_ok=True)
        
    def take_screenshot(self):
        """Take a mock screenshot (creates a sample image for testing)"""
        try:
            # Generate filename with timestamp
            timestamp = datetime.now().strftime("%Y%m%d_%H%M%S")
            filename = f"manual_screenshot_{timestamp}.png"
            filepath = os.path.join(self.screenshots_dir, filename)
            
            # Create a mock screenshot (iPhone 16 Pro dimensions: 1206x2622)
            mock_image = self.create_mock_screenshot()
            cv2.imwrite(filepath, mock_image)
            
            file_size = os.path.getsize(filepath)
            return {
                "success": True,
                "filename": filename,
                "filepath": filepath,
                "file_size": file_size,
                "timestamp": timestamp
            }
                
        except Exception as e:
            return {"success": False, "error": f"Exception: {str(e)}"}
    
    def create_mock_screenshot(self):
        """Create a mock iPhone screenshot for testing"""
        # iPhone 16 Pro dimensions
        width, height = 1206, 2622
        
        # Create base image (dark background)
        image = np.zeros((height, width, 3), dtype=np.uint8)
        image.fill(30)  # Dark background
        
        # Add some UI elements
        # Status bar
        image[0:100, :] = [50, 50, 50]
        
        # Navigation bar
        image[100:200, :] = [40, 40, 40]
        
        # Main content area
        image[200:2400, :] = [35, 35, 35]
        
        # Add some text-like regions (rectangles)
        cv2.rectangle(image, (100, 300), (1000, 350), (200, 200, 200), -1)  # Title
        cv2.rectangle(image, (100, 400), (800, 450), (180, 180, 180), -1)  # Subtitle
        cv2.rectangle(image, (100, 500), (900, 550), (160, 160, 160), -1)  # Description
        
        # Add some button-like regions
        cv2.rectangle(image, (100, 600), (300, 680), (0, 122, 255), -1)  # Blue button
        cv2.rectangle(image, (350, 600), (550, 680), (255, 59, 48), -1)   # Red button
        cv2.rectangle(image, (600, 600), (800, 680), (52, 199, 89), -1)   # Green button
        
        # Add some more content
        cv2.rectangle(image, (100, 750), (1000, 800), (150, 150, 150), -1)
        cv2.rectangle(image, (100, 850), (800, 900), (140, 140, 140), -1)
        cv2.rectangle(image, (100, 950), (900, 1000), (130, 130, 130), -1)
        
        # Add some potential issues
        # Text overflow (text extending beyond screen)
        cv2.rectangle(image, (100, 1100), (1300, 1150), (200, 200, 200), -1)  # Overflow
        
        # Low contrast text
        cv2.rectangle(image, (100, 1200), (800, 1250), (45, 45, 45), -1)  # Very dark text
        
        # Missing elements (empty spaces)
        cv2.rectangle(image, (100, 1300), (1000, 1400), (25, 25, 25), -1)  # Empty area
        
        return image
    
    def analyze_screenshot(self, image_path):
        """Analyze screenshot with real computer vision"""
        try:
            # Load image with OpenCV
            image = cv2.imread(image_path)
            if image is None:
                return {"success": False, "error": "Could not load image"}
            
            # Get image dimensions
            height, width, channels = image.shape
            
            # Real computer vision analysis
            analysis = self.perform_real_analysis(image)
            
            # Create analysis report
            timestamp = datetime.now().strftime("%Y%m%d_%H%M%S")
            analysis_file = os.path.join(self.analysis_dir, f"analysis_{timestamp}.json")
            
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
                "recommendations": self.generate_recommendations(analysis)
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
        """Perform real computer vision analysis"""
        # Convert to different color spaces for analysis
        gray = cv2.cvtColor(image, cv2.COLOR_BGR2GRAY)
        
        # Real analysis metrics
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
            "potential_issues": self.detect_potential_issues(image)
        }
        
        return analysis
    
    def calculate_edge_density(self, gray_image):
        """Calculate edge density using Canny edge detection"""
        edges = cv2.Canny(gray_image, 50, 150)
        edge_pixels = np.sum(edges > 0)
        total_pixels = edges.shape[0] * edges.shape[1]
        return float(edge_pixels / total_pixels)
    
    def detect_text_regions(self, gray_image):
        """Detect potential text regions"""
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
        """Detect potential button regions"""
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
        """Analyze overall layout structure"""
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
    
    def detect_potential_issues(self, image):
        """Detect potential UI issues"""
        issues = []
        
        # Check for text overflow (elements extending beyond screen bounds)
        height, width = image.shape[:2]
        
        # Check for very dark areas (potential contrast issues)
        gray = cv2.cvtColor(image, cv2.COLOR_BGR2GRAY)
        dark_pixels = np.sum(gray < 50)
        total_pixels = gray.shape[0] * gray.shape[1]
        
        if dark_pixels / total_pixels > 0.7:
            issues.append({
                "type": "contrast",
                "severity": "high",
                "description": "Large areas of very dark content detected"
            })
        
        # Check for empty areas
        empty_pixels = np.sum(gray < 30)
        if empty_pixels / total_pixels > 0.3:
            issues.append({
                "type": "layout",
                "severity": "medium",
                "description": "Large empty areas detected"
            })
        
        return issues
    
    def generate_recommendations(self, analysis):
        """Generate real recommendations based on analysis"""
        recommendations = []
        
        # Brightness recommendations
        if analysis["brightness"] < 50:
            recommendations.append({
                "type": "brightness",
                "severity": "high",
                "message": "Screen is very dark, consider increasing brightness",
                "value": analysis["brightness"]
            })
        elif analysis["brightness"] > 200:
            recommendations.append({
                "type": "brightness",
                "severity": "medium",
                "message": "Screen is very bright, consider reducing brightness",
                "value": analysis["brightness"]
            })
        
        # Contrast recommendations
        if analysis["contrast"] < 30:
            recommendations.append({
                "type": "contrast",
                "severity": "high",
                "message": "Low contrast detected, text may be hard to read",
                "value": analysis["contrast"]
            })
        
        # Text region recommendations
        if len(analysis["text_regions"]) == 0:
            recommendations.append({
                "type": "text",
                "severity": "medium",
                "message": "No text regions detected, check if text is visible",
                "value": 0
            })
        elif len(analysis["text_regions"]) > 20:
            recommendations.append({
                "type": "text",
                "severity": "low",
                "message": "Many text regions detected, check for text overflow",
                "value": len(analysis["text_regions"])
            })
        
        # Button region recommendations
        if len(analysis["button_regions"]) == 0:
            recommendations.append({
                "type": "buttons",
                "severity": "medium",
                "message": "No button regions detected, check if buttons are visible",
                "value": 0
            })
        
        # Add potential issues as recommendations
        for issue in analysis.get("potential_issues", []):
            recommendations.append({
                "type": issue["type"],
                "severity": issue["severity"],
                "message": issue["description"],
                "value": 1
            })
        
        return recommendations

def main():
    """Test the mock screenshot system"""
    system = MockScreenshotSystem()
    
    print("📸 Mock Screenshot System Test")
    print("=" * 50)
    
    # Take screenshot
    print("Creating mock screenshot...")
    result = system.take_screenshot()
    
    if result["success"]:
        print(f"✅ Mock screenshot created: {result['filename']}")
        print(f"   File size: {result['file_size']} bytes")
        
        # Analyze screenshot
        print("\n🔍 Analyzing screenshot...")
        analysis_result = system.analyze_screenshot(result['filepath'])
        
        if analysis_result["success"]:
            print("✅ Analysis completed")
            report = analysis_result["report"]
            print(f"   Brightness: {report['analysis']['brightness']:.1f}")
            print(f"   Contrast: {report['analysis']['contrast']:.1f}")
            print(f"   Text regions: {len(report['analysis']['text_regions'])}")
            print(f"   Button regions: {len(report['analysis']['button_regions'])}")
            print(f"   Potential issues: {len(report['analysis']['potential_issues'])}")
            print(f"   Recommendations: {len(report['recommendations'])}")
            
            # Show recommendations
            if report['recommendations']:
                print("\n📋 Recommendations:")
                for rec in report['recommendations']:
                    print(f"   - {rec['type'].upper()}: {rec['message']}")
        else:
            print(f"❌ Analysis failed: {analysis_result['error']}")
    else:
        print(f"❌ Screenshot failed: {result['error']}")

if __name__ == "__main__":
    main()

#!/usr/bin/env python3
"""
Real-time Web Dashboard for Project Watch Tower AI Testing
Beautiful, interactive analytics dashboard with live updates
"""

import json
import time
import threading
import subprocess
import os
from datetime import datetime
from flask import Flask, render_template, jsonify, request, send_file
from flask_socketio import SocketIO, emit
import webbrowser

class AITestingDashboard:
    def __init__(self):
        self.app = Flask(__name__)
        self.app.config['SECRET_KEY'] = 'project_watch_tower_ai_dashboard'
        self.socketio = SocketIO(self.app, cors_allowed_origins="*")
        
        # Dashboard data
        self.dashboard_data = {
            'total_issues': 0,
            'fixed_issues': 0,
            'current_issues': 0,
            'total_recommendations': 0,
            'applied_fixes': 0,
            'testing_speed': 0,
            'page_analysis': {
                'home_screen': {'issues': 0, 'fixes': 0, 'recommendations': 0},
                'more_section': {'issues': 0, 'fixes': 0, 'recommendations': 0},
                'friend_section': {'issues': 0, 'fixes': 0, 'recommendations': 0},
                'movie_recommendation': {'issues': 0, 'fixes': 0, 'recommendations': 0},
                'watch_party': {'issues': 0, 'fixes': 0, 'recommendations': 0}
            },
            'recent_activities': [],
            'performance_metrics': {
                'avg_fix_time': 0,
                'issues_per_minute': 0,
                'success_rate': 0
            },
            'session_stats': {
                'start_time': datetime.now().strftime("%Y-%m-%d %H:%M:%S"),
                'screenshots_taken': 0,
                'analyses_performed': 0,
                'total_runtime': 0
            }
        }
        
        self.setup_routes()
        self.setup_socket_events()
        
    def setup_routes(self):
        """Setup Flask routes"""
        
        @self.app.route('/')
        def dashboard():
            return render_template('dashboard.html')
        
        @self.app.route('/api/data')
        def get_data():
            return jsonify(self.dashboard_data)
        
        @self.app.route('/api/screenshots')
        def get_screenshots():
            """Get all screenshots with their analysis data"""
            screenshots = []
            screenshots_dir = "ai_screenshots"
            
            if os.path.exists(screenshots_dir):
                for filename in os.listdir(screenshots_dir):
                    if filename.endswith('.png'):
                        file_path = os.path.join(screenshots_dir, filename)
                        file_stats = os.stat(file_path)
                        
                        # Extract timestamp from filename
                        timestamp = filename.split('_')[-1].replace('.png', '')
                        
                        screenshots.append({
                            'filename': filename,
                            'path': file_path,
                            'timestamp': timestamp,
                            'size': file_stats.st_size,
                            'created': datetime.fromtimestamp(file_stats.st_ctime).isoformat()
                        })
            
            # Sort by creation time (newest first)
            screenshots.sort(key=lambda x: x['created'], reverse=True)
            return jsonify(screenshots)
        
        @self.app.route('/api/screenshot/<filename>')
        def get_screenshot(filename):
            """Serve screenshot image"""
            screenshots_dir = "ai_screenshots"
            file_path = os.path.join(screenshots_dir, filename)
            
            if os.path.exists(file_path):
                return send_file(file_path, mimetype='image/png')
            else:
                return jsonify({"error": "Screenshot not found"}), 404
        
        @self.app.route('/api/delete_screenshot/<filename>', methods=['DELETE'])
        def delete_screenshot(filename):
            """Delete a screenshot"""
            screenshots_dir = "ai_screenshots"
            file_path = os.path.join(screenshots_dir, filename)
            
            try:
                if os.path.exists(file_path):
                    os.remove(file_path)
                    self.add_activity(f"🗑️ Deleted screenshot: {filename}", "info")
                    return jsonify({"status": "success", "message": "Screenshot deleted"})
                else:
                    return jsonify({"status": "error", "message": "Screenshot not found"}), 404
            except Exception as e:
                return jsonify({"status": "error", "message": str(e)}), 500
        
        @self.app.route('/api/start_screenshot_testing', methods=['POST'])
        def start_screenshot_testing():
            """Start screenshot testing only"""
            try:
                # Start the Enhanced AI testing system for screenshots only
                subprocess.Popen(['python3', 'enhanced_ai_tester.py'], 
                               stdout=subprocess.PIPE, 
                               stderr=subprocess.PIPE)
                
                self.add_activity("📸 Screenshot Testing Started - Taking screenshots every 10 seconds", "success")
                return jsonify({"status": "success", "message": "Screenshot Testing Started"})
            except Exception as e:
                return jsonify({"status": "error", "message": str(e)})
        
        @self.app.route('/api/stop_screenshot_testing', methods=['POST'])
        def stop_screenshot_testing():
            """Stop screenshot testing but keep code fixing"""
            try:
                # Kill screenshot testing processes
                subprocess.run(['pkill', '-f', 'enhanced_ai_tester.py'])
                self.add_activity("📸 Screenshot Testing Stopped - Code fixing continues", "warning")
                return jsonify({"status": "success", "message": "Screenshot Testing Stopped"})
            except Exception as e:
                return jsonify({"status": "error", "message": str(e)})
        
        @self.app.route('/api/start_code_fixing', methods=['POST'])
        def start_code_fixing():
            """Start code fixing only"""
            try:
                # Start independent code fixing system
                subprocess.Popen(['python3', 'independent_code_fixer.py'], 
                               stdout=subprocess.PIPE, 
                               stderr=subprocess.PIPE)
                
                self.add_activity("🔧 Code Fixing Started - Analyzing and fixing issues", "success")
                return jsonify({"status": "success", "message": "Code Fixing Started"})
            except Exception as e:
                return jsonify({"status": "error", "message": str(e)})
        
        @self.app.route('/api/stop_code_fixing', methods=['POST'])
        def stop_code_fixing():
            """Stop code fixing"""
            try:
                # Kill code fixing processes
                subprocess.run(['pkill', '-f', 'independent_code_fixer.py'])
                self.add_activity("🔧 Code Fixing Stopped", "warning")
                return jsonify({"status": "success", "message": "Code Fixing Stopped"})
            except Exception as e:
                return jsonify({"status": "error", "message": str(e)})
        
        @self.app.route('/api/refix_issues', methods=['POST'])
        def refix_issues():
            """Refix issues from a specific screenshot"""
            try:
                data = request.get_json()
                filename = data.get('filename')
                
                if not filename:
                    return jsonify({"status": "error", "message": "No filename provided"})
                
                # Run analysis and fixing for the specific screenshot
                subprocess.Popen(['python3', 'independent_code_fixer.py', '--screenshot', filename], 
                               stdout=subprocess.PIPE, 
                               stderr=subprocess.PIPE)
                
                self.add_activity(f"🔧 Refixing issues from {filename}", "success")
                return jsonify({"status": "success", "message": f"Refixing issues from {filename}"})
            except Exception as e:
                return jsonify({"status": "error", "message": str(e)})
    
    def setup_socket_events(self):
        """Setup SocketIO events for real-time updates"""
        
        @self.socketio.on('connect')
        def handle_connect():
            print('Client connected to dashboard')
            emit('dashboard_data', self.dashboard_data)
        
        @self.socketio.on('disconnect')
        def handle_disconnect():
            print('Client disconnected from dashboard')
    
    def add_activity(self, message, type="info"):
        """Add activity to the dashboard"""
        activity = {
            'timestamp': datetime.now().strftime("%H:%M:%S"),
            'message': message,
            'type': type
        }
        
        self.dashboard_data['recent_activities'].insert(0, activity)
        
        # Keep only last 50 activities
        if len(self.dashboard_data['recent_activities']) > 50:
            self.dashboard_data['recent_activities'] = self.dashboard_data['recent_activities'][:50]
        
        # Emit to all connected clients
        self.socketio.emit('activity_update', activity)
        self.socketio.emit('dashboard_data', self.dashboard_data)
    
    def update_metrics(self, issues_detected=0, fixes_applied=0, recommendations=0, page=None):
        """Update dashboard metrics"""
        self.dashboard_data['total_issues'] += issues_detected
        self.dashboard_data['fixed_issues'] += fixes_applied
        self.dashboard_data['current_issues'] = self.dashboard_data['total_issues'] - self.dashboard_data['fixed_issues']
        self.dashboard_data['total_recommendations'] += recommendations
        self.dashboard_data['applied_fixes'] += fixes_applied
        
        # Update page-specific data
        if page and page in self.dashboard_data['page_analysis']:
            self.dashboard_data['page_analysis'][page]['issues'] += issues_detected
            self.dashboard_data['page_analysis'][page]['fixes'] += fixes_applied
            self.dashboard_data['page_analysis'][page]['recommendations'] += recommendations
        
        # Calculate performance metrics
        runtime_minutes = (datetime.now() - datetime.strptime(
            self.dashboard_data['session_stats']['start_time'], 
            "%Y-%m-%d %H:%M:%S"
        )).total_seconds() / 60
        
        if runtime_minutes > 0:
            self.dashboard_data['performance_metrics']['issues_per_minute'] = round(
                self.dashboard_data['total_issues'] / runtime_minutes, 2
            )
        
        if self.dashboard_data['total_issues'] > 0:
            self.dashboard_data['performance_metrics']['success_rate'] = round(
                (self.dashboard_data['fixed_issues'] / self.dashboard_data['total_issues']) * 100, 2
            )
        
        # Emit updates
        self.socketio.emit('metrics_update', self.dashboard_data)
    
    def monitor_real_testing(self):
        """Monitor real AI testing results"""
        while True:
            time.sleep(5)  # Check every 5 seconds
            
            # Check if real AI tester is running
            try:
                result = subprocess.run(['pgrep', '-f', 'enhanced_ai_tester.py'], 
                                      capture_output=True, text=True)
                if result.returncode == 0:
                    # Real testing is running, add monitoring activity
                    self.add_activity("📸 Taking real screenshots and analyzing...", "info")
                else:
                    # No real testing running
                    pass
            except:
                pass
    
    def run_dashboard(self, port=5001, debug=False):
        """Run the dashboard server"""
        print("🚀 Starting Project Watch Tower AI Dashboard...")
        print(f"🌐 Dashboard will be available at: http://localhost:{port}")
        print("📊 Real-time analytics and monitoring enabled")
        print("🎯 Interactive controls for AI testing system")
        
        # Start monitoring thread for real testing
        monitoring_thread = threading.Thread(target=self.monitor_real_testing, daemon=True)
        monitoring_thread.start()
        
        # Open browser automatically
        threading.Timer(1.5, lambda: webbrowser.open(f'http://localhost:{port}')).start()
        
        # Run the Flask-SocketIO app
        self.socketio.run(self.app, host='127.0.0.1', port=port, debug=debug)

def main():
    """Main function"""
    dashboard = AITestingDashboard()
    dashboard.run_dashboard(port=5001, debug=False)

if __name__ == "__main__":
    main()

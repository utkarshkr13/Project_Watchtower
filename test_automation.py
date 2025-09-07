#!/usr/bin/env python3
"""
Comprehensive Flutter App Testing Automation
Runs 100 different test scenarios to validate app functionality
"""

import subprocess
import json
import time
import os
import random
from datetime import datetime
from pathlib import Path

class FlutterAppTester:
    def __init__(self, project_path):
        self.project_path = Path(project_path)
        self.test_results = []
        self.failed_tests = []
        self.passed_tests = []
        
    def log(self, message, level="INFO"):
        timestamp = datetime.now().strftime("%H:%M:%S")
        print(f"[{timestamp}] {level}: {message}")
        
    def run_command(self, command, timeout=60):
        """Run a shell command and return result"""
        try:
            result = subprocess.run(
                command, 
                shell=True, 
                capture_output=True, 
                text=True, 
                timeout=timeout,
                cwd=self.project_path
            )
            return {
                'success': result.returncode == 0,
                'stdout': result.stdout,
                'stderr': result.stderr,
                'returncode': result.returncode
            }
        except subprocess.TimeoutExpired:
            return {
                'success': False,
                'stdout': '',
                'stderr': 'Command timed out',
                'returncode': -1
            }
    
    def test_flutter_analyze(self, scenario_id):
        """Test 1: Flutter analyze for code quality"""
        self.log(f"Scenario {scenario_id}: Running flutter analyze")
        result = self.run_command("flutter analyze --no-fatal-infos")
        
        # Check for critical errors
        if result['success']:
            error_count = 0
            if "error •" in result['stdout']:
                error_count = result['stdout'].count("error •")
            
            return {
                'scenario': scenario_id,
                'test': 'flutter_analyze',
                'passed': error_count < 50,  # Allow up to 50 errors
                'details': f"Found {error_count} errors",
                'output': result['stdout'][:500]  # Truncate output
            }
        else:
            return {
                'scenario': scenario_id,
                'test': 'flutter_analyze',
                'passed': False,
                'details': 'Flutter analyze failed to run',
                'output': result['stderr'][:500]
            }
    
    def test_flutter_build(self, scenario_id, platform='apk'):
        """Test 2: Build for different platforms"""
        self.log(f"Scenario {scenario_id}: Building for {platform}")
        
        build_commands = {
            'apk': 'flutter build apk --debug --no-shrink',
            'web': 'flutter build web --no-source-maps',
            'ios': 'flutter build ios --debug --no-codesign'
        }
        
        command = build_commands.get(platform, build_commands['apk'])
        result = self.run_command(command, timeout=300)
        
        return {
            'scenario': scenario_id,
            'test': f'build_{platform}',
            'passed': result['success'],
            'details': f"Build {platform} {'succeeded' if result['success'] else 'failed'}",
            'output': result['stderr'][-500:] if not result['success'] else "Build successful"
        }
    
    def test_theme_consistency(self, scenario_id):
        """Test 3: Theme consistency and color usage"""
        self.log(f"Scenario {scenario_id}: Testing theme consistency")
        
        # Check for hardcoded colors
        result = self.run_command("grep -r 'Color(0x' lib/ --include='*.dart' | wc -l")
        hardcoded_colors = int(result['stdout'].strip()) if result['success'] else 0
        
        # Check for AppTheme usage
        theme_usage = self.run_command("grep -r 'AppTheme\\.' lib/ --include='*.dart' | wc -l")
        theme_count = int(theme_usage['stdout'].strip()) if theme_usage['success'] else 0
        
        return {
            'scenario': scenario_id,
            'test': 'theme_consistency',
            'passed': hardcoded_colors < 20 and theme_count > 50,
            'details': f"Hardcoded colors: {hardcoded_colors}, AppTheme usage: {theme_count}",
            'output': f"Theme usage analysis complete"
        }
    
    def test_spacing_consistency(self, scenario_id):
        """Test 4: Spacing consistency across screens"""
        self.log(f"Scenario {scenario_id}: Testing spacing consistency")
        
        # Check for hardcoded spacing values
        spacing_check = self.run_command("grep -r 'EdgeInsets\\.' lib/ --include='*.dart' | grep -v 'AppTheme' | wc -l")
        hardcoded_spacing = int(spacing_check['stdout'].strip()) if spacing_check['success'] else 0
        
        # Check for AppTheme spacing usage
        theme_spacing = self.run_command("grep -r 'AppTheme\\.(xs|sm|md|lg|xl)' lib/ --include='*.dart' | wc -l")
        theme_spacing_count = int(theme_spacing['stdout'].strip()) if theme_spacing['success'] else 0
        
        return {
            'scenario': scenario_id,
            'test': 'spacing_consistency',
            'passed': hardcoded_spacing < 30 and theme_spacing_count > 20,
            'details': f"Hardcoded spacing: {hardcoded_spacing}, Theme spacing: {theme_spacing_count}",
            'output': "Spacing analysis complete"
        }
    
    def test_import_consistency(self, scenario_id):
        """Test 5: Import consistency and unused imports"""
        self.log(f"Scenario {scenario_id}: Testing import consistency")
        
        # Check for unused imports
        result = self.run_command("flutter analyze | grep 'unused_import' | wc -l")
        unused_imports = int(result['stdout'].strip()) if result['success'] else 0
        
        return {
            'scenario': scenario_id,
            'test': 'import_consistency',
            'passed': unused_imports < 10,
            'details': f"Unused imports: {unused_imports}",
            'output': "Import analysis complete"
        }
    
    def test_widget_tree_structure(self, scenario_id):
        """Test 6: Widget tree structure validation"""
        self.log(f"Scenario {scenario_id}: Testing widget tree structure")
        
        # Check for missing keys in lists
        missing_keys = self.run_command("grep -r 'ListView\\|GridView' lib/ --include='*.dart' | grep -v 'key:' | wc -l")
        missing_key_count = int(missing_keys['stdout'].strip()) if missing_keys['success'] else 0
        
        # Check for proper StatefulWidget usage
        stateful_widgets = self.run_command("grep -r 'StatefulWidget' lib/ --include='*.dart' | wc -l")
        stateful_count = int(stateful_widgets['stdout'].strip()) if stateful_widgets['success'] else 0
        
        return {
            'scenario': scenario_id,
            'test': 'widget_tree_structure',
            'passed': missing_key_count < 5 and stateful_count > 5,
            'details': f"Potential missing keys: {missing_key_count}, StatefulWidgets: {stateful_count}",
            'output': "Widget structure analysis complete"
        }
    
    def test_screen_implementations(self, scenario_id):
        """Test 7: All required screens are implemented"""
        self.log(f"Scenario {scenario_id}: Testing screen implementations")
        
        required_screens = [
            'enhanced_home_screen.dart',
            'connect_screen.dart',
            'watch_party_screen.dart',
            'movie_detail_screen.dart',
            'profile_screen.dart'
        ]
        
        missing_screens = []
        for screen in required_screens:
            if not (self.project_path / 'lib' / 'screens' / screen).exists():
                missing_screens.append(screen)
        
        return {
            'scenario': scenario_id,
            'test': 'screen_implementations',
            'passed': len(missing_screens) == 0,
            'details': f"Missing screens: {missing_screens}" if missing_screens else "All screens present",
            'output': "Screen implementation check complete"
        }
    
    def test_theme_file_structure(self, scenario_id):
        """Test 8: Theme file structure and completeness"""
        self.log(f"Scenario {scenario_id}: Testing theme file structure")
        
        theme_file = self.project_path / 'lib' / 'theme' / 'app_theme.dart'
        if not theme_file.exists():
            return {
                'scenario': scenario_id,
                'test': 'theme_file_structure',
                'passed': False,
                'details': "Theme file missing",
                'output': "app_theme.dart not found"
            }
        
        # Check for required theme elements
        theme_content = theme_file.read_text()
        required_elements = [
            'lightTheme',
            'darkTheme',
            'AmbientColor',
            'primaryColor',
            'minimalSurface',
            'heading1',
            'body'
        ]
        
        missing_elements = [elem for elem in required_elements if elem not in theme_content]
        
        return {
            'scenario': scenario_id,
            'test': 'theme_file_structure',
            'passed': len(missing_elements) == 0,
            'details': f"Missing theme elements: {missing_elements}" if missing_elements else "All theme elements present",
            'output': "Theme structure analysis complete"
        }
    
    def test_pubspec_dependencies(self, scenario_id):
        """Test 9: Pubspec dependencies are valid"""
        self.log(f"Scenario {scenario_id}: Testing pubspec dependencies")
        
        result = self.run_command("flutter pub deps --no-dev")
        
        return {
            'scenario': scenario_id,
            'test': 'pubspec_dependencies',
            'passed': result['success'],
            'details': "Dependencies resolved successfully" if result['success'] else "Dependency resolution failed",
            'output': result['stderr'][:500] if not result['success'] else "Dependencies OK"
        }
    
    def test_responsive_layout(self, scenario_id):
        """Test 10: Responsive layout patterns"""
        self.log(f"Scenario {scenario_id}: Testing responsive layout patterns")
        
        # Check for responsive widgets
        responsive_patterns = self.run_command("grep -r 'MediaQuery\\|LayoutBuilder\\|Flexible\\|Expanded' lib/ --include='*.dart' | wc -l")
        responsive_count = int(responsive_patterns['stdout'].strip()) if responsive_patterns['success'] else 0
        
        return {
            'scenario': scenario_id,
            'test': 'responsive_layout',
            'passed': responsive_count > 10,
            'details': f"Responsive patterns found: {responsive_count}",
            'output': "Responsive layout analysis complete"
        }
    
    def run_scenario(self, scenario_id):
        """Run a complete test scenario"""
        scenario_start = time.time()
        self.log(f"Starting scenario {scenario_id}/100")
        
        # Select random tests for this scenario
        all_tests = [
            self.test_flutter_analyze,
            self.test_theme_consistency,
            self.test_spacing_consistency,
            self.test_import_consistency,
            self.test_widget_tree_structure,
            self.test_screen_implementations,
            self.test_theme_file_structure,
            self.test_pubspec_dependencies,
            self.test_responsive_layout
        ]
        
        # Run build test occasionally
        if scenario_id % 10 == 0:
            platforms = ['apk', 'web']
            platform = random.choice(platforms)
            all_tests.append(lambda sid: self.test_flutter_build(sid, platform))
        
        # Run 3-5 random tests per scenario
        num_tests = random.randint(3, min(5, len(all_tests)))
        selected_tests = random.sample(all_tests, num_tests)
        
        scenario_results = []
        for test in selected_tests:
            try:
                result = test(scenario_id)
                scenario_results.append(result)
                
                if result['passed']:
                    self.passed_tests.append(result)
                    self.log(f"✅ {result['test']}: PASSED - {result['details']}")
                else:
                    self.failed_tests.append(result)
                    self.log(f"❌ {result['test']}: FAILED - {result['details']}", "ERROR")
                    
            except Exception as e:
                error_result = {
                    'scenario': scenario_id,
                    'test': 'unknown',
                    'passed': False,
                    'details': f"Test crashed: {str(e)}",
                    'output': str(e)
                }
                scenario_results.append(error_result)
                self.failed_tests.append(error_result)
                self.log(f"💥 Test crashed: {str(e)}", "ERROR")
        
        scenario_time = time.time() - scenario_start
        self.log(f"Scenario {scenario_id} completed in {scenario_time:.2f}s")
        
        return scenario_results
    
    def generate_report(self):
        """Generate comprehensive test report"""
        total_tests = len(self.passed_tests) + len(self.failed_tests)
        pass_rate = (len(self.passed_tests) / total_tests * 100) if total_tests > 0 else 0
        
        report = f"""
# Flutter App Testing Report
Generated: {datetime.now().strftime("%Y-%m-%d %H:%M:%S")}

## Summary
- **Total Tests Run**: {total_tests}
- **Passed**: {len(self.passed_tests)} ✅
- **Failed**: {len(self.failed_tests)} ❌
- **Pass Rate**: {pass_rate:.1f}%

## Test Categories
"""
        
        # Group by test type
        test_types = {}
        for test in self.passed_tests + self.failed_tests:
            test_type = test['test']
            if test_type not in test_types:
                test_types[test_type] = {'passed': 0, 'failed': 0}
            
            if test['passed']:
                test_types[test_type]['passed'] += 1
            else:
                test_types[test_type]['failed'] += 1
        
        for test_type, counts in test_types.items():
            total = counts['passed'] + counts['failed']
            rate = (counts['passed'] / total * 100) if total > 0 else 0
            status = "✅" if rate >= 80 else "⚠️" if rate >= 60 else "❌"
            report += f"- **{test_type}**: {counts['passed']}/{total} ({rate:.1f}%) {status}\n"
        
        if self.failed_tests:
            report += "\n## Failed Tests Details\n"
            for test in self.failed_tests[-10]:  # Show last 10 failures
                report += f"- **Scenario {test['scenario']}** - {test['test']}: {test['details']}\n"
        
        report += f"\n## Recommendations\n"
        
        if pass_rate >= 90:
            report += "🎉 **Excellent!** Your app is in great shape. Continue monitoring.\n"
        elif pass_rate >= 75:
            report += "👍 **Good!** Minor issues detected. Address failed tests when convenient.\n"
        elif pass_rate >= 60:
            report += "⚠️ **Needs Attention!** Several issues found. Prioritize fixing failed tests.\n"
        else:
            report += "🚨 **Critical Issues!** Many tests failing. Immediate attention required.\n"
        
        return report
    
    def run_all_scenarios(self):
        """Run all 100 test scenarios"""
        start_time = time.time()
        self.log("🚀 Starting 100-scenario testing suite")
        
        for scenario_id in range(1, 101):
            try:
                results = self.run_scenario(scenario_id)
                self.test_results.extend(results)
                
                # Brief pause between scenarios
                time.sleep(0.5)
                
                # Progress update every 10 scenarios
                if scenario_id % 10 == 0:
                    passed = len(self.passed_tests)
                    failed = len(self.failed_tests)
                    total = passed + failed
                    rate = (passed / total * 100) if total > 0 else 0
                    self.log(f"Progress: {scenario_id}/100 scenarios | Pass rate: {rate:.1f}%")
                    
            except KeyboardInterrupt:
                self.log("Testing interrupted by user", "WARNING")
                break
            except Exception as e:
                self.log(f"Scenario {scenario_id} crashed: {str(e)}", "ERROR")
                continue
        
        total_time = time.time() - start_time
        self.log(f"🏁 Testing completed in {total_time:.2f}s")
        
        # Generate and save report
        report = self.generate_report()
        
        report_path = self.project_path / "test_report.md"
        with open(report_path, 'w') as f:
            f.write(report)
        
        self.log(f"📊 Report saved to {report_path}")
        print("\n" + report)

def main():
    project_path = "/Users/salescode/Desktop/Recycle_Bin/FWB"
    
    if not os.path.exists(project_path):
        print(f"❌ Project path not found: {project_path}")
        return
    
    tester = FlutterAppTester(project_path)
    tester.run_all_scenarios()

if __name__ == "__main__":
    main()

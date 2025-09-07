#!/usr/bin/env python3
"""
🗼 Project Watchtower - Cursor Integration Automation
This script orchestrates the complete night automation with Cursor AI integration
"""

import os
import json
import time
import subprocess
import threading
from datetime import datetime
from pathlib import Path

class ProjectWatchtowerAutomation:
    def __init__(self):
        self.project_root = Path("/Users/salescode/Desktop/Recycle_Bin/fwb")
        self.automation_dir = self.project_root / "automation"
        self.reports_dir = self.automation_dir / "reports"
        self.logs_dir = self.automation_dir / "logs"
        self.fixes_dir = self.automation_dir / "fixes"
        
        # Create directories
        for dir_path in [self.automation_dir, self.reports_dir, self.logs_dir, self.fixes_dir]:
            dir_path.mkdir(exist_ok=True)
        
        self.log_file = self.logs_dir / f"automation_{datetime.now().strftime('%Y%m%d_%H%M%S')}.log"
        
    def log(self, message):
        """Log message with timestamp"""
        timestamp = datetime.now().strftime('%Y-%m-%d %H:%M:%S')
        log_entry = f"[{timestamp}] {message}"
        print(log_entry)
        
        with open(self.log_file, 'a') as f:
            f.write(log_entry + '\n')
    
    def run_flutter_command(self, command, timeout=300):
        """Run flutter command with timeout"""
        try:
            result = subprocess.run(
                f"cd {self.project_root} && {command}",
                shell=True,
                capture_output=True,
                text=True,
                timeout=timeout
            )
            return result.returncode == 0, result.stdout, result.stderr
        except subprocess.TimeoutExpired:
            return False, "", "Command timed out"
        except Exception as e:
            return False, "", str(e)
    
    def check_app_health(self):
        """Comprehensive app health check"""
        self.log("🔍 Performing comprehensive app health check...")
        
        health_report = {
            "timestamp": datetime.now().isoformat(),
            "checks": {},
            "overall_health": "unknown",
            "critical_issues": [],
            "minor_issues": [],
            "recommendations": []
        }
        
        # 1. Build Check
        self.log("  📦 Checking build status...")
        success, stdout, stderr = self.run_flutter_command("flutter build ios --simulator")
        health_report["checks"]["build"] = {
            "status": "pass" if success else "fail",
            "details": stderr if not success else "Build successful"
        }
        if not success:
            health_report["critical_issues"].append(f"Build failed: {stderr}")
        
        # 2. Code Quality Check
        self.log("  📝 Checking code quality...")
        success, stdout, stderr = self.run_flutter_command("flutter analyze")
        health_report["checks"]["code_quality"] = {
            "status": "pass" if success else "fail",
            "details": stderr if not success else "No analysis issues"
        }
        if not success:
            health_report["minor_issues"].append(f"Analysis issues: {stderr}")
        
        # 3. Dependencies Check
        self.log("  📚 Checking dependencies...")
        success, stdout, stderr = self.run_flutter_command("flutter pub deps")
        health_report["checks"]["dependencies"] = {
            "status": "pass" if success else "fail",
            "details": "Dependencies resolved" if success else stderr
        }
        
        # 4. File Structure Check
        self.log("  📁 Checking file structure...")
        critical_files = [
            "lib/main.dart",
            "lib/screens/auth/refined_login_screen.dart",
            "lib/screens/enhanced_home_screen.dart",
            "lib/screens/root_tab_screen.dart",
            "lib/theme/app_theme.dart",
            "pubspec.yaml"
        ]
        
        missing_files = [f for f in critical_files if not (self.project_root / f).exists()]
        health_report["checks"]["file_structure"] = {
            "status": "pass" if not missing_files else "fail",
            "missing_files": missing_files
        }
        if missing_files:
            health_report["critical_issues"].extend([f"Missing file: {f}" for f in missing_files])
        
        # 5. UI Consistency Check
        self.log("  🎨 Checking UI consistency...")
        ui_issues = self.check_ui_consistency()
        health_report["checks"]["ui_consistency"] = {
            "status": "pass" if not ui_issues else "warn",
            "issues": ui_issues
        }
        health_report["minor_issues"].extend(ui_issues)
        
        # 6. Branding Check
        self.log("  🏷️ Checking branding consistency...")
        branding_issues = self.check_branding_consistency()
        health_report["checks"]["branding"] = {
            "status": "pass" if not branding_issues else "warn",
            "issues": branding_issues
        }
        health_report["minor_issues"].extend(branding_issues)
        
        # 7. Performance Check
        self.log("  ⚡ Checking performance indicators...")
        perf_issues = self.check_performance_indicators()
        health_report["checks"]["performance"] = {
            "status": "pass" if not perf_issues else "warn",
            "issues": perf_issues
        }
        health_report["minor_issues"].extend(perf_issues)
        
        # Determine overall health
        if health_report["critical_issues"]:
            health_report["overall_health"] = "critical"
        elif health_report["minor_issues"]:
            health_report["overall_health"] = "needs_improvement"
        else:
            health_report["overall_health"] = "excellent"
        
        # Generate recommendations
        health_report["recommendations"] = self.generate_recommendations(health_report)
        
        # Save health report
        report_file = self.reports_dir / f"health_report_{datetime.now().strftime('%H%M%S')}.json"
        with open(report_file, 'w') as f:
            json.dump(health_report, f, indent=2)
        
        self.log(f"  📊 Health check complete. Status: {health_report['overall_health']}")
        return health_report
    
    def check_ui_consistency(self):
        """Check for UI consistency issues"""
        issues = []
        
        # Check for hardcoded colors
        result = subprocess.run(
            f"cd {self.project_root} && grep -r 'Colors\\.' lib/ --include='*.dart' | grep -v 'AppTheme' || true",
            shell=True, capture_output=True, text=True
        )
        if result.stdout.strip():
            issues.append("Hardcoded colors found - should use AppTheme")
        
        # Check for hardcoded spacing
        result = subprocess.run(
            f"cd {self.project_root} && grep -r 'EdgeInsets\\.all([0-9]' lib/ --include='*.dart' | grep -v 'AppTheme' || true",
            shell=True, capture_output=True, text=True
        )
        if result.stdout.strip():
            issues.append("Hardcoded spacing found - should use AppTheme spacing")
        
        # Check for missing semantic labels
        result = subprocess.run(
            f"cd {self.project_root} && grep -r 'GestureDetector\\|InkWell\\|TextButton' lib/ --include='*.dart' | grep -v 'semanticsLabel' || true",
            shell=True, capture_output=True, text=True
        )
        lines = result.stdout.strip().split('\n') if result.stdout.strip() else []
        if len(lines) > 5:  # Allow some without semantic labels
            issues.append("Many interactive widgets missing semantic labels")
        
        return issues
    
    def check_branding_consistency(self):
        """Check for branding consistency"""
        issues = []
        
        # Check for old FWB references
        result = subprocess.run(
            f"cd {self.project_root} && grep -r 'FWB' lib/ --include='*.dart' || true",
            shell=True, capture_output=True, text=True
        )
        if result.stdout.strip():
            issues.append("Old 'FWB' branding references found")
        
        # Check for old tagline
        result = subprocess.run(
            f"cd {self.project_root} && grep -r 'Friends With Benefits' lib/ --include='*.dart' || true",
            shell=True, capture_output=True, text=True
        )
        if result.stdout.strip():
            issues.append("Old 'Friends With Benefits' tagline found")
        
        # Check for new branding presence
        result = subprocess.run(
            f"cd {self.project_root} && grep -r 'Project Watchtower' lib/ --include='*.dart' || true",
            shell=True, capture_output=True, text=True
        )
        if not result.stdout.strip():
            issues.append("New 'Project Watchtower' branding may be incomplete")
        
        return issues
    
    def check_performance_indicators(self):
        """Check for performance indicators"""
        issues = []
        
        # Check for excessive setState calls
        result = subprocess.run(
            f"cd {self.project_root} && grep -r 'setState.*build' lib/ --include='*.dart' || true",
            shell=True, capture_output=True, text=True
        )
        if result.stdout.strip():
            issues.append("Potential setState in build method detected")
        
        # Check for missing const constructors
        result = subprocess.run(
            f"cd {self.project_root} && grep -r 'Widget.*(' lib/ --include='*.dart' | grep -v 'const' | wc -l",
            shell=True, capture_output=True, text=True
        )
        try:
            count = int(result.stdout.strip())
            if count > 100:  # Threshold for concern
                issues.append(f"Many widgets without const constructors ({count} found)")
        except:
            pass
        
        # Check for large image files
        result = subprocess.run(
            f"cd {self.project_root} && find . -name '*.png' -size +1M || true",
            shell=True, capture_output=True, text=True
        )
        if result.stdout.strip():
            issues.append("Large image files found - may impact performance")
        
        return issues
    
    def generate_recommendations(self, health_report):
        """Generate improvement recommendations"""
        recommendations = []
        
        # Critical issues recommendations
        for issue in health_report["critical_issues"]:
            if "Build failed" in issue:
                recommendations.append("Fix build errors immediately - this prevents app from running")
            elif "Missing file" in issue:
                recommendations.append("Restore missing critical files")
        
        # Minor issues recommendations
        for issue in health_report["minor_issues"]:
            if "Hardcoded colors" in issue:
                recommendations.append("Replace hardcoded colors with AppTheme references")
            elif "branding" in issue.lower():
                recommendations.append("Update all branding references to Project Watchtower")
            elif "performance" in issue.lower():
                recommendations.append("Apply performance optimizations")
            elif "semantic" in issue.lower():
                recommendations.append("Add semantic labels for better accessibility")
        
        return recommendations
    
    def apply_automated_fixes(self, health_report):
        """Apply automated fixes based on health report"""
        self.log("🛠️ Applying automated fixes...")
        
        fixes_applied = []
        
        # Fix 1: Update hardcoded colors
        if any("Hardcoded colors" in issue for issue in health_report["minor_issues"]):
            self.log("  🎨 Fixing hardcoded colors...")
            self.fix_hardcoded_colors()
            fixes_applied.append("Updated hardcoded colors to use AppTheme")
        
        # Fix 2: Update branding
        if any("branding" in issue.lower() for issue in health_report["minor_issues"]):
            self.log("  🏷️ Fixing branding consistency...")
            self.fix_branding_consistency()
            fixes_applied.append("Updated branding to Project Watchtower")
        
        # Fix 3: Add const constructors
        if any("const constructors" in issue for issue in health_report["minor_issues"]):
            self.log("  ⚡ Adding const constructors...")
            self.fix_const_constructors()
            fixes_applied.append("Added const constructors for performance")
        
        # Fix 4: Standardize spacing
        if any("spacing" in issue.lower() for issue in health_report["minor_issues"]):
            self.log("  📐 Standardizing spacing...")
            self.fix_spacing_consistency()
            fixes_applied.append("Standardized spacing using AppTheme")
        
        return fixes_applied
    
    def fix_hardcoded_colors(self):
        """Fix hardcoded color references"""
        subprocess.run(
            f"cd {self.project_root} && find lib/ -name '*.dart' -exec sed -i '' 's/Colors\\.grey/AppTheme.secondaryText(brightness)/g' {{}} \\;",
            shell=True
        )
        subprocess.run(
            f"cd {self.project_root} && find lib/ -name '*.dart' -exec sed -i '' 's/Colors\\.black/AppTheme.primaryText(brightness)/g' {{}} \\;",
            shell=True
        )
    
    def fix_branding_consistency(self):
        """Fix branding consistency"""
        subprocess.run(
            f"cd {self.project_root} && find lib/ -name '*.dart' -exec sed -i '' 's/FWB/Project Watchtower/g' {{}} \\;",
            shell=True
        )
        subprocess.run(
            f"cd {self.project_root} && find lib/ -name '*.dart' -exec sed -i '' 's/Friends With Benefits/Watch Together, Discover Together/g' {{}} \\;",
            shell=True
        )
    
    def fix_const_constructors(self):
        """Add const constructors where possible"""
        # This is a simplified version - in practice, this would be more sophisticated
        subprocess.run(
            f"cd {self.project_root} && find lib/ -name '*.dart' -exec sed -i '' 's/Widget(/const Widget(/g' {{}} \\;",
            shell=True
        )
    
    def fix_spacing_consistency(self):
        """Standardize spacing"""
        subprocess.run(
            f"cd {self.project_root} && find lib/ -name '*.dart' -exec sed -i '' 's/EdgeInsets\\.all(8)/EdgeInsets.all(AppTheme.sm)/g' {{}} \\;",
            shell=True
        )
        subprocess.run(
            f"cd {self.project_root} && find lib/ -name '*.dart' -exec sed -i '' 's/EdgeInsets\\.all(16)/EdgeInsets.all(AppTheme.md)/g' {{}} \\;",
            shell=True
        )
    
    def run_tests_and_fix_cycle(self):
        """Run a complete test and fix cycle"""
        cycle_start = datetime.now()
        self.log(f"🔄 Starting test and fix cycle at {cycle_start}")
        
        # 1. Health check
        health_report = self.check_app_health()
        
        # 2. Apply fixes if needed
        fixes_applied = []
        if health_report["overall_health"] != "excellent":
            fixes_applied = self.apply_automated_fixes(health_report)
            
            # 3. Rebuild after fixes
            self.log("🔨 Rebuilding after fixes...")
            success, stdout, stderr = self.run_flutter_command("flutter clean && flutter pub get")
            if success:
                success, stdout, stderr = self.run_flutter_command("flutter build ios --simulator")
                if success:
                    self.log("✅ Rebuild successful after fixes")
                else:
                    self.log(f"❌ Rebuild failed after fixes: {stderr}")
            
            # 4. Re-check health
            self.log("🔍 Re-checking health after fixes...")
            health_report = self.check_app_health()
        
        cycle_end = datetime.now()
        cycle_duration = cycle_end - cycle_start
        
        # Create cycle report
        cycle_report = {
            "cycle_start": cycle_start.isoformat(),
            "cycle_end": cycle_end.isoformat(),
            "duration_seconds": cycle_duration.total_seconds(),
            "health_report": health_report,
            "fixes_applied": fixes_applied,
            "success": health_report["overall_health"] in ["excellent", "needs_improvement"]
        }
        
        # Save cycle report
        cycle_file = self.reports_dir / f"cycle_{datetime.now().strftime('%H%M%S')}.json"
        with open(cycle_file, 'w') as f:
            json.dump(cycle_report, f, indent=2)
        
        return cycle_report
    
    def run_night_automation(self):
        """Run the complete night automation"""
        self.log("🌙 Starting Project Watchtower Night Automation")
        
        automation_start = datetime.now()
        max_cycles = 10
        cycles_run = 0
        perfect_cycles = 0
        
        while cycles_run < max_cycles:
            cycles_run += 1
            self.log(f"\n🔄 Starting cycle {cycles_run}/{max_cycles}")
            
            cycle_report = self.run_tests_and_fix_cycle()
            
            if cycle_report["success"] and cycle_report["health_report"]["overall_health"] == "excellent":
                perfect_cycles += 1
                self.log(f"🎉 Cycle {cycles_run} completed perfectly!")
                
                # If we have 2 perfect cycles in a row, we're done
                if perfect_cycles >= 2:
                    self.log("🎉 Two perfect cycles achieved! App is optimal!")
                    break
            else:
                perfect_cycles = 0  # Reset counter
                
            # Wait between cycles
            if cycles_run < max_cycles:
                self.log("⏳ Waiting 30 seconds before next cycle...")
                time.sleep(30)
        
        automation_end = datetime.now()
        total_duration = automation_end - automation_start
        
        # Generate final report
        final_report = self.generate_final_automation_report(
            automation_start, automation_end, cycles_run, perfect_cycles
        )
        
        self.log("🌅 Night automation completed!")
        self.log(f"📊 Total cycles: {cycles_run}")
        self.log(f"⏰ Total time: {total_duration}")
        self.log(f"🎯 Perfect cycles: {perfect_cycles}")
        
        return final_report
    
    def generate_final_automation_report(self, start_time, end_time, cycles_run, perfect_cycles):
        """Generate comprehensive final report"""
        self.log("📄 Generating final automation report...")
        
        # Final health check
        final_health = self.check_app_health()
        
        report = {
            "automation_summary": {
                "start_time": start_time.isoformat(),
                "end_time": end_time.isoformat(),
                "duration_hours": (end_time - start_time).total_seconds() / 3600,
                "cycles_run": cycles_run,
                "perfect_cycles": perfect_cycles,
                "success_rate": (perfect_cycles / cycles_run) * 100 if cycles_run > 0 else 0
            },
            "final_app_status": final_health,
            "overall_success": final_health["overall_health"] == "excellent"
        }
        
        # Save final report
        final_report_file = self.reports_dir / f"final_automation_report_{datetime.now().strftime('%Y%m%d')}.json"
        with open(final_report_file, 'w') as f:
            json.dump(report, f, indent=2)
        
        # Create markdown summary for easy reading
        markdown_report = self.create_markdown_summary(report)
        markdown_file = self.reports_dir / f"FINAL_REPORT_{datetime.now().strftime('%Y%m%d')}.md"
        with open(markdown_file, 'w') as f:
            f.write(markdown_report)
        
        # Create simple status file
        status_file = self.automation_dir / "AUTOMATION_STATUS.txt"
        with open(status_file, 'w') as f:
            status = "SUCCESS" if report["overall_success"] else "NEEDS_ATTENTION"
            f.write(f"🗼 Project Watchtower Automation Status: {status}\n")
            f.write(f"Completed: {end_time}\n")
            f.write(f"Cycles Run: {cycles_run}\n")
            f.write(f"Perfect Cycles: {perfect_cycles}\n")
            f.write(f"Final Health: {final_health['overall_health']}\n")
            f.write(f"\nCheck {markdown_file} for detailed report\n")
        
        return report
    
    def create_markdown_summary(self, report):
        """Create markdown summary of automation"""
        summary = f"""# 🗼 Project Watchtower - Night Automation Complete

**Completed:** {datetime.now().strftime('%Y-%m-%d %H:%M:%S')}
**Status:** {'🎉 SUCCESS' if report['overall_success'] else '⚠️ NEEDS ATTENTION'}

## 📊 Automation Summary

- **Duration:** {report['automation_summary']['duration_hours']:.1f} hours
- **Cycles Run:** {report['automation_summary']['cycles_run']}
- **Perfect Cycles:** {report['automation_summary']['perfect_cycles']}
- **Success Rate:** {report['automation_summary']['success_rate']:.1f}%

## 📱 Final App Status

**Overall Health:** {report['final_app_status']['overall_health'].title()}

### Build Status: {'✅' if report['final_app_status']['checks']['build']['status'] == 'pass' else '❌'}
{report['final_app_status']['checks']['build']['details']}

### Code Quality: {'✅' if report['final_app_status']['checks']['code_quality']['status'] == 'pass' else '❌'}
{report['final_app_status']['checks']['code_quality']['details']}

### UI Consistency: {'✅' if report['final_app_status']['checks']['ui_consistency']['status'] == 'pass' else '⚠️'}
{'No issues found' if not report['final_app_status']['checks']['ui_consistency']['issues'] else 'Issues: ' + ', '.join(report['final_app_status']['checks']['ui_consistency']['issues'])}

### Branding: {'✅' if report['final_app_status']['checks']['branding']['status'] == 'pass' else '⚠️'}
{'Consistent' if not report['final_app_status']['checks']['branding']['issues'] else 'Issues: ' + ', '.join(report['final_app_status']['checks']['branding']['issues'])}

## 🛠️ Issues & Recommendations

"""
        
        if report['final_app_status']['critical_issues']:
            summary += "### 🚨 Critical Issues\n"
            for issue in report['final_app_status']['critical_issues']:
                summary += f"- {issue}\n"
            summary += "\n"
        
        if report['final_app_status']['minor_issues']:
            summary += "### ⚠️ Minor Issues\n"
            for issue in report['final_app_status']['minor_issues']:
                summary += f"- {issue}\n"
            summary += "\n"
        
        if report['final_app_status']['recommendations']:
            summary += "### 💡 Recommendations\n"
            for rec in report['final_app_status']['recommendations']:
                summary += f"- {rec}\n"
            summary += "\n"
        
        if not report['final_app_status']['critical_issues'] and not report['final_app_status']['minor_issues']:
            summary += "🎉 **No issues found! Project Watchtower is perfect!**\n\n"
        
        summary += f"""## ☀️ Morning Status

Project Watchtower is ready for use!
{'All systems optimal and functioning perfectly.' if report['overall_success'] else 'Some minor improvements may be beneficial.'}

---
*Generated by Project Watchtower Automation System*
"""
        
        return summary

def main():
    """Main entry point for night automation"""
    print("🗼 Project Watchtower - Cursor Integration Automation")
    print("🌙 Preparing for night-long testing and optimization...")
    
    automation = ProjectWatchtowerAutomation()
    
    try:
        final_report = automation.run_night_automation()
        
        if final_report["overall_success"]:
            print("\n🎉 SUCCESS! Project Watchtower is perfect!")
            print("☀️ Your app is ready for the morning!")
        else:
            print("\n⚠️ Automation completed with some items needing attention")
            print("📄 Check the final report for details")
        
        print(f"\n📊 Final Status: {final_report['final_app_status']['overall_health']}")
        print("💤 Sweet dreams! The automation worked hard for you!")
        
    except KeyboardInterrupt:
        automation.log("⚠️ Automation interrupted by user")
        print("\n⚠️ Automation stopped by user")
    except Exception as e:
        automation.log(f"❌ Automation error: {str(e)}")
        print(f"\n❌ Automation error: {str(e)}")
        raise

if __name__ == "__main__":
    main()





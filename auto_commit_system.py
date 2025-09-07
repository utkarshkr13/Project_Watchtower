#!/usr/bin/env python3
"""
Auto-Commit System for Project Watch Tower
Automatically commits changes every 5 minutes to GitHub repository
"""

import os
import sys
import time
import subprocess
import logging
from datetime import datetime
from pathlib import Path

class AutoCommitSystem:
    def __init__(self):
        self.setup_logging()
        self.repo_path = "/Users/salescode/Desktop/Recycle_Bin/project_watch_tower"
        self.github_repo = "https://github.com/utkarshkr13/Project_Watchtower.git"
        self.commit_interval = 300  # 5 minutes in seconds
        self.is_running = True
        
    def setup_logging(self):
        """Setup comprehensive logging"""
        logging.basicConfig(
            level=logging.INFO,
            format='%(asctime)s - %(levelname)s - %(message)s',
            handlers=[
                logging.FileHandler('auto_commit.log'),
                logging.StreamHandler()
            ]
        )
        self.logger = logging.getLogger(__name__)
        
    def check_git_status(self):
        """Check if we're in a git repository and get status"""
        try:
            os.chdir(self.repo_path)
            
            # Check if this is a git repository
            result = subprocess.run(['git', 'status'], capture_output=True, text=True)
            if result.returncode != 0:
                self.logger.error("Not a git repository or git not initialized")
                return False
                
            return True
            
        except Exception as e:
            self.logger.error(f"Error checking git status: {e}")
            return False
    
    def setup_git_repository(self):
        """Setup git repository and remote"""
        try:
            os.chdir(self.repo_path)
            
            # Initialize git if not already done
            if not os.path.exists('.git'):
                self.logger.info("Initializing git repository...")
                subprocess.run(['git', 'init'], check=True)
            
            # Add remote origin if not exists
            result = subprocess.run(['git', 'remote', '-v'], capture_output=True, text=True)
            if 'origin' not in result.stdout:
                self.logger.info("Adding remote origin...")
                subprocess.run(['git', 'remote', 'add', 'origin', self.github_repo], check=True)
            
            # Set up git config if needed
            subprocess.run(['git', 'config', 'user.name', 'Project Watch Tower AI'], check=True)
            subprocess.run(['git', 'config', 'user.email', 'ai@projectwatchtower.com'], check=True)
            
            self.logger.info("Git repository setup complete")
            return True
            
        except Exception as e:
            self.logger.error(f"Error setting up git repository: {e}")
            return False
    
    def get_changes_summary(self):
        """Get a summary of changes to commit"""
        try:
            os.chdir(self.repo_path)
            
            # Get list of modified files
            result = subprocess.run(['git', 'status', '--porcelain'], capture_output=True, text=True)
            if not result.stdout.strip():
                return None, "No changes to commit"
            
            changes = []
            for line in result.stdout.strip().split('\n'):
                if line:
                    status = line[:2]
                    filename = line[3:]
                    changes.append((status, filename))
            
            # Categorize changes
            categories = {
                'AI Testing': [],
                'UI Fixes': [],
                'Code Updates': [],
                'Documentation': [],
                'Configuration': [],
                'Other': []
            }
            
            for status, filename in changes:
                if any(x in filename.lower() for x in ['ai', 'test', 'monitor', 'fixer']):
                    categories['AI Testing'].append(filename)
                elif any(x in filename.lower() for x in ['screen', 'widget', 'theme', 'ui']):
                    categories['UI Fixes'].append(filename)
                elif any(x in filename.lower() for x in ['dart', 'lib', 'main']):
                    categories['Code Updates'].append(filename)
                elif any(x in filename.lower() for x in ['readme', 'md', 'doc']):
                    categories['Documentation'].append(filename)
                elif any(x in filename.lower() for x in ['yaml', 'json', 'config', 'pubspec']):
                    categories['Configuration'].append(filename)
                else:
                    categories['Other'].append(filename)
            
            # Create summary
            summary_parts = []
            for category, files in categories.items():
                if files:
                    summary_parts.append(f"{category}: {len(files)} files")
            
            summary = " | ".join(summary_parts) if summary_parts else "Various updates"
            
            return changes, summary
            
        except Exception as e:
            self.logger.error(f"Error getting changes summary: {e}")
            return None, "Error analyzing changes"
    
    def commit_changes(self, changes, summary):
        """Commit the changes with a descriptive message"""
        try:
            os.chdir(self.repo_path)
            
            timestamp = datetime.now().strftime("%Y-%m-%d %H:%M:%S")
            
            # Add all changes
            subprocess.run(['git', 'add', '.'], check=True)
            
            # Create commit message
            commit_message = f"🤖 Auto-commit: {summary} ({timestamp})"
            
            # Add detailed file list
            if changes:
                commit_message += "\n\nFiles updated:\n"
                for status, filename in changes[:10]:  # Limit to first 10 files
                    commit_message += f"  {status} {filename}\n"
                
                if len(changes) > 10:
                    commit_message += f"  ... and {len(changes) - 10} more files\n"
            
            # Commit changes
            subprocess.run(['git', 'commit', '-m', commit_message], check=True)
            
            # Push to GitHub
            push_result = subprocess.run(['git', 'push', 'origin', 'main'], 
                                       capture_output=True, text=True)
            
            if push_result.returncode == 0:
                self.logger.info(f"✅ Successfully committed and pushed: {summary}")
                return True
            else:
                self.logger.warning(f"⚠️ Commit successful but push failed: {push_result.stderr}")
                return False
                
        except Exception as e:
            self.logger.error(f"Error committing changes: {e}")
            return False
    
    def run_auto_commit(self):
        """Main auto-commit loop"""
        self.logger.info("🚀 Starting Auto-Commit System for Project Watch Tower")
        self.logger.info(f"📁 Repository: {self.repo_path}")
        self.logger.info(f"🌐 GitHub: {self.github_repo}")
        self.logger.info(f"⏰ Commit interval: {self.commit_interval} seconds (5 minutes)")
        
        # Setup git repository
        if not self.setup_git_repository():
            self.logger.error("Failed to setup git repository. Exiting.")
            return
        
        commit_count = 0
        
        while self.is_running:
            try:
                self.logger.info("🔍 Checking for changes...")
                
                # Check git status
                if not self.check_git_status():
                    self.logger.error("Git repository check failed. Exiting.")
                    break
                
                # Get changes summary
                changes, summary = self.get_changes_summary()
                
                if changes:
                    self.logger.info(f"📝 Found changes: {summary}")
                    
                    # Commit changes
                    if self.commit_changes(changes, summary):
                        commit_count += 1
                        self.logger.info(f"🎉 Total commits made: {commit_count}")
                    else:
                        self.logger.error("❌ Failed to commit changes")
                else:
                    self.logger.info("✅ No changes to commit")
                
                # Wait for next check
                self.logger.info(f"⏳ Waiting {self.commit_interval} seconds until next check...")
                time.sleep(self.commit_interval)
                
            except KeyboardInterrupt:
                self.logger.info("🛑 Auto-commit system stopped by user")
                break
            except Exception as e:
                self.logger.error(f"❌ Unexpected error: {e}")
                time.sleep(60)  # Wait 1 minute before retrying
        
        self.logger.info(f"📊 Auto-commit system finished. Total commits: {commit_count}")

def main():
    """Main function"""
    print("🤖 Auto-Commit System for Project Watch Tower")
    print("=" * 50)
    print("This will automatically commit changes every 5 minutes")
    print("Press Ctrl+C to stop")
    print("=" * 50)
    
    auto_commit = AutoCommitSystem()
    auto_commit.run_auto_commit()

if __name__ == "__main__":
    main()

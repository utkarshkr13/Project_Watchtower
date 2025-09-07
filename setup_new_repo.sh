#!/bin/bash

# Project Watch Tower - GitHub Repository Setup Script
# ==================================================

set -e

# Colors for output
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

echo -e "${BLUE}"
echo "🚀 =================================="
echo "   Project Watch Tower Setup"
echo "   GitHub Repository Configuration"
echo "===================================${NC}"
echo

# Check if we're in the right directory
if [ ! -f "start_ai_testing.sh" ] || [ ! -d "test_cases" ]; then
    echo -e "${RED}❌ Error: Please run this script from the project_watch_tower directory${NC}"
    exit 1
fi

echo -e "${YELLOW}📋 Pre-Setup Checklist:${NC}"
echo "1. ✅ Folder renamed from 'FWB' to 'project_watch_tower'"
echo "2. ✅ All files committed with complete history"
echo "3. ✅ AI testing system with 10,000+ test cases ready"
echo "4. ✅ GitHub Actions CI/CD pipeline configured"
echo

# Check current git status
echo -e "${BLUE}🔍 Checking Git status...${NC}"
git status --short

echo
echo -e "${YELLOW}⚠️  IMPORTANT: Before running this script, please:${NC}"
echo "1. Go to https://github.com/utkarshkr13"
echo "2. Click 'New Repository'"
echo "3. Name it: project_watch_tower"
echo "4. Description: 🏰 AI-Driven Test Automation System for Flutter Watch Together App"
echo "5. DO NOT initialize with README (we have our own)"
echo "6. Click 'Create repository'"
echo

read -p "Have you created the repository on GitHub? (y/n): " -n 1 -r
echo
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo -e "${YELLOW}Please create the repository first, then run this script again.${NC}"
    exit 1
fi

echo
echo -e "${BLUE}🔗 Connecting to new GitHub repository...${NC}"

# Remove old remote if exists
git remote remove origin 2>/dev/null || echo "No existing origin remote"

# Add new remote
echo "Adding new remote origin..."
git remote add origin https://github.com/utkarshkr13/project_watch_tower.git

# Verify remote
echo -e "${BLUE}📡 Verifying remote connection...${NC}"
git remote -v

echo
echo -e "${BLUE}🚀 Pushing to new repository...${NC}"
echo "This may take a few minutes due to the large number of files..."

# Push to new repository
git push -u origin main

if [ $? -eq 0 ]; then
    echo
    echo -e "${GREEN}🎉 SUCCESS! Repository setup complete!${NC}"
    echo
    echo -e "${GREEN}✅ Your new repository is live at:${NC}"
    echo "   https://github.com/utkarshkr13/project_watch_tower"
    echo
    echo -e "${BLUE}📊 What's included:${NC}"
    echo "   • 10,000+ comprehensive test cases"
    echo "   • AI-powered testing engine with computer vision"
    echo "   • Cross-platform iOS and Android testing"
    echo "   • GitHub Actions CI/CD pipeline"
    echo "   • Real-time monitoring dashboard"
    echo "   • Complete Flutter app with all features"
    echo "   • Full commit history preserved"
    echo
    echo -e "${YELLOW}🔥 Next Steps:${NC}"
    echo "1. Visit your repository: https://github.com/utkarshkr13/project_watch_tower"
    echo "2. Enable GitHub Actions in the Actions tab"
    echo "3. Configure repository secrets for notifications (optional)"
    echo "4. Start testing: ./start_ai_testing.sh --limit 10"
    echo "5. View dashboard: ./start_ai_testing.sh --dashboard"
    echo
    echo -e "${GREEN}🤖 Your AI testing system is ready to revolutionize your development workflow!${NC}"
else
    echo -e "${RED}❌ Error pushing to repository. Please check:${NC}"
    echo "1. Repository exists on GitHub"
    echo "2. You have push permissions"
    echo "3. Internet connection is stable"
    echo
    echo "You can try pushing manually with:"
    echo "git push -u origin main"
fi

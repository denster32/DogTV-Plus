#!/bin/sh
# Git hooks setup script for DogTV+ project
# Run this script to install development Git hooks

set -e

HOOKS_DIR=".githooks"
GIT_HOOKS_DIR=".git/hooks"

echo "🔧 Setting up Git hooks for DogTV+ development..."

# Check if we're in a Git repository
if [ ! -d ".git" ]; then
    echo "❌ Error: Not in a Git repository. Please run this from the project root."
    exit 1
fi

# Check if hooks directory exists
if [ ! -d "$HOOKS_DIR" ]; then
    echo "❌ Error: $HOOKS_DIR directory not found."
    exit 1
fi

# Install hooks
for hook in "$HOOKS_DIR"/*; do
    if [ -f "$hook" ]; then
        hook_name=$(basename "$hook")
        target="$GIT_HOOKS_DIR/$hook_name"
        
        echo "📋 Installing $hook_name hook..."
        
        # Backup existing hook if it exists
        if [ -f "$target" ]; then
            echo "   Backing up existing $hook_name hook..."
            mv "$target" "$target.backup"
        fi
        
        # Copy and make executable
        cp "$hook" "$target"
        chmod +x "$target"
        
        echo "   ✅ $hook_name hook installed"
    fi
done

# Configure Git to use local hooks directory
echo "🔧 Configuring Git hooks path..."
git config core.hooksPath .githooks

echo ""
echo "✅ Git hooks setup complete!"
echo ""
echo "Installed hooks:"
echo "  - pre-commit: Runs SwiftLint, build check, and tests"
echo "  - pre-push: Runs comprehensive checks before pushing"
echo ""
echo "To disable hooks temporarily, use:"
echo "  git commit --no-verify"
echo "  git push --no-verify"
echo ""
echo "To uninstall hooks, run:"
echo "  git config --unset core.hooksPath"

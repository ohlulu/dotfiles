#!/bin/bash
set -e

echo "=============================================="
echo "  Swift Documentation Tools Installer"
echo "=============================================="
echo ""

# Check if Homebrew is installed
if ! command -v brew &> /dev/null; then
    echo "Homebrew is not installed. Please install it first:"
    echo "  /bin/bash -c \"\$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)\""
    exit 1
fi

echo "Homebrew found. Starting installation..."
echo ""

# 1. SourceKitten - AST Analysis
echo "1/4: Installing SourceKitten (AST analysis)..."
if command -v sourcekitten &> /dev/null; then
    echo "     SourceKitten already installed, skipping..."
else
    brew install sourcekitten
    echo "     SourceKitten installed successfully"
fi
echo ""

# 2. dependency-graph - Dependency visualization
echo "2/4: Installing dependency-graph (dependency visualization)..."
if command -v dependency-graph &> /dev/null; then
    echo "     dependency-graph already installed, skipping..."
else
    brew tap simonbs/dependency-graph https://github.com/simonbs/dependency-graph.git 2>/dev/null || true
    brew install dependency-graph
    echo "     dependency-graph installed successfully"
fi
echo ""

# 3. SourceDocs - Markdown documentation generation
echo "3/4: Installing SourceDocs (Markdown documentation)..."
if command -v sourcedocs &> /dev/null; then
    echo "     SourceDocs already installed, skipping..."
else
    brew install sourcedocs
    echo "     SourceDocs installed successfully"
fi
echo ""

# 4. Graphviz - DOT format rendering
echo "4/4: Installing Graphviz (diagram rendering)..."
if command -v dot &> /dev/null; then
    echo "     Graphviz already installed, skipping..."
else
    brew install graphviz
    echo "     Graphviz installed successfully"
fi
echo ""

echo "=============================================="
echo "  Installation Complete!"
echo "=============================================="
echo ""
echo "Installed Tools:"
echo "  - sourcekitten : $(sourcekitten version 2>/dev/null || echo 'installed')"
echo "  - dependency-graph : $(dependency-graph --version 2>/dev/null | head -1 || echo 'installed')"
echo "  - sourcedocs : $(sourcedocs version 2>/dev/null || echo 'installed')"
echo "  - dot (graphviz) : $(dot -V 2>&1 | head -1 || echo 'installed')"
echo ""
echo "Quick Start Commands:"
echo "  # Analyze Swift file structure"
echo "  sourcekitten structure --file Sources/MyModule/File.swift"
echo ""
echo "  # Generate dependency graph (Mermaid format)"
echo "  dependency-graph Package.swift --syntax mermaid"
echo ""
echo "  # Generate Markdown documentation"
echo "  sourcedocs generate --all-modules --output-folder docs/API"
echo ""
echo "  # SPM dependencies"
echo "  swift package show-dependencies --format json"
echo ""

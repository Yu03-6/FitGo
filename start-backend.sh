#!/usr/bin/env bash
# FitGo backend start script (Git Bash / WSL)

cd "$(dirname "$0")/backend" || exit 1

echo "=========================================="
echo "🚀 FitGo backend start"
echo "=========================================="
echo ""

# Check dependencies
echo "1) Checking npm dependencies..."
if [ ! -d "node_modules" ]; then
  echo "   ⚠️  node_modules missing, installing..."
  npm install
else
  echo "   ✅ Dependencies already installed"
fi

echo ""
echo "2) Starting backend..."
echo "   Service: http://localhost:3000"
echo ""
echo "=========================================="
echo ""

npm start

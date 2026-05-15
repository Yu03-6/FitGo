#!/bin/bash
# FitGo Application Startup Script
# Auto-start backend and initialize database

set -e

echo ""
echo "========================================"
echo "    FitGo Application Setup & Start     "
echo "========================================"
echo ""

# Check Node.js
echo "1) Checking Node.js..."
if command -v node &> /dev/null; then
    NODE_VERSION=$(node --version)
    echo "   ✅ Node.js found: $NODE_VERSION"
else
    echo "   ❌ Node.js not installed!"
    echo ""
    echo "   Please install Node.js first:"
    echo "   1. Visit https://nodejs.org (LTS)"
    echo "   2. Or use package manager: brew install node (macOS) or apt-get install nodejs (Ubuntu)"
    echo ""
    exit 1
fi

# Check npm
echo ""
echo "2) Checking npm..."
if command -v npm &> /dev/null; then
    NPM_VERSION=$(npm --version)
    echo "   ✅ npm found: $NPM_VERSION"
else
    echo "   ❌ npm not installed!"
    exit 1
fi

# Check MySQL
echo ""
echo "3) Checking MySQL..."
if command -v mysql &> /dev/null; then
    MYSQL_VERSION=$(mysql --version)
    echo "   ✅ MySQL found: $MYSQL_VERSION"
else
    echo "   ⚠️  MySQL command not found"
    echo "   Hint: ensure MySQL is installed and added to PATH"
fi

# 获取项目根目录
PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BACKEND_DIR="$PROJECT_ROOT/backend"
FLUTTER_DIR="$PROJECT_ROOT/flutter"

echo ""
echo "4) Enter backend directory..."
cd "$BACKEND_DIR"
echo "   📂 Current directory: $(pwd)"

# Check .env file
echo ""
echo "5) Checking .env file..."
if [ -f ".env" ]; then
    echo "   ✅ .env file exists"
else
    echo "   ❌ .env file is missing!"
    exit 1
fi

# Check node_modules
echo ""
echo "6) Checking npm dependencies..."
if [ -d "node_modules" ]; then
    echo "   ✅ Dependencies already installed"
else
    echo "   ⏳ Installing dependencies..."
    npm install
    echo "   ✅ Dependencies installed"
fi

# Initialize database
echo ""
echo "7) Initializing database..."
if command -v mysql &> /dev/null; then
    echo "   ⏳ Creating database and tables..."
    if mysql -u root -proot < init_database.sql 2>/dev/null; then
        echo "   ✅ Database initialized"
    else
        echo "   ⚠️  Database init may have failed"
        echo "   Please run manually: mysql -u root -proot < init_database.sql"
    fi
else
    echo "   ℹ️  Please initialize DB manually:"
    echo "   mysql -u root -proot < init_database.sql"
fi

# Start backend service
echo ""
echo "8) Start FitGo backend..."
echo "   🚀 Command: npm run dev"
echo ""
echo "   Backend info:"
echo "   - URL: http://localhost:3000"
echo "   - Health: http://localhost:3000/health"
echo "   - Stop: Ctrl + C"
echo ""
echo "========================================"
echo "Launch Flutter in another terminal:"
echo "  cd $FLUTTER_DIR"
echo "  flutter run"
echo "========================================"
echo ""

# 启动开发服务器
npm run dev

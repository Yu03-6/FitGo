# FitGo

AI 驱动的健身餐食规划应用。根据你的身体数据和饮食偏好，自动生成个性化的每周膳食计划。

## 技术栈

| 层级 | 技术 |
|-------|-----------|
| 后端 | Node.js + Express |
| 数据库 | MySQL |
| 前端 | Flutter（Android / iOS / Web / Windows） |
| 第三方 API | Spoonacular（膳食规划）、Resend（邮件发送） |

## 功能

- 用户注册（邮箱 OTP 验证）
- 基于 JWT 的身份认证与密码重置
- 根据身高、体重、年龄、性别、活动量自动计算每日热量（TDEE）
- 通过 Spoonacular API 生成 AI 周膳食计划
- 支持多种饮食偏好：普通、素食、生酮、纯素
- 收藏与查看喜欢的膳食计划
- 支持排除过敏或不喜欢的食材

## 项目结构

```
FitGo/
├── backend/                  # Node.js API 服务
│   ├── controllers/          # 认证、膳食、用户逻辑
│   ├── middleware/            # JWT 认证中间件
│   ├── routes/               # Express 路由定义
│   ├── services/             # Spoonacular、邮件、用户服务
│   ├── utils/                # 热量计算器、邮件发送工具
│   ├── migrations/           # 数据库迁移文件
│   └── server.js             # 入口文件（端口 3000）
├── flutter/                  # Flutter 移动端/Web/桌面端
│   └── lib/
│       ├── models/           # 数据模型（JSON 序列化）
│       ├── providers/        # 认证与数据状态管理
│       ├── screens/          # 界面页面（引导、首页等）
│       ├── services/         # API 客户端、本地存储
│       └── router/           # 路由定义
├── schema.sql                # 数据库结构参考
└── start-app.sh              # 一键启动脚本
```

## 快速开始

### 环境要求

- **Node.js** 18+
- **MySQL** 8.0+
- **Flutter SDK** 3.0+

### 1. 创建数据库

```bash
mysql -u root -p < schema.sql
```

### 2. 启动后端

```bash
cd backend
cp .env.example .env
```

编辑 `.env`，填入你的实际配置：

```env
MYSQL_HOST=localhost
MYSQL_PORT=3306
MYSQL_USER=root
MYSQL_PASSWORD=你的MySQL密码
MYSQL_DATABASE=fitgo

JWT_SECRET=你的JWT密钥
JWT_EXPIRY=7d

SPOONACULAR_API_KEY=你的Spoonacular_API密钥
SPOONACULAR_BASE_URL=https://api.spoonacular.com/mealplanner/generate

RESEND_API_KEY=你的Resend_API密钥
RESEND_FROM_EMAIL=no-reply@你的域名.com
```

```bash
npm install
npm run dev
```

API 服务启动在 `http://localhost:3000`。

### 3. 启动 Flutter 应用

```bash
cd flutter
flutter pub get
flutter run
```

### 一键启动

```bash
bash start-app.sh    # macOS / Linux
.\start-app.ps1      # Windows PowerShell
```

## API 接口

| 方法 | 路径 | 说明 |
|--------|------|-------------|
| POST | `/api/auth/register` | 注册（发送邮箱验证码） |
| POST | `/api/auth/verify-otp` | 验证注册 OTP |
| POST | `/api/auth/login` | 邮箱密码登录 |
| POST | `/api/auth/forgot-password` | 请求密码重置 |
| POST | `/api/auth/reset-password` | 通过 OTP 重置密码 |
| GET | `/api/meal/generate` | 生成膳食计划（需登录） |
| POST | `/api/meal/save` | 保存膳食计划（需登录） |
| GET | `/api/meal/saved` | 获取已保存的膳食计划（需登录） |
| GET | `/api/user/profile` | 获取用户资料（需登录） |
| PUT | `/api/user/profile` | 更新用户资料（需登录） |

## 环境变量说明

| 变量 | 说明 |
|----------|-------------|
| `MYSQL_HOST` | MySQL 主机地址 |
| `MYSQL_PORT` | MySQL 端口 |
| `MYSQL_USER` | MySQL 用户名 |
| `MYSQL_PASSWORD` | MySQL 密码 |
| `MYSQL_DATABASE` | 数据库名称 |
| `JWT_SECRET` | JWT 签名密钥 |
| `JWT_EXPIRY` | Token 过期时间 |
| `SPOONACULAR_API_KEY` | [Spoonacular API](https://spoonacular.com/food-api) 密钥 |
| `RESEND_API_KEY` | [Resend](https://resend.com) API 密钥（邮件服务） |
| `RESEND_FROM_EMAIL` | 发件人邮箱地址 |
| `PORT` | 服务器端口（默认: 3000） |

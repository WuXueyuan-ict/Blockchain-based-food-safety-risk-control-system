#!/bin/bash

# 食品安全追溯系统后端重启脚本
echo "🔄 重启食品安全追溯系统后端服务..."

# 进入后端目录
cd "$(dirname "$0")"

# 停止现有服务
echo "🛑 停止现有服务..."
./stop_backend.sh

# 等待服务完全停止
sleep 3

# 编译项目
echo "📦 重新编译项目..."
mvn compile -q

if [ $? -ne 0 ]; then
    echo "❌ 项目编译失败"
    exit 1
fi

# 启动服务
echo "🚀 启动服务..."
./start_backend.sh

echo "✅ 重启完成"

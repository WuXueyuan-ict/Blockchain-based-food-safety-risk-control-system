#!/bin/bash

# 食品安全追溯系统后端停止脚本
echo "🛑 停止食品安全追溯系统后端服务..."

# 进入后端目录
cd "$(dirname "$0")"

# 检查PID文件是否存在
if [ -f backend.pid ]; then
    PID=$(cat backend.pid)
    if ps -p $PID > /dev/null 2>&1; then
        echo "📝 找到运行中的服务 (PID: $PID)"
        kill $PID
        echo "⏳ 等待服务停止..."
        
        # 等待最多10秒让服务正常关闭
        for i in {1..10}; do
            if ! ps -p $PID > /dev/null 2>&1; then
                echo "✅ 服务已正常停止"
                rm -f backend.pid
                exit 0
            fi
            sleep 1
        done
        
        # 如果还没停止，强制杀死
        echo "⚠️  强制停止服务..."
        kill -9 $PID 2>/dev/null
        rm -f backend.pid
        echo "✅ 服务已强制停止"
    else
        echo "⚠️  PID文件存在但进程不存在，清理PID文件"
        rm -f backend.pid
    fi
else
    echo "📝 查找Spring Boot进程..."
    PIDS=$(pgrep -f "spring-boot:run" || pgrep -f "food.*safety.*platform")
    
    if [ -n "$PIDS" ]; then
        echo "找到以下进程："
        echo "$PIDS"
        echo "🛑 停止这些进程..."
        echo "$PIDS" | xargs kill
        sleep 3
        
        # 检查是否还有残留进程
        REMAINING=$(pgrep -f "spring-boot:run" || pgrep -f "food.*safety.*platform")
        if [ -n "$REMAINING" ]; then
            echo "⚠️  强制停止残留进程..."
            echo "$REMAINING" | xargs kill -9
        fi
        echo "✅ 所有相关进程已停止"
    else
        echo "ℹ️  没有找到运行中的后端服务"
    fi
fi

echo "🏁 停止操作完成"

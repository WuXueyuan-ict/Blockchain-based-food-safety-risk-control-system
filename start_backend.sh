#!/bin/bash

# 食品安全追溯系统后端启动脚本
echo "🚀 启动食品安全追溯系统后端服务..."

# 检查Java环境
if ! command -v java &> /dev/null; then
    echo "❌ 错误：未找到Java环境，请安装Java 17或更高版本"
    exit 1
fi

# 检查Maven环境
if ! command -v mvn &> /dev/null; then
    echo "❌ 错误：未找到Maven，请安装Maven"
    exit 1
fi

# 进入后端目录
cd "$(dirname "$0")"

# 清理并编译项目
echo "📦 编译项目..."
mvn clean compile -q

if [ $? -ne 0 ]; then
    echo "❌ 项目编译失败"
    exit 1
fi

# 启动应用
echo "🔥 启动应用（端口：8645）..."
echo "📝 日志将保存到 startup.log"

# 使用后台运行模式
nohup mvn spring-boot:run -Dspring-boot.run.jvmArguments="-Xmx2g -Xms1g" > startup.log 2>&1 &

# 保存进程ID
echo $! > backend.pid

echo "✅ 后端服务启动成功！"
echo "📊 服务地址: http://localhost:8645"
echo "📋 API文档: http://localhost:8645/swagger-ui/index.html"
echo "❤️  健康检查: http://localhost:8645/actuator/health"
echo "📄 查看日志: tail -f startup.log"
echo "🛑 停止服务: pkill -f spring-boot:run 或者 kill \$(cat backend.pid)"

# 等待几秒检查服务是否正常启动
sleep 5

if ps -p $(cat backend.pid) > /dev/null; then
    echo "🎉 服务运行正常"
else
    echo "⚠️  服务可能启动失败，请检查日志: cat startup.log"
fi

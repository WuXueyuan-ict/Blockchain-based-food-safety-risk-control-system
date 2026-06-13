#!/bin/bash

# 食品安全追溯系统 - Flutter离线构建脚本
# 解决Gradle网络下载超时问题

echo "🚀 开始Flutter离线构建..."

# 1. 清理项目
echo "📦 清理项目缓存..."
flutter clean
flutter pub get

# 2. 设置Gradle离线模式
echo "⚙️ 配置Gradle离线模式..."
export GRADLE_OPTS="-Dorg.gradle.daemon=false -Dorg.gradle.parallel=false"

# 3. 使用本地Gradle构建
echo "🔨 使用本地Gradle构建..."
cd android
gradle assembleDebug --offline --no-daemon
cd ..

echo "✅ 构建完成！"
echo "📱 APK文件位置: android/app/build/outputs/apk/debug/app-debug.apk"

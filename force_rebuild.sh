#!/bin/bash

# 强制重新构建Flutter应用
# Force rebuild Flutter app

echo "🔧 开始强制重新构建..."

# 1. 停止所有Flutter进程
echo "⏹️ 停止Flutter进程..."
pkill -f flutter || true

# 2. 清理Flutter缓存
echo "🧹 清理Flutter缓存..."
flutter clean

# 3. 清理pub缓存
echo "📦 清理pub缓存..."
flutter pub cache clean

# 4. 重新获取依赖
echo "📥 重新获取依赖..."
flutter pub get

# 5. 清理Android构建缓存
echo "🤖 清理Android构建缓存..."
cd android
./gradlew clean
cd ..

# 6. 删除构建目录
echo "🗑️ 删除构建目录..."
rm -rf build/
rm -rf .dart_tool/

# 7. 重新获取依赖
echo "📥 再次获取依赖..."
flutter pub get

# 8. 检查Flutter环境
echo "🔍 检查Flutter环境..."
flutter doctor

# 9. 尝试构建
echo "🏗️ 开始构建..."
flutter run --debug

echo "✅ 强制重新构建完成！"

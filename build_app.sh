#!/bin/bash

echo "🔧 设置Flutter编译环境..."

# 使用Java 17
export JAVA_HOME=/Users/hb/Library/Java/JavaVirtualMachines/corretto-17.0.14/Contents/Home
export PATH=$JAVA_HOME/bin:$PATH

echo "✅ Java版本设置为:"
java -version

echo "📦 获取依赖..."
flutter pub get

echo "🔨 直接使用本地Gradle编译..."
cd android
/opt/homebrew/bin/gradle assembleDebug
cd ..

echo "🎉 编译完成！"

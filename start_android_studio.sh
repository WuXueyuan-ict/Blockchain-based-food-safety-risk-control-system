#!/bin/bash

echo "🔧 配置Android Studio环境..."

# 设置Java 17
export JAVA_HOME=/Users/hb/Library/Java/JavaVirtualMachines/corretto-17.0.14/Contents/Home
export PATH=$JAVA_HOME/bin:$PATH

# 设置Android SDK
export ANDROID_HOME=/Users/hb/Library/Android/sdk
export PATH=$ANDROID_HOME/tools:$ANDROID_HOME/platform-tools:$PATH

# 设置Flutter
export FLUTTER_HOME=/Users/hb/Downloads/flutter
export PATH=$FLUTTER_HOME/bin:$PATH

# 设置Gradle
export GRADLE_HOME=/opt/homebrew/Cellar/gradle/8.14
export PATH=$GRADLE_HOME/bin:$PATH

echo "✅ 环境变量设置完成:"
echo "JAVA_HOME: $JAVA_HOME"
echo "ANDROID_HOME: $ANDROID_HOME"
echo "FLUTTER_HOME: $FLUTTER_HOME"
echo "GRADLE_HOME: $GRADLE_HOME"

echo "🚀 启动Android Studio..."
# 启动Android Studio（如果已安装）
if [ -d "/Applications/Android Studio.app" ]; then
    open -a "Android Studio" .
else
    echo "❌ 未找到Android Studio，请手动启动并导入项目"
    echo "项目路径: $(pwd)"
fi

echo "📝 Android Studio配置提醒:"
echo "1. File → Project Structure → SDK Location"
echo "   - JDK location: $JAVA_HOME"
echo "   - Android SDK location: $ANDROID_HOME"
echo ""
echo "2. File → Settings → Build → Gradle"
echo "   - Gradle JVM: Project SDK (corretto-17)"
echo "   - Use Gradle from: Specified location → /opt/homebrew/bin/gradle"
echo ""
echo "3. 如果还有问题，请使用我们的编译脚本: ./build_app.sh"

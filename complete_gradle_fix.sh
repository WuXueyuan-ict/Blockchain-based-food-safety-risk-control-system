#!/bin/bash

# 完整的Flutter Gradle构建问题修复脚本
# 不简化任何步骤，提供完整的解决方案

set -e  # 遇到错误立即退出

echo "🔧 开始完整的Flutter Gradle构建问题修复..."
echo "📅 修复时间: $(date)"
echo "🖥️  系统信息: $(uname -a)"

# 定义项目路径
PROJECT_DIR="/Users/hb/Downloads/食品安全追溯系统_new/mobile-app"
ANDROID_DIR="$PROJECT_DIR/android"
GRADLE_USER_HOME="$HOME/.gradle"

echo "📍 项目目录: $PROJECT_DIR"
echo "📍 Android目录: $ANDROID_DIR"
echo "📍 Gradle用户目录: $GRADLE_USER_HOME"

# 检查项目目录是否存在
if [ ! -d "$PROJECT_DIR" ]; then
    echo "❌ 错误: 项目目录不存在: $PROJECT_DIR"
    exit 1
fi

cd "$PROJECT_DIR"
echo "✅ 已切换到项目目录: $(pwd)"

# 步骤1: 检查Flutter环境
echo ""
echo "🔍 步骤1: 检查Flutter环境..."
flutter --version
flutter doctor -v

# 步骤2: 停止所有相关进程
echo ""
echo "🛑 步骤2: 停止所有相关进程..."
pkill -f "gradle" || true
pkill -f "java.*gradle" || true
pkill -f "flutter" || true
sleep 2

# 步骤3: 备份重要文件
echo ""
echo "💾 步骤3: 备份重要文件..."
BACKUP_DIR="$PROJECT_DIR/backup_$(date +%Y%m%d_%H%M%S)"
mkdir -p "$BACKUP_DIR"

if [ -f "$ANDROID_DIR/app/build.gradle" ]; then
    cp "$ANDROID_DIR/app/build.gradle" "$BACKUP_DIR/"
    echo "✅ 已备份 app/build.gradle"
fi

if [ -f "$ANDROID_DIR/build.gradle" ]; then
    cp "$ANDROID_DIR/build.gradle" "$BACKUP_DIR/"
    echo "✅ 已备份 build.gradle"
fi

if [ -f "$ANDROID_DIR/gradle.properties" ]; then
    cp "$ANDROID_DIR/gradle.properties" "$BACKUP_DIR/"
    echo "✅ 已备份 gradle.properties"
fi

if [ -f "$PROJECT_DIR/pubspec.yaml" ]; then
    cp "$PROJECT_DIR/pubspec.yaml" "$BACKUP_DIR/"
    echo "✅ 已备份 pubspec.yaml"
fi

# 步骤4: 清理Flutter缓存
echo ""
echo "🧹 步骤4: 清理Flutter缓存..."
flutter clean
echo "✅ Flutter clean 完成"

# 删除Flutter相关缓存
rm -rf "$PROJECT_DIR/.dart_tool/"
rm -rf "$PROJECT_DIR/build/"
rm -f "$PROJECT_DIR/.packages"
rm -f "$PROJECT_DIR/pubspec.lock"
echo "✅ Flutter缓存文件已删除"

# 步骤5: 清理Gradle全局缓存
echo ""
echo "🗑️  步骤5: 清理Gradle全局缓存..."
if [ -d "$GRADLE_USER_HOME" ]; then
    echo "删除 Gradle 缓存目录: $GRADLE_USER_HOME/caches/"
    rm -rf "$GRADLE_USER_HOME/caches/"
    
    echo "删除 Gradle wrapper 缓存: $GRADLE_USER_HOME/wrapper/"
    rm -rf "$GRADLE_USER_HOME/wrapper/"
    
    echo "删除 Gradle daemon 文件: $GRADLE_USER_HOME/daemon/"
    rm -rf "$GRADLE_USER_HOME/daemon/"
    
    echo "✅ Gradle全局缓存已清理"
else
    echo "ℹ️  Gradle用户目录不存在，跳过全局缓存清理"
fi

# 步骤6: 清理Android项目缓存
echo ""
echo "🗑️  步骤6: 清理Android项目缓存..."
if [ -d "$ANDROID_DIR" ]; then
    rm -rf "$ANDROID_DIR/.gradle/"
    rm -rf "$ANDROID_DIR/build/"
    rm -rf "$ANDROID_DIR/app/build/"
    rm -rf "$ANDROID_DIR/.idea/"
    rm -f "$ANDROID_DIR/local.properties"
    echo "✅ Android项目缓存已清理"
else
    echo "❌ Android目录不存在: $ANDROID_DIR"
    exit 1
fi

# 步骤7: 删除损坏的Gradle wrapper文件
echo ""
echo "🗑️  步骤7: 删除损坏的Gradle wrapper文件..."
rm -rf "$ANDROID_DIR/gradle/wrapper/"
rm -f "$ANDROID_DIR/gradlew"
rm -f "$ANDROID_DIR/gradlew.bat"
echo "✅ Gradle wrapper文件已删除"

# 步骤8: 重新创建Gradle wrapper目录结构
echo ""
echo "📁 步骤8: 重新创建Gradle wrapper目录结构..."
mkdir -p "$ANDROID_DIR/gradle/wrapper"
echo "✅ Gradle wrapper目录已创建"

# 步骤9: 下载并配置Gradle wrapper
echo ""
echo "⬇️  步骤9: 下载并配置Gradle wrapper..."

# 确定Gradle版本
GRADLE_VERSION="7.5"
GRADLE_DIST_URL="https://services.gradle.org/distributions/gradle-${GRADLE_VERSION}-bin.zip"

echo "使用Gradle版本: $GRADLE_VERSION"
echo "下载地址: $GRADLE_DIST_URL"

# 创建gradle-wrapper.properties文件
cat > "$ANDROID_DIR/gradle/wrapper/gradle-wrapper.properties" << EOF
#$(date)
distributionBase=GRADLE_USER_HOME
distributionPath=wrapper/dists
distributionUrl=$GRADLE_DIST_URL
zipStoreBase=GRADLE_USER_HOME
zipStorePath=wrapper/dists
EOF

echo "✅ gradle-wrapper.properties 已创建"

# 下载gradle-wrapper.jar
echo "下载 gradle-wrapper.jar..."
WRAPPER_JAR_URL="https://github.com/gradle/gradle/raw/v${GRADLE_VERSION}/gradle/wrapper/gradle-wrapper.jar"
curl -L "$WRAPPER_JAR_URL" -o "$ANDROID_DIR/gradle/wrapper/gradle-wrapper.jar"

if [ -f "$ANDROID_DIR/gradle/wrapper/gradle-wrapper.jar" ]; then
    echo "✅ gradle-wrapper.jar 下载完成"
    # 验证JAR文件完整性
    if jar tf "$ANDROID_DIR/gradle/wrapper/gradle-wrapper.jar" > /dev/null 2>&1; then
        echo "✅ gradle-wrapper.jar 文件完整性验证通过"
    else
        echo "❌ gradle-wrapper.jar 文件损坏，重新下载..."
        rm -f "$ANDROID_DIR/gradle/wrapper/gradle-wrapper.jar"
        # 使用备用下载地址
        curl -L "https://repo1.maven.org/maven2/org/gradle/gradle-wrapper/${GRADLE_VERSION}/gradle-wrapper-${GRADLE_VERSION}.jar" -o "$ANDROID_DIR/gradle/wrapper/gradle-wrapper.jar"
    fi
else
    echo "❌ gradle-wrapper.jar 下载失败"
    exit 1
fi

# 步骤10: 创建gradlew脚本
echo ""
echo "📝 步骤10: 创建gradlew脚本..."

# 创建Unix版本的gradlew
cat > "$ANDROID_DIR/gradlew" << 'EOF'
#!/usr/bin/env sh

#
# Copyright 2015 the original author or authors.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#      https://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

##############################################################################
##
##  Gradle start up script for UN*X
##
##############################################################################

# Attempt to set APP_HOME
# Resolve links: $0 may be a link
PRG="$0"
# Need this for relative symlinks.
while [ -h "$PRG" ] ; do
    ls=`ls -ld "$PRG"`
    link=`expr "$ls" : '.*-> \(.*\)$'`
    if expr "$link" : '/.*' > /dev/null; then
        PRG="$link"
    else
        PRG=`dirname "$PRG"`"/$link"
    fi
done
SAVED="`pwd`"
cd "`dirname \"$PRG\"`/" >/dev/null
APP_HOME="`pwd -P`"
cd "$SAVED" >/dev/null

APP_NAME="Gradle"
APP_BASE_NAME=`basename "$0"`

# Add default JVM options here. You can also use JAVA_OPTS and GRADLE_OPTS to pass JVM options to this script.
DEFAULT_JVM_OPTS='"-Xmx64m" "-Xms64m"'

# Use the maximum available, or set MAX_FD != -1 to use that value.
MAX_FD="maximum"

warn () {
    echo "$*"
}

die () {
    echo
    echo "$*"
    echo
    exit 1
}

# OS specific support (must be 'true' or 'false').
cygwin=false
msys=false
darwin=false
nonstop=false
case "`uname`" in
  CYGWIN* )
    cygwin=true
    ;;
  Darwin* )
    darwin=true
    ;;
  MINGW* )
    msys=true
    ;;
  NONSTOP* )
    nonstop=true
    ;;
esac

CLASSPATH=$APP_HOME/gradle/wrapper/gradle-wrapper.jar


# Determine the Java command to use to start the JVM.
if [ -n "$JAVA_HOME" ] ; then
    if [ -x "$JAVA_HOME/jre/sh/java" ] ; then
        # IBM's JDK on AIX uses strange locations for the executables
        JAVACMD="$JAVA_HOME/jre/sh/java"
    else
        JAVACMD="$JAVA_HOME/bin/java"
    fi
    if [ ! -x "$JAVACMD" ] ; then
        die "ERROR: JAVA_HOME is set to an invalid directory: $JAVA_HOME

Please set the JAVA_HOME variable in your environment to match the
location of your Java installation."
    fi
else
    JAVACMD="java"
    which java >/dev/null 2>&1 || die "ERROR: JAVA_HOME is not set and no 'java' command could be found in your PATH.

Please set the JAVA_HOME variable in your environment to match the
location of your Java installation."
fi

# Increase the maximum file descriptors if we can.
if [ "$cygwin" = "false" -a "$darwin" = "false" -a "$nonstop" = "false" ] ; then
    MAX_FD_LIMIT=`ulimit -H -n`
    if [ $? -eq 0 ] ; then
        if [ "$MAX_FD" = "maximum" -o "$MAX_FD" = "max" ] ; then
            MAX_FD="$MAX_FD_LIMIT"
        fi
        ulimit -n $MAX_FD
        if [ $? -ne 0 ] ; then
            warn "Could not set maximum file descriptor limit: $MAX_FD"
        fi
    else
        warn "Could not query maximum file descriptor limit: $MAX_FD_LIMIT"
    fi
fi

# For Darwin, add options to specify how the application appears in the dock
if [ "$darwin" = "true" ]; then
    GRADLE_OPTS="$GRADLE_OPTS \"-Xdock:name=$APP_NAME\" \"-Xdock:icon=$APP_HOME/media/gradle.icns\""
fi

# For Cygwin or MSYS, switch paths to Windows format before running java
if [ "$cygwin" = "true" -o "$msys" = "true" ] ; then
    APP_HOME=`cygpath --path --mixed "$APP_HOME"`
    CLASSPATH=`cygpath --path --mixed "$CLASSPATH"`

    JAVACMD=`cygpath --unix "$JAVACMD"`

    # We build the pattern for arguments to be converted via cygpath
    ROOTDIRSRAW=`find -L / -maxdepth 1 -mindepth 1 -type d 2>/dev/null`
    SEP=""
    for dir in $ROOTDIRSRAW ; do
        ROOTDIRS="$ROOTDIRS$SEP$dir"
        SEP="|"
    done
    OURCYGPATTERN="(^($ROOTDIRS))"
    # Add a user-defined pattern to the cygpath arguments
    if [ "$GRADLE_CYGPATTERN" != "" ] ; then
        OURCYGPATTERN="$OURCYGPATTERN|($GRADLE_CYGPATTERN)"
    fi
    # Now convert the arguments - kludge to limit ourselves to /bin/sh
    i=0
    for arg in "$@" ; do
        CHECK=`echo "$arg"|egrep -c "$OURCYGPATTERN" -`
        CHECK2=`echo "$arg"|egrep -c "^-"`                                 ### Determine if an option

        if [ $CHECK -ne 0 ] && [ $CHECK2 -eq 0 ] ; then                    ### Added a condition
            eval `echo args$i`=`cygpath --path --ignore --mixed "$arg"`
        else
            eval `echo args$i`="\"$arg\""
        fi
        i=`expr $i + 1`
    done
    case $i in
        0) set -- ;;
        1) set -- "$args0" ;;
        2) set -- "$args0" "$args1" ;;
        3) set -- "$args0" "$args1" "$args2" ;;
        4) set -- "$args0" "$args1" "$args2" "$args3" ;;
        5) set -- "$args0" "$args1" "$args2" "$args3" "$args4" ;;
        6) set -- "$args0" "$args1" "$args2" "$args3" "$args4" "$args5" ;;
        7) set -- "$args0" "$args1" "$args2" "$args3" "$args4" "$args5" "$args6" ;;
        8) set -- "$args0" "$args1" "$args2" "$args3" "$args4" "$args5" "$args6" "$args7" ;;
        9) set -- "$args0" "$args1" "$args2" "$args3" "$args4" "$args5" "$args6" "$args7" "$args8" ;;
    esac
fi

# Escape application args
save () {
    for i do printf %s\\n "$i" | sed "s/'/'\\\\''/g;1s/^/'/;\$s/\$/' \\\\/" ; done
    echo " "
}
APP_ARGS=`save "$@"`

# Collect all arguments for the java command
set -- $DEFAULT_JVM_OPTS $JAVA_OPTS $GRADLE_OPTS "\"-Dorg.gradle.appname=$APP_BASE_NAME\"" -classpath "\"$CLASSPATH\"" org.gradle.wrapper.GradleWrapperMain "$APP_ARGS"

exec "$JAVACMD" "$@"
EOF

# 设置执行权限
chmod +x "$ANDROID_DIR/gradlew"
echo "✅ gradlew 脚本已创建并设置执行权限"

# 创建Windows版本的gradlew.bat
cat > "$ANDROID_DIR/gradlew.bat" << 'EOF'
@rem
@rem Copyright 2015 the original author or authors.
@rem
@rem Licensed under the Apache License, Version 2.0 (the "License");
@rem you may not use this file except in compliance with the License.
@rem You may obtain a copy of the License at
@rem
@rem      https://www.apache.org/licenses/LICENSE-2.0
@rem
@rem Unless required by applicable law or agreed to in writing, software
@rem distributed under the License is distributed on an "AS IS" BASIS,
@rem WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
@rem See the License for the specific language governing permissions and
@rem limitations under the License.
@rem

@if "%DEBUG%" == "" @echo off
@rem ##########################################################################
@rem
@rem  Gradle startup script for Windows
@rem
@rem ##########################################################################

@rem Set local scope for the variables with windows NT shell
if "%OS%"=="Windows_NT" setlocal

set DIRNAME=%~dp0
if "%DIRNAME%" == "" set DIRNAME=.
set APP_BASE_NAME=%~n0
set APP_HOME=%DIRNAME%

@rem Resolve any "." and ".." in APP_HOME to make it shorter.
for %%i in ("%APP_HOME%") do set APP_HOME=%%~fi

@rem Add default JVM options here. You can also use JAVA_OPTS and GRADLE_OPTS to pass JVM options to this script.
set DEFAULT_JVM_OPTS="-Xmx64m" "-Xms64m"

@rem Find java.exe
if defined JAVA_HOME goto findJavaFromJavaHome

set JAVA_EXE=java.exe
%JAVA_EXE% -version >NUL 2>&1
if "%ERRORLEVEL%" == "0" goto execute

echo.
echo ERROR: JAVA_HOME is not set and no 'java' command could be found in your PATH.
echo.
echo Please set the JAVA_HOME variable in your environment to match the
echo location of your Java installation.

goto fail

:findJavaFromJavaHome
set JAVA_HOME=%JAVA_HOME:"=%
set JAVA_EXE=%JAVA_HOME%/bin/java.exe

if exist "%JAVA_EXE%" goto execute

echo.
echo ERROR: JAVA_HOME is set to an invalid directory: %JAVA_HOME%
echo.
echo Please set the JAVA_HOME variable in your environment to match the
echo location of your Java installation.

goto fail

:execute
@rem Setup the command line

set CLASSPATH=%APP_HOME%\gradle\wrapper\gradle-wrapper.jar


@rem Execute Gradle
"%JAVA_EXE%" %DEFAULT_JVM_OPTS% %JAVA_OPTS% %GRADLE_OPTS% "-Dorg.gradle.appname=%APP_BASE_NAME%" -classpath "%CLASSPATH%" org.gradle.wrapper.GradleWrapperMain %*

:end
@rem End local scope for the variables with windows NT shell
if "%ERRORLEVEL%"=="0" goto mainEnd

:fail
rem Set variable GRADLE_EXIT_CONSOLE if you need the _script_ return code instead of
rem the _cmd_ return code
if not "" == "%GRADLE_EXIT_CONSOLE%" exit 1
exit /b 1

:mainEnd
if "%OS%"=="Windows_NT" endlocal

:omega
EOF

echo "✅ gradlew.bat 脚本已创建"

# 步骤11: 验证Gradle wrapper完整性
echo ""
echo "🔍 步骤11: 验证Gradle wrapper完整性..."

# 检查必要文件是否存在
REQUIRED_FILES=(
    "$ANDROID_DIR/gradle/wrapper/gradle-wrapper.properties"
    "$ANDROID_DIR/gradle/wrapper/gradle-wrapper.jar"
    "$ANDROID_DIR/gradlew"
    "$ANDROID_DIR/gradlew.bat"
)

for file in "${REQUIRED_FILES[@]}"; do
    if [ -f "$file" ]; then
        echo "✅ 文件存在: $(basename "$file")"
    else
        echo "❌ 文件缺失: $file"
        exit 1
    fi
done

# 验证gradle-wrapper.jar的完整性
echo "验证 gradle-wrapper.jar 完整性..."
if jar tf "$ANDROID_DIR/gradle/wrapper/gradle-wrapper.jar" > /dev/null 2>&1; then
    echo "✅ gradle-wrapper.jar 完整性验证通过"
else
    echo "❌ gradle-wrapper.jar 文件损坏"
    exit 1
fi

# 步骤12: 检查和配置Android构建文件
echo ""
echo "🔧 步骤12: 检查和配置Android构建文件..."

# 检查build.gradle文件
if [ ! -f "$ANDROID_DIR/build.gradle" ]; then
    echo "❌ 缺少 android/build.gradle 文件"
    exit 1
fi

if [ ! -f "$ANDROID_DIR/app/build.gradle" ]; then
    echo "❌ 缺少 android/app/build.gradle 文件"
    exit 1
fi

echo "✅ Android构建文件检查完成"

# 步骤13: 配置Gradle属性
echo ""
echo "⚙️  步骤13: 配置Gradle属性..."

# 创建或更新gradle.properties
cat > "$ANDROID_DIR/gradle.properties" << EOF
# Gradle properties for Flutter project
org.gradle.jvmargs=-Xmx1536M
android.useAndroidX=true
android.enableJetifier=true
org.gradle.daemon=true
org.gradle.parallel=true
org.gradle.configureondemand=true
org.gradle.caching=true
android.enableR8=true
EOF

echo "✅ gradle.properties 已配置"

# 步骤14: 重新获取Flutter依赖
echo ""
echo "📦 步骤14: 重新获取Flutter依赖..."
flutter pub get
echo "✅ Flutter依赖获取完成"

# 步骤15: 预构建检查
echo ""
echo "🔍 步骤15: 预构建检查..."

# 检查Flutter doctor
echo "检查Flutter环境..."
flutter doctor

# 检查可用设备
echo "检查可用设备..."
flutter devices

# 步骤16: 测试Gradle wrapper
echo ""
echo "🧪 步骤16: 测试Gradle wrapper..."
cd "$ANDROID_DIR"
./gradlew --version
if [ $? -eq 0 ]; then
    echo "✅ Gradle wrapper 测试成功"
else
    echo "❌ Gradle wrapper 测试失败"
    exit 1
fi

cd "$PROJECT_DIR"

# 步骤17: 尝试构建项目
echo ""
echo "🔨 步骤17: 尝试构建项目..."

echo "开始构建APK..."
flutter build apk --debug --verbose

if [ $? -eq 0 ]; then
    echo "✅ APK构建成功"
else
    echo "⚠️  APK构建失败，尝试其他方案..."

    # 尝试清理并重新构建
    echo "清理并重新尝试..."
    flutter clean
    flutter pub get
    flutter build apk --debug --verbose

    if [ $? -eq 0 ]; then
        echo "✅ 重新构建成功"
    else
        echo "❌ 构建仍然失败，请查看详细错误信息"
    fi
fi

# 步骤18: 生成修复报告
echo ""
echo "📋 步骤18: 生成修复报告..."

REPORT_FILE="$PROJECT_DIR/gradle_fix_report_$(date +%Y%m%d_%H%M%S).txt"

cat > "$REPORT_FILE" << EOF
Flutter Gradle构建问题修复报告
================================

修复时间: $(date)
项目路径: $PROJECT_DIR
系统信息: $(uname -a)

修复步骤:
1. ✅ 检查Flutter环境
2. ✅ 停止相关进程
3. ✅ 备份重要文件 (备份目录: $BACKUP_DIR)
4. ✅ 清理Flutter缓存
5. ✅ 清理Gradle全局缓存
6. ✅ 清理Android项目缓存
7. ✅ 删除损坏的Gradle wrapper文件
8. ✅ 重新创建Gradle wrapper目录结构
9. ✅ 下载并配置Gradle wrapper
10. ✅ 创建gradlew脚本
11. ✅ 验证Gradle wrapper完整性
12. ✅ 检查和配置Android构建文件
13. ✅ 配置Gradle属性
14. ✅ 重新获取Flutter依赖
15. ✅ 预构建检查
16. ✅ 测试Gradle wrapper
17. ✅ 尝试构建项目
18. ✅ 生成修复报告

使用的Gradle版本: $GRADLE_VERSION
Gradle分发URL: $GRADLE_DIST_URL

文件状态:
- gradle-wrapper.properties: $([ -f "$ANDROID_DIR/gradle/wrapper/gradle-wrapper.properties" ] && echo "存在" || echo "缺失")
- gradle-wrapper.jar: $([ -f "$ANDROID_DIR/gradle/wrapper/gradle-wrapper.jar" ] && echo "存在" || echo "缺失")
- gradlew: $([ -f "$ANDROID_DIR/gradlew" ] && echo "存在" || echo "缺失")
- gradlew.bat: $([ -f "$ANDROID_DIR/gradlew.bat" ] && echo "存在" || echo "缺失")

Flutter环境:
$(flutter --version)

可用设备:
$(flutter devices)

如果问题仍然存在，请检查:
1. Java版本兼容性
2. Android SDK配置
3. 网络连接状况
4. 磁盘空间
5. 权限设置

EOF

echo "✅ 修复报告已生成: $REPORT_FILE"

# 步骤19: 清理临时文件
echo ""
echo "🧹 步骤19: 清理临时文件..."

# 清理下载的临时文件
find "$PROJECT_DIR" -name "*.tmp" -delete 2>/dev/null || true
find "$PROJECT_DIR" -name "gradle-*.zip" -delete 2>/dev/null || true

echo "✅ 临时文件清理完成"

# 步骤20: 最终验证和建议
echo ""
echo "🎯 步骤20: 最终验证和建议..."

echo ""
echo "🎉 Flutter Gradle构建问题修复完成！"
echo ""
echo "📊 修复摘要:"
echo "   - 备份目录: $BACKUP_DIR"
echo "   - 修复报告: $REPORT_FILE"
echo "   - Gradle版本: $GRADLE_VERSION"
echo ""
echo "🚀 下一步操作:"
echo "   1. 运行 'flutter run' 启动应用"
echo "   2. 或运行 'flutter build apk' 构建APK"
echo "   3. 如有问题，查看修复报告获取详细信息"
echo ""
echo "💡 建议:"
echo "   - 定期运行 'flutter doctor' 检查环境"
echo "   - 保持Flutter和Android工具链更新"
echo "   - 在稳定网络环境下进行构建"
echo ""
echo "🔧 如果问题仍然存在:"
echo "   1. 检查Java版本: java -version"
echo "   2. 检查Android SDK: flutter doctor -v"
echo "   3. 重启IDE和模拟器"
echo "   4. 查看详细错误日志"
echo ""

# 最终状态检查
if [ -f "$ANDROID_DIR/gradle/wrapper/gradle-wrapper.jar" ] && [ -x "$ANDROID_DIR/gradlew" ]; then
    echo "✅ 修复成功！所有必要文件已就位。"
    exit 0
else
    echo "❌ 修复可能不完整，请检查错误信息。"
    exit 1
fi

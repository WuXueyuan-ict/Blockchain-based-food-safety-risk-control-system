import 'dart:io';

/// 快速诊断脚本
/// 用于检查认证状态和API权限问题
void main() async {
  print('🔍 开始快速诊断...\n');

  // 1. 检查认证状态
  print('=' * 60);
  print('🔐 检查认证状态');
  print('=' * 60);

  print('❌ 无法直接访问GetStorage，请在应用内使用诊断工具');
  print('💡 建议使用应用内的诊断功能:');
  print('   1. 打开应用');
  print('   2. 导航到: /debug/auth-status');
  print('   3. 导航到: /debug/api-diagnosis');
  
  // 2. 分析403错误
  print('\n' + '=' * 60);
  print('🔍 403错误分析');
  print('=' * 60);

  print('❌ 403 Forbidden错误的常见原因:');
  print('   1. 未登录或缺少认证token');
  print('   2. Token已过期或无效');
  print('   3. Token权限不足');
  print('   4. 服务器端权限配置问题');
  print('   5. API端点需要特定的用户角色');

  print('\n💡 解决步骤:');
  print('   1. 确保用户已登录');
  print('   2. 检查token是否正确保存');
  print('   3. 验证token是否有效');
  print('   4. 确认用户权限设置');
  
  // 3. 检查网络配置
  print('\n' + '=' * 60);
  print('🌐 检查网络配置');
  print('=' * 60);

  print('📋 从日志中可以看到:');
  print('   URL: http://192.168.10.8:8645/api/app/ar/package/PROD_001');
  print('   状态码: 403 Forbidden');
  print('   ✅ 网络连接正常');
  print('   ❌ 权限验证失败');
  
  // 4. 检查API服务配置
  print('\n' + '=' * 60);
  print('🔧 检查API服务配置');
  print('=' * 60);
  
  final apiServiceFiles = [
    'lib/services/api_service.dart',
    'lib/services/risk_analysis_service.dart',
    'lib/services/ar_package_service.dart',
  ];
  
  for (final filePath in apiServiceFiles) {
    try {
      final file = File(filePath);
      if (await file.exists()) {
        final content = await file.readAsString();
        
        // 检查是否有认证拦截器
        final hasAuthInterceptor = content.contains('Authorization') || content.contains('Bearer');
        print('${hasAuthInterceptor ? "✅" : "❌"} $filePath: ${hasAuthInterceptor ? "有认证配置" : "缺少认证配置"}');
        
        // 检查是否有API日志
        final hasApiLogger = content.contains('ApiLoggerInterceptor') || content.contains('api_logger');
        print('${hasApiLogger ? "✅" : "❌"} $filePath: ${hasApiLogger ? "有API日志" : "缺少API日志"}');
      } else {
        print('❌ $filePath: 文件不存在');
      }
    } catch (e) {
      print('❌ $filePath: 检查失败 - $e');
    }
  }
  
  // 5. 生成修复建议
  print('\n' + '=' * 60);
  print('💡 修复建议');
  print('=' * 60);

  print('🔑 立即操作:');
  print('   1. 运行应用并登录');
  print('   2. 在应用中使用模拟登录功能');
  print('   3. 检查登录页面是否正确保存token');

  print('\n🔍 进一步诊断:');
  print('   1. 在应用中访问: /debug/auth-status');
  print('   2. 在应用中访问: /debug/api-diagnosis');
  print('   3. 检查API监控日志');
  
  print('\n🛠️  开发者操作:');
  print('   1. 检查后端API权限配置');
  print('   2. 验证token验证逻辑');
  print('   3. 确认用户角色权限设置');
  
  print('\n📱 应用内诊断:');
  print('   1. 打开应用');
  print('   2. 导航到设置 -> 调试工具');
  print('   3. 使用"认证状态检查"和"API诊断"功能');
  
  // 6. 应用内修复
  print('\n' + '=' * 60);
  print('⚡ 应用内修复');
  print('=' * 60);

  print('🔧 在应用中执行以下操作:');
  print('   1. 打开应用');
  print('   2. 导航到: /debug/auth-status');
  print('   3. 点击"模拟登录"按钮');
  print('   4. 使用"测试API"功能验证权限');
  print('   5. 查看详细的诊断结果');
  
  print('\n🎯 诊断完成!');
  print('如果问题仍然存在，请查看应用内的详细诊断工具。');
}

import 'dart:io';
import 'dart:convert';

/// 联调测试脚本
/// 用于检查API端点的可用性和响应
void main() async {
  print('🔧 开始API联调测试...\n');
  
  final baseUrl = 'http://192.168.10.8:8645/api';
  
  // 测试端点列表
  final endpoints = [
    // 基础健康检查
    {'name': '健康检查', 'path': '/health', 'method': 'GET', 'needsAuth': false},
    {'name': '服务状态', 'path': '/status', 'method': 'GET', 'needsAuth': false},
    
    // 用户相关
    {'name': '用户资料', 'path': '/users/profile', 'method': 'GET', 'needsAuth': true},
    {'name': '用户设置', 'path': '/users/settings', 'method': 'GET', 'needsAuth': true},
    
    // 安全指数
    {'name': '安全指数列表', 'path': '/safety/indexes?page=0&size=5', 'method': 'GET', 'needsAuth': true},
    
    // AR包装
    {'name': 'AR包装信息', 'path': '/app/ar/package/PROD_001', 'method': 'GET', 'needsAuth': true},
    
    // 风险分析
    {'name': '风险物质列表', 'path': '/v1/risk-analysis/substances', 'method': 'GET', 'needsAuth': true},
    
    // 产品
    {'name': '产品列表', 'path': '/v1/products?page=0&size=5', 'method': 'GET', 'needsAuth': true},
  ];
  
  print('📋 测试计划:');
  print('基础URL: $baseUrl');
  print('测试端点数量: ${endpoints.length}');
  print('=' * 60);
  
  int successCount = 0;
  int failedCount = 0;
  int warningCount = 0;
  
  for (int i = 0; i < endpoints.length; i++) {
    final endpoint = endpoints[i];
    final url = '$baseUrl${endpoint['path']}';
    
    print('\n${i + 1}. 测试: ${endpoint['name']}');
    print('   URL: $url');
    print('   方法: ${endpoint['method']}');
    print('   需要认证: ${endpoint['needsAuth'] == true ? "是" : "否"}');
    
    try {
      final result = await _testEndpoint(url, endpoint['method'] as String);
      
      if (result['success']) {
        print('   ✅ 成功 - 状态码: ${result['statusCode']}');
        print('   ⏱️  响应时间: ${result['responseTime']}ms');
        successCount++;
      } else {
        final statusCode = result['statusCode'];
        if (statusCode == 500) {
          print('   ⚠️  警告 - 服务器内部错误 (500)');
          print('   💡 这通常是后端代码问题，不是客户端问题');
          warningCount++;
        } else if (statusCode == 403) {
          print('   🔑 认证问题 - 权限不足 (403)');
          print('   💡 需要检查token或用户权限');
          failedCount++;
        } else if (statusCode == 404) {
          print('   ❌ 端点不存在 (404)');
          print('   💡 检查URL路径是否正确');
          failedCount++;
        } else {
          print('   ❌ 失败 - 状态码: $statusCode');
          failedCount++;
        }
        
        if (result['error'] != null) {
          print('   错误: ${result['error']}');
        }
      }
    } catch (e) {
      print('   ❌ 网络错误: $e');
      failedCount++;
    }
    
    // 添加延迟避免过快请求
    await Future.delayed(const Duration(milliseconds: 500));
  }
  
  // 打印总结
  print('\n' + '=' * 60);
  print('📊 联调测试总结');
  print('=' * 60);
  print('总测试数: ${endpoints.length}');
  print('✅ 成功: $successCount');
  print('⚠️  警告: $warningCount (服务器500错误)');
  print('❌ 失败: $failedCount');
  print('成功率: ${((successCount / endpoints.length) * 100).toStringAsFixed(1)}%');
  
  if (warningCount > 0) {
    print('\n💡 关于500错误:');
    print('- 500错误表示服务器内部错误');
    print('- 这通常是后端代码或数据库问题');
    print('- 客户端请求格式是正确的');
    print('- 需要后端开发者检查服务器日志');
  }
  
  if (failedCount > 0) {
    print('\n🔧 修复建议:');
    print('- 403错误: 检查认证token和用户权限');
    print('- 404错误: 检查API端点路径是否正确');
    print('- 网络错误: 检查服务器是否运行和网络连接');
  }
  
  print('\n📱 在移动应用中进行详细测试:');
  print('1. 打开应用');
  print('2. 导航到: /debug/api-integration-test');
  print('3. 使用联调测试工具进行详细测试');
  print('4. 查看完整的请求/响应信息');
}

Future<Map<String, dynamic>> _testEndpoint(String url, String method) async {
  final startTime = DateTime.now();
  
  try {
    final client = HttpClient();
    client.connectionTimeout = const Duration(seconds: 10);
    
    final uri = Uri.parse(url);
    final request = await client.openUrl(method, uri);
    
    // 添加基本请求头
    request.headers.set('Content-Type', 'application/json');
    request.headers.set('User-Agent', 'FoodSafetyApp/1.0');
    
    final response = await request.close();
    final endTime = DateTime.now();
    final responseTime = endTime.difference(startTime).inMilliseconds;
    
    final responseBody = await response.transform(utf8.decoder).join();
    
    client.close();
    
    return {
      'success': response.statusCode >= 200 && response.statusCode < 300,
      'statusCode': response.statusCode,
      'responseTime': responseTime,
      'responseBody': responseBody,
    };
  } catch (e) {
    final endTime = DateTime.now();
    final responseTime = endTime.difference(startTime).inMilliseconds;
    
    return {
      'success': false,
      'statusCode': null,
      'responseTime': responseTime,
      'error': e.toString(),
    };
  }
}

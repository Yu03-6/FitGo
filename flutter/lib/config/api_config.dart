/// API configuration
class ApiConfig {
  // ========================================
  // 根据运行环境选择正确的 API 地址：
  // ========================================
  // ✅ Windows桌面/Web开发: 用 localhost 或 127.0.0.1
  // ✅ Android模拟器: 用 10.0.2.2
  // ✅ 真机(iOS/Android)同一WiFi/热点: 用你电脑的局域网IP
  // ========================================
  // 当前热点IP: 172.20.10.2 (手机热点)
  // 旧WiFi IP: 192.168.31.115
  // ========================================
  static const String apiBaseUrl = 'http://172.20.10.2:3000';

  // 其他选项（按需取消注释）：
  //static const String apiBaseUrl = 'http://localhost:3000';
  //static const String apiBaseUrl = 'http://127.0.0.1:3000';
  //static const String apiBaseUrl = 'http://10.0.2.2:3000'; // Android模拟器

  static const int connectionTimeout = 30; // 秒
  static const int receiveTimeout = 30; // 秒
}

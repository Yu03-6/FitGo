import 'dart:io';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// 跨平台安全存储服务
/// - Web 平台使用 shared_preferences (因为 flutter_secure_storage 不支持 Web)
/// - 移动端/桌面端使用 flutter_secure_storage
class StorageService {
  final FlutterSecureStorage? _secureStorage;

  StorageService() : _secureStorage = kIsWeb ? null : const FlutterSecureStorage();

  /// 读取存储的值
  Future<String?> read({required String key}) async {
    try {
      if (kIsWeb) {
        final prefs = await SharedPreferences.getInstance();
        return prefs.getString(key);
      } else {
        return await _secureStorage!.read(key: key);
      }
    } catch (e) {
      print('StorageService.read error ($key): $e');
      // 降级到 shared_preferences
      try {
        final prefs = await SharedPreferences.getInstance();
        return prefs.getString(key);
      } catch (e2) {
        print('StorageService.read fallback also failed: $e2');
        return null;
      }
    }
  }

  /// 写入存储值
  Future<void> write({required String key, required String value}) async {
    try {
      if (kIsWeb) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString(key, value);
      } else {
        await _secureStorage!.write(key: key, value: value);
      }
    } catch (e) {
      print('StorageService.write error ($key): $e');
      // 降级到 shared_preferences
      try {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString(key, value);
      } catch (e2) {
        print('StorageService.write fallback also failed: $e2');
      }
    }
  }

  /// 删除存储的值
  Future<void> delete({required String key}) async {
    try {
      if (kIsWeb) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.remove(key);
      } else {
        await _secureStorage!.delete(key: key);
      }
    } catch (e) {
      print('StorageService.delete error ($key): $e');
      try {
        final prefs = await SharedPreferences.getInstance();
        await prefs.remove(key);
      } catch (e2) {
        print('StorageService.delete fallback also failed: $e2');
      }
    }
  }
}

import 'dart:convert';
import 'package:flutter/services.dart';

abstract class ConfigReader {
  static Map<String, dynamic>? _config;

  static Future<void> initialize() async {
    final configString = await rootBundle.loadString('config/app_config.json');
    _config = json.decode(configString) as Map<String, dynamic>;
  }

  static String getToken() {
    return _config!['TOKEN'] as String;
  }

  static String getApplicationId() {
    return _config!['APPLICATION_ID'] as String;
  }

  static String getGuildId() {
    return _config!['GUILD_ID'] as String;
  }

  static String getChannelId() {
    return _config!['CHANNEL_ID'] as String;
  }

  static String getVersion() {
    return _config!['VERSION'] as String;
  }

  static String getId() {
    return _config!['ID'] as String;
  }
}
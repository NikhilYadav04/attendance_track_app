import 'package:attendance_tracker/http/config/api_config.dart';

class ApiEndpoints {
  //* Auth
  static String get auth => '${ApiConfig.baseUrl}/api/auth';
  static String get deleteBackup => '${ApiConfig.baseUrl}/api/auth';

  //* Backup
  static String get addBackup => '${ApiConfig.baseUrl}/api/backup';
  static String getBackup(String name, String uniqueKey) =>
      '${ApiConfig.baseUrl}/api/backup/${name}/${uniqueKey}';

  //* Email
  static String get email => '${ApiConfig.baseUrl}/api/backup/email';
}

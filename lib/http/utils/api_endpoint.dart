import 'package:attendance_tracker/http/config/api_config.dart';

class ApiEndpoints {
  //* Backup

  //* for add and delete
  static String get backup => '${ApiConfig.baseUrl}/api/backup';

  static String get email => '${ApiConfig.baseUrl}/api/backup/email';

  //* for get backup
  static String get_backup(String name, String uniqueKey) =>
      '${ApiConfig.baseUrl}/api/backup/${name}/${uniqueKey}';
}

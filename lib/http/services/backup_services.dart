import 'package:attendance_tracker/http/models/api_response.dart';
import 'package:attendance_tracker/http/models/subject.dart';
import 'package:attendance_tracker/http/services/api_service.dart';
import 'package:attendance_tracker/http/utils/api_endpoint.dart';

class BackupServices extends ApiService {
  //* register user
  Future<ApiResponse<Map<String, dynamic>>> registerUser({
    required String name,
    required String nickName,
    required String collegeName,
  }) async {
    return post(
      ApiEndpoints.auth,
      data: {
        "name": name,
        "nickName": nickName,
        "collegeName": collegeName,
      },
      fromJson: (data) => data as Map<String, dynamic>,
    );
  }

  //* add backup
  Future<ApiResponse<Map<String, dynamic>>> addBackup({
    required String name,
    required String nickName,
    required String uniqueKey,
    required String collegeName,
    required List<Subject> subjects,
    required List<AttendanceRecord> attendanceRecords,
  }) async {
    return post(
      ApiEndpoints.addBackup,
      data: {
        "name": name,
        "nickName": nickName,
        "uniqueKey": uniqueKey,
        "collegeName": collegeName,
        "subjects": subjects.map((s) => s.toJson()).toList(),
        "attendanceRecords": attendanceRecords.map((a) => a.toJson()).toList(),
      },
      fromJson: (data) => data as Map<String, dynamic>,
    );
  }

  //* send email with key
  Future<ApiResponse<Map<String, dynamic>>> sendEmail({
    required String email,
    required String key,
  }) async {
    return post(
      ApiEndpoints.email,
      data: {
        "key": key,
        "email": email,
      },
      fromJson: (data) => data as Map<String, dynamic>,
    );
  }

  //* get backup
  Future<ApiResponse<Map<String, dynamic>>> getBackup({
    required String name,
    required String uniqueKey,
  }) async {
    return get(
      ApiEndpoints.getBackup(name, uniqueKey),
      fromJson: (data) => data as Map<String, dynamic>,
    );
  }

  //* delete user (backup)
  Future<ApiResponse<Map<String, dynamic>>> deleteBackup({
    required String name,
    required String uniqueKey,
  }) async {
    return delete(
      ApiEndpoints.deleteBackup,
      data: {
        "name": name,
        "uniqueKey": uniqueKey,
      },
      fromJson: (data) => data as Map<String, dynamic>,
    );
  }
}

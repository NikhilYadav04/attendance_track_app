import 'dart:convert';

import 'package:attendance_tracker/core/snackBar.dart';
import 'package:attendance_tracker/http/models/api_response.dart';
import 'package:attendance_tracker/http/models/subject.dart';
import 'package:attendance_tracker/http/models/user.dart';
import 'package:attendance_tracker/http/services/backup_services.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class BackupProvider extends ChangeNotifier {
  final BackupServices _backupServices = BackupServices();

  Future<void> addAttendanceBackup({
    required String uniqueKey,
    required BuildContext context,
  }) async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? userData = prefs.getString('user_data');

      if (userData == null || userData.isEmpty) {
        CustomSnackBar.show(
          context: context,
          icon: Icons.error,
          backgroundColor: Colors.red,
          title: "No Attendance Data Found to Save",
        );
        return;
      }

      final user = UserData.fromJson(jsonDecode(userData));

      List<AttendanceRecord> attendanceRecords =
          user.subjects.expand((subject) => subject.attendanceHistory).toList();

      await Future.delayed(Duration(milliseconds: 200));

      ApiResponse<Map<String, dynamic>> response =
          await _backupServices.addBackup(
        name: user.name,
        nickName: user.nickname,
        uniqueKey: uniqueKey,
        collegeName: user.collegeName,
        subjects: user.subjects,
        attendanceRecords: attendanceRecords,
      );

      if (response.statusCode == 200) {
        CustomSnackBar.show(
          context: context,
          icon: Icons.check_circle,
          backgroundColor: Colors.green,
          title: "Backup saved successfully ✅",
        );
      } else {
        CustomSnackBar.show(
            context: context,
            icon: Icons.error,
            backgroundColor: Colors.red,
            title: response.message);
      }
    } catch (e) {
      print("Error: ${e.toString()}");
      CustomSnackBar.show(
        context: context,
        icon: Icons.error,
        backgroundColor: Colors.red,
        title: "An unexpected error occurred",
      );
    }
  }

  //* send_email
  Future<void> sendEmail({
    required BuildContext context,
    required String email,
    required String uniqueKey,
  }) async {
    try {
      ApiResponse<Map<String, dynamic>> response =
          await _backupServices.sendEmail(email: email, key: uniqueKey);

      if (response.statusCode == 200) {
        CustomSnackBar.show(
          context: context,
          icon: Icons.email,
          backgroundColor: Colors.green,
          title: "Email sent successfully 📩",
        );
      } else {
        CustomSnackBar.show(
            context: context,
            icon: Icons.error,
            backgroundColor: Colors.red,
            title: response.message);
      }
    } catch (e) {
      print("Error: ${e.toString()}");
      CustomSnackBar.show(
        context: context,
        icon: Icons.error,
        backgroundColor: Colors.red,
        title: "An unexpected error occurred",
      );
    }
  }

  //* get_backup
  Future<void> getAttendanceRecord({
    required BuildContext context,
    required String name,
    required String uniqueKey,
  }) async {
    try {
      ApiResponse<Map<String, dynamic>> response =
          await _backupServices.getBackup(name: name, uniqueKey: uniqueKey);

      if (response.statusCode == 200) {
        Map<String, dynamic> user = response.data!["user"];

        //* ✅ Correctly map subjects list
        List<Subject> subjects = (user["Subject"] as List<dynamic>)
            .map((subjectJson) => Subject.fromJson(subjectJson))
            .toList();

        UserData userModel = UserData(
          name: user["name"],
          nickname: user["nickName"],
          collegeName: user["collegeName"],
          subjects: subjects,
        );

        SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.setString('user_data', jsonEncode(userModel.toJson()));

        CustomSnackBar.show(
          context: context,
          icon: Icons.check_circle,
          backgroundColor: Colors.green,
          title: "Backup restored successfully ✅",
        );
      } else {
        CustomSnackBar.show(
          context: context,
          icon: Icons.error,
          backgroundColor: Colors.red,
          title: response.message,
        );
      }
    } catch (e) {
      print("Error: ${e.toString()}");
      CustomSnackBar.show(
        context: context,
        icon: Icons.error,
        backgroundColor: Colors.red,
        title: "An unexpected error occurred",
      );
    }
  }

  //* delete_user
  Future<void> deleteAttendanceBackup({
    required String uniqueKey,
    required BuildContext context,
  }) async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? userData = prefs.getString('user_data');

      if (userData == null || userData.isEmpty) {
        CustomSnackBar.show(
          context: context,
          icon: Icons.error,
          backgroundColor: Colors.red,
          title: "No Attendance Data Found to Delete",
        );
        return;
      }

      final user = UserData.fromJson(jsonDecode(userData));

      await Future.delayed(Duration(milliseconds: 200));

      ApiResponse<Map<String, dynamic>> response =
          await _backupServices.deleteBackup(
        name: user.name,
        uniqueKey: uniqueKey,
      );

      if (response.statusCode == 200) {
        CustomSnackBar.show(
          context: context,
          icon: Icons.delete_forever,
          backgroundColor: Colors.green,
          title: "Backup deleted successfully 🗑️",
        );
      } else {
        CustomSnackBar.show(
            context: context,
            icon: Icons.error,
            backgroundColor: Colors.red,
            title: response.message);
      }
    } catch (e) {
      print("Error: ${e.toString()}");
      CustomSnackBar.show(
        context: context,
        icon: Icons.error,
        backgroundColor: Colors.red,
        title: "An unexpected error occurred",
      );
    }
  }
}

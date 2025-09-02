import 'dart:convert';

import 'package:attendance_tracker/core/snackBar.dart';
import 'package:attendance_tracker/http/models/api_response.dart';
import 'package:attendance_tracker/http/models/subject.dart';
import 'package:attendance_tracker/http/models/user.dart';
import 'package:attendance_tracker/http/services/backup_services.dart';
import 'package:attendance_tracker/view/splash_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:logger/logger.dart';
import 'package:shared_preferences/shared_preferences.dart';

class BackupProvider extends ChangeNotifier {
  final BackupServices _backupServices = BackupServices();

  //* Auth
  Future<String> registerUser(BuildContext context,
      {required String name}) async {
    try {
      if (name.isEmpty) {
        CustomSnackBar.show(
          context: context,
          icon: Icons.error,
          backgroundColor: Colors.red,
          title: "Enter a Name !",
        );
        return "0";
      }

      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? userData = prefs.getString('user_data');

      if (userData == null || userData.isEmpty) {
        CustomSnackBar.show(
          context: context,
          icon: Icons.error,
          backgroundColor: Colors.red,
          title: "No Data Found!",
        );
        return "0";
      }

      final user = UserData.fromJson(jsonDecode(userData));

      ApiResponse<Map<String, dynamic>> response =
          await _backupServices.registerUser(
              name: name,
              nickName: user.nickname,
              collegeName: user.collegeName);

      Logger().d(response);
      Logger().d(response.statusCode);

      if (response.statusCode == 201) {
        CustomSnackBar.show(
          context: context,
          icon: Icons.check_circle,
          backgroundColor: Colors.green,
          title: "You are registered successfully ✅",
        );

        String uniqueKey = response.data?["user"]["uniqueKey"] ?? 0;

        return uniqueKey;
      } else {
        CustomSnackBar.show(
            context: context,
            icon: Icons.error,
            backgroundColor: Colors.red,
            title: response.message);

        return "0";
      }
    } catch (e) {
      print("Error: ${e.toString()}");
      CustomSnackBar.show(
        context: context,
        icon: Icons.error,
        backgroundColor: Colors.red,
        title: "An unexpected error occurred ${e.toString()}",
      );

      return "0";
    }
  }

  Future<void> addAttendanceBackup({
    required String name,
    required String uniqueKey,
    required BuildContext context,
  }) async {
    try {
      if (name.isEmpty) {
        CustomSnackBar.show(
          context: context,
          icon: Icons.error,
          backgroundColor: Colors.red,
          title: "Enter a name !!",
        );
        return;
      }

      if (uniqueKey.isEmpty) {
        CustomSnackBar.show(
          context: context,
          icon: Icons.error,
          backgroundColor: Colors.red,
          title: "Enter your unique key !!",
        );
        return;
      }

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
      Logger().d(user.subjects[0].attendanceHistory);

      await Future.delayed(Duration(milliseconds: 200));

      ApiResponse<Map<String, dynamic>> response =
          await _backupServices.addBackup(
        name: name,
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

      return;
    } catch (e) {
      print("Error: ${e.toString()}");
      CustomSnackBar.show(
        context: context,
        icon: Icons.error,
        backgroundColor: Colors.red,
        title: "An unexpected error occurred",
      );

      return;
    }
  }

  //* send_email
  Future<void> sendEmail({
    required BuildContext context,
    required String email,
    required String uniqueKey,
  }) async {
    try {
      if (email.isEmpty) {
        CustomSnackBar.show(
          context: context,
          icon: Icons.error,
          backgroundColor: Colors.red,
          title: "Enter an email address !",
        );
        return;
      }

      //* ✅ Regex check
      final RegExp emailRegex = RegExp(
        r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
      );

      if (!emailRegex.hasMatch(email)) {
        CustomSnackBar.show(
          context: context,
          icon: Icons.error,
          backgroundColor: Colors.red,
          title: "Enter a valid email address !",
        );
        return;
      }

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
          title: response.message,
        );
      }

      return;
    } catch (e) {
      print("Error: ${e.toString()}");
      CustomSnackBar.show(
        context: context,
        icon: Icons.error,
        backgroundColor: Colors.red,
        title: "An unexpected error occurred",
      );
      return;
    }
  }

  //* get_backup
  Future<void> getAttendanceRecord({
    required BuildContext context,
    required String name,
    required String uniqueKey,
  }) async {
    try {
      if (name.isEmpty) {
        CustomSnackBar.show(
          context: context,
          icon: Icons.error,
          backgroundColor: Colors.red,
          title: "Enter a name !",
        );
        return;
      }

      if (uniqueKey.isEmpty) {
        CustomSnackBar.show(
          context: context,
          icon: Icons.error,
          backgroundColor: Colors.red,
          title: "Enter unique key !",
        );
        return;
      }

      ApiResponse<Map<String, dynamic>> response =
          await _backupServices.getBackup(name: name, uniqueKey: uniqueKey);

      if (response.statusCode == 200) {
        Map<String, dynamic> user = response.data!["userAttendanceData"];

        Logger().d(user["subjects"][0]["attendanceHistory"]);

        //* ✅ Correctly map subjects list
        List<Subject> subjects = (user["subjects"] as List<dynamic>)
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

      return;
    } catch (e) {
      print("Error: ${e.toString()}");
      CustomSnackBar.show(
        context: context,
        icon: Icons.error,
        backgroundColor: Colors.red,
        title: "An unexpected error occurred",
      );

      return;
    }
  }

  //* delete_user
  Future<void> deleteAttendanceBackup({
    required String name,
    required String uniqueKey,
    required BuildContext context,
  }) async {
    try {
      if (name.isEmpty) {
        CustomSnackBar.show(
          context: context,
          icon: Icons.error,
          backgroundColor: Colors.red,
          title: "Enter a name !",
        );
        return;
      }

      if (uniqueKey.isEmpty) {
        CustomSnackBar.show(
          context: context,
          icon: Icons.error,
          backgroundColor: Colors.red,
          title: "Enter unique key !",
        );
        return;
      }

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

      return;
    } catch (e) {
      print("Error: ${e.toString()}");
      CustomSnackBar.show(
        context: context,
        icon: Icons.error,
        backgroundColor: Colors.red,
        title: "An unexpected error occurred",
      );

      return;
    }
  }

  //* logout
  Future<void> logout(BuildContext context) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove('user_data');

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => SplashScreen()),
      (Route<dynamic> route) => false,
    );
  }
}

// Enhanced Subject Model with Date Tracking and Goal Calculation
import 'package:attendance_tracker/core/appColors.dart';
import 'package:flutter/material.dart';
import 'dart:math' as Math;

class Subject {
  String name;
  int totalLectures;
  List<AttendanceRecord> attendanceHistory;
  DateTime createdDate;
  String? description;
  int targetPercentage; // Changed to int for easier UI handling

  Subject({
    required this.name,
    required this.totalLectures,
    List<AttendanceRecord>? attendanceHistory,
    DateTime? createdDate,
    this.description,
    this.targetPercentage = 75, // Changed to int
  })  : attendanceHistory = attendanceHistory ?? [],
        createdDate = createdDate ?? DateTime.now();

  // Calculate attended lectures from history
  int get attendedLectures => attendanceHistory.length;

  // Calculate percentage
  double get percentage =>
      totalLectures > 0 ? (attendedLectures / totalLectures) * 100 : 0;

  // Check if goal is achieved
  bool get isGoalAchieved => percentage >= targetPercentage;

  // Calculate lectures needed to reach target
  int get lecturesNeededForGoal {
    if (isGoalAchieved) return 0;

    // If we've already attended all lectures but still haven't reached target
    if (attendedLectures >= totalLectures) return 0;

    // Calculate minimum consecutive lectures needed
    int currentAttended = attendedLectures;
    int currentTotal = totalLectures;
    int lecturesNeeded = 0;

    // Try adding lectures one by one until target is reached
    while (lecturesNeeded < 100) {
      // Prevent infinite loop
      int newAttended = currentAttended + lecturesNeeded;
      int newTotal =
          Math.max(currentTotal, newAttended); // Adjust total if needed
      double newPercentage = newTotal > 0 ? (newAttended / newTotal) * 100 : 0;

      if (newPercentage >= targetPercentage) {
        return lecturesNeeded;
      }
      lecturesNeeded++;
    }

    return -1; // Impossible to achieve with current structure
  }

  // Get lectures that can be missed and still achieve goal
  int get lecturesCanMiss {
    if (!isGoalAchieved) return 0;

    int currentAttended = attendedLectures;
    int missableLectures = 0;

    // Calculate how many lectures can be missed
    while (missableLectures < (totalLectures - currentAttended)) {
      int futureTotal = totalLectures;
      int futureAttended = currentAttended;
      double futurePercentage =
          futureTotal > 0 ? (futureAttended / futureTotal) * 100 : 0;

      if (futurePercentage < targetPercentage) {
        break;
      }
      missableLectures++;
    }

    return missableLectures;
  }

  // Get goal status message
  String get goalStatusMessage {
    if (isGoalAchieved) {
      int canMiss = lecturesCanMiss;
      if (canMiss > 0) {
        return canMiss == 1
            ? 'Can miss 1 more lecture'
            : 'Can miss $canMiss more lectures';
      }
      return 'Goal achieved! 🎉';
    } else {
      int needed = lecturesNeededForGoal;
      if (needed == -1 || needed == 0) {
        return 'Target unreachable';
      } else if (needed == 1) {
        return 'Need 1 more lecture';
      } else {
        return 'Need $needed more lectures';
      }
    }
  }

  // Get goal status color
  Color get goalStatusColor {
    if (isGoalAchieved) {
      return AppColors.success;
    } else if (lecturesNeededForGoal == -1 || lecturesNeededForGoal == 0) {
      return AppColors.accent;
    } else {
      return AppColors.warning;
    }
  }

  // Get goal status icon
  IconData get goalStatusIcon {
    if (isGoalAchieved) {
      return Icons.celebration;
    } else if (lecturesNeededForGoal == -1 || lecturesNeededForGoal == 0) {
      return Icons.error_outline;
    } else {
      return Icons.trending_up;
    }
  }

  // Add attendance for today
  void markAttendance() {
    DateTime today = DateTime.now();
    // Check if already marked today
    bool alreadyMarked = attendanceHistory.any((record) =>
        record.date.year == today.year &&
        record.date.month == today.month &&
        record.date.day == today.day);

    if (!alreadyMarked && attendanceHistory.length < totalLectures) {
      attendanceHistory.add(AttendanceRecord(
        subjectName: name,
        date: today,
        markedAt: today,
      ));
    }
  }

  // Check if attended on specific date
  bool isAttendedOn(DateTime date) {
    return attendanceHistory.any((record) =>
        record.date.year == date.year &&
        record.date.month == date.month &&
        record.date.day == date.day);
  }

  // Get attendance streak
  int getCurrentStreak() {
    if (attendanceHistory.isEmpty) return 0;

    List<AttendanceRecord> sortedHistory = List.from(attendanceHistory);
    sortedHistory.sort((a, b) => b.date.compareTo(a.date));

    int streak = 0;
    DateTime lastDate = DateTime.now();

    for (var record in sortedHistory) {
      Duration difference = lastDate.difference(record.date);
      if (difference.inDays <= 1) {
        streak++;
        lastDate = record.date;
      } else {
        break;
      }
    }
    return streak;
  }

  Map<String, dynamic> toJson() => {
        'name': name,
        'totalLectures': totalLectures,
        'attendanceHistory':
            attendanceHistory.map((record) => record.toJson()).toList(),
        'createdDate': createdDate.toIso8601String(),
        'description': description,
        'targetPercentage': targetPercentage,
      };

  factory Subject.fromJson(Map<String, dynamic> json) => Subject(
        name: json['name'],
        totalLectures: json['totalLectures'],
        attendanceHistory: (json['attendanceHistory'] as List?)
                ?.map((record) => AttendanceRecord.fromJson(record))
                .toList() ??
            [],
        createdDate: DateTime.parse(json['createdDate']),
        description: json['description'],
        targetPercentage:
            json['targetPercentage']?.toInt() ?? 75, // Changed to int
      );
}

// Attendance Record Model
class AttendanceRecord {
  String? subjectName;
  DateTime date;
  DateTime markedAt;
  String? notes;

  AttendanceRecord({
    this.subjectName,
    required this.date,
    required this.markedAt,
    this.notes,
  });

  Map<String, dynamic> toJson() => {
        'subjectName': subjectName,
        'date': date.toIso8601String(),
        'markedAt': markedAt.toIso8601String(),
        'notes': notes,
      };

  factory AttendanceRecord.fromJson(Map<String, dynamic> json) =>
      AttendanceRecord(
          date: DateTime.parse(json['date']),
          markedAt: DateTime.parse(json['markedAt']),
          notes: json['notes'],
          subjectName: json['subjectName'] as String?);
}

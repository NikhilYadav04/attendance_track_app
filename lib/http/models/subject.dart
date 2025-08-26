// Enhanced Subject Model with New Attendance Logic

class Subject {
  String name;
  int attendedLectures;
  int totalLectures;
  List<AttendanceRecord> attendanceHistory;
  DateTime createdDate;
  String? description;
  int targetPercentage;

  Subject({
    required this.name,
    this.attendedLectures = 0,
    this.totalLectures = 0,
    List<AttendanceRecord>? attendanceHistory,
    DateTime? createdDate,
    this.description,
    this.targetPercentage = 75,
  })  : attendanceHistory = attendanceHistory ?? [],
        createdDate = createdDate ?? DateTime.now();

  double get percentage =>
      totalLectures > 0 ? (attendedLectures / totalLectures) * 100 : 0;

  bool get isGoalAchieved => percentage >= targetPercentage;

  /// Calculates how many future lectures can be missed while staying above the target.
  int get lecturesCanMiss {
    if (percentage < targetPercentage) return 0;

    int missable = 0;
    while (true) {
      int futureAttended = attendedLectures;
      int futureTotal = totalLectures + missable + 1;
      double futurePercentage = (futureAttended / futureTotal) * 100;
      if (futurePercentage < targetPercentage) {
        break;
      }
      missable++;
    }
    return missable;
  }

  /// Marks multiple lectures as Present.
  void markPresent(int count) {
    DateTime now = DateTime.now();
    attendedLectures += count;
    totalLectures += count;

    for (int i = 0; i < count; i++) {
      attendanceHistory.add(AttendanceRecord(
        subjectName: name,
        date: now,
        markedAt: now,
        isPresent: true,
        lectureNumber: totalLectures - count + i + 1,
      ));
    }
  }

  /// Marks multiple lectures as Skipped/Absent.
  void markSkip(int count) {
    DateTime now = DateTime.now();
    totalLectures += count;

    for (int i = 0; i < count; i++) {
      attendanceHistory.add(AttendanceRecord(
        subjectName: name,
        date: now,
        markedAt: now,
        isPresent: false,
        lectureNumber: totalLectures - count + i + 1,
      ));
    }
  }

  void updateLectures(int newAttended, int newTotal) {
    if (newTotal >= newAttended && newAttended >= 0 && newTotal >= 0) {
      attendedLectures = newAttended;
      totalLectures = newTotal;
    }
  }

  bool isAttendedOn(DateTime date) {
    return attendanceHistory.any((record) =>
        record.isPresent &&
        record.date.year == date.year &&
        record.date.month == date.month &&
        record.date.day == date.day);
  }

  int getCurrentStreak() {
    if (attendanceHistory.isEmpty) return 0;

    var presentRecords = attendanceHistory.where((r) => r.isPresent).toList();
    if (presentRecords.isEmpty) return 0;

    presentRecords.sort((a, b) => b.date.compareTo(a.date));

    int streak = 0;
    DateTime lastDate = DateTime.now();
    Set<DateTime> uniqueDays = {};

    for (var record in presentRecords) {
      DateTime recordDay =
          DateTime(record.date.year, record.date.month, record.date.day);
      if (uniqueDays.contains(recordDay)) continue;

      Duration difference = lastDate.difference(recordDay);
      if (streak == 0 && difference.inDays <= 1) {
        streak++;
        uniqueDays.add(recordDay);
        lastDate = recordDay;
      } else if (streak > 0 && difference.inDays == 1) {
        streak++;
        uniqueDays.add(recordDay);
        lastDate = recordDay;
      } else if (streak > 0) {
        break;
      }
    }
    return streak;
  }

  Map<String, dynamic> toJson() => {
        'name': name,
        'attendedLectures': attendedLectures,
        'totalLectures': totalLectures,
        'attendanceHistory':
            attendanceHistory.map((record) => record.toJson()).toList(),
        'createdDate': createdDate.toIso8601String(),
        'description': description,
        'targetPercentage': targetPercentage,
      };

  factory Subject.fromJson(Map<String, dynamic> json) => Subject(
        name: json['name'],
        attendedLectures: json['attendedLectures'] ?? 0,
        totalLectures: json['totalLectures'] ?? 0,
        attendanceHistory: (json['attendanceHistory'] as List?)
                ?.map((record) => AttendanceRecord.fromJson(record))
                .toList() ??
            [],
        createdDate: DateTime.parse(json['createdDate']),
        description: json['description'],
        targetPercentage: json['targetPercentage']?.toInt() ?? 75,
      );
}

//* Represents a single attendance event.
class AttendanceRecord {
  String? subjectName;
  DateTime date;
  DateTime markedAt;
  bool isPresent; //* true for present, false for skip/absent
  int? lectureNumber; //* Tracks which lecture number this was
  String? notes;

  AttendanceRecord({
    this.subjectName,
    required this.date,
    required this.markedAt,
    required this.isPresent,
    this.lectureNumber,
    this.notes,
  });

  Map<String, dynamic> toJson() => {
        'subjectName': subjectName,
        'date': date.toIso8601String(),
        'markedAt': markedAt.toIso8601String(),
        'isPresent': isPresent,
        'lectureNumber': lectureNumber,
        'notes': notes,
      };

  factory AttendanceRecord.fromJson(Map<String, dynamic> json) =>
      AttendanceRecord(
        date: DateTime.parse(json['date']),
        markedAt: DateTime.parse(json['markedAt']),
        isPresent: json['isPresent'] ??
            true, //* Default to true for backward compatibility
        lectureNumber: json['lectureNumber'],
        notes: json['notes'],
        subjectName: json['subjectName'] as String?,
      );
}

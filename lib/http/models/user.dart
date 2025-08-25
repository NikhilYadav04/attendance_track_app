import 'package:attendance_tracker/http/models/subject.dart';

class UserData {
  final int? id;
  String name;
  String nickname;
  String? uniqueKey;
  String collegeName;
  List<Subject> subjects;

  UserData({
    this.id,
    this.uniqueKey,
    required this.name,
    required this.nickname,
    required this.collegeName,
    required this.subjects,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'nickname': nickname,
        'uniqueKey': uniqueKey,
        'collegeName': collegeName,
        'subjects': subjects.map((s) => s.toJson()).toList(),
      };

  factory UserData.fromJson(Map<String, dynamic> json) => UserData(
        uniqueKey: json['uniqueKey'] as String?,
        id: json['id'] as int?,
        name: json['name'],
        nickname: json['nickname'],
        collegeName: json['collegeName'],
        subjects:
            (json['subjects'] as List).map((s) => Subject.fromJson(s)).toList(),
      );
}

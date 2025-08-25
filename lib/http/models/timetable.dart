// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

class Timetable {
  final int id;
  final String name;
  final String userId;
  final String timetable;

  Timetable(
      {required this.id,
      required this.name,
      required this.userId,
      required this.timetable});

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      'name': name,
      'userId': userId,
      'timetable': timetable,
    };
  }

  factory Timetable.fromMap(Map<String, dynamic> map) {
    return Timetable(
      id: map['id'] as int,
      name: map['name'] as String,
      userId: map['userId'] as String,
      timetable: map['timetable'] as String,
    );
  }

  String toJson() => json.encode(toMap());

  factory Timetable.fromJson(String source) =>
      Timetable.fromMap(json.decode(source) as Map<String, dynamic>);
}

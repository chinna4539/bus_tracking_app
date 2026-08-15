import 'package:cloud_firestore/cloud_firestore.dart';

class NotificationInfo {
  final String id;
  final String title;
  final String message;
  final DateTime createdAt;
  final bool read;

  NotificationInfo({
    required this.id,
    required this.title,
    required this.message,
    required this.createdAt,
    required this.read,
  });

  factory NotificationInfo.fromMap(String id, Map<String, dynamic> map) {
    return NotificationInfo(
      id: id,
      title: map['title'] as String? ?? '',
      message: map['message'] as String? ?? '',
      createdAt: (map['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      read: map['read'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'message': message,
      'createdAt': createdAt,
      'read': read,
    };
  }
}

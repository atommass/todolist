import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:todolist/services/cloud/cloud_storage_constants.dart';

@immutable
class CloudTask {
  final String documentId;
  final String ownerUserId;
  final String text;
  final bool isDone;
  final DateTime? lastUpdated;
  final DateTime deadline;
  final int priority;

  const CloudTask({
    required this.documentId,
    required this.ownerUserId,
    required this.text,
    required this.isDone,
    required this.lastUpdated,
    required this.deadline,
    required this.priority,
  });

  CloudTask.fromSnapshot(QueryDocumentSnapshot<Map<String, dynamic>> snapshot)
    : documentId = snapshot.id,
      // Safely read fields from the snapshot, provide sensible defaults
      ownerUserId = snapshot.data()[ownerUserIdFieldName] as String? ?? '',
      text = snapshot.data()[textFieldName] as String? ?? '',
      isDone = snapshot.data()[isDoneFieldName] as bool? ?? false,
      // Firestore stores dates as Timestamp; convert when needed
      lastUpdated = _timestampToDateTime(snapshot.data()[lastUpdatedFieldName]),
      deadline =
          _timestampToDateTime(snapshot.data()[deadlineFieldName]) ??
          DateTime.now().add(const Duration(days: 7)),
      priority = snapshot.data()[priorityFieldName] as int? ?? 0;

  static DateTime? _timestampToDateTime(Object? value) {
    if (value == null) return null;
    if (value is DateTime) return value;
    try {
      final toDate = value as dynamic;
      final dt = toDate.toDate();
      if (dt is DateTime) return dt;
    } catch (_) {
    }
    return null;
  }
}

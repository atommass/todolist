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
      ownerUserId = snapshot.data()[ownerUserIdFieldName],
      text = snapshot.data()[textFieldName] as String,
      isDone = snapshot.data()[isDoneFieldName] as bool,
      lastUpdated = snapshot.data()[lastUpdatedFieldName] as DateTime?,
      deadline = snapshot.data()[deadlineFieldName] as DateTime,
      priority = snapshot.data()[priorityFieldName] as int;
}

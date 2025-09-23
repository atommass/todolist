import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:todolist/services/cloud/cloud_task.dart';
import 'package:todolist/services/cloud/cloud_storage_constants.dart';
import 'package:todolist/services/cloud/cloud_storage_exceptions.dart';


class FirebaseCloudStorage {
  final todoItem = FirebaseFirestore.instance.collection('todolist');

  Future<void> deleteTask({required String documentId}) async {
    try {
      await todoItem.doc(documentId).delete();
    } catch (e) {
      throw CouldNotDeleteTaskException();
    }
  }

  Future<void> updateTask({
    required String documentId,
    required String text,
  }) async {
    try {
      await todoItem.doc(documentId).update({textFieldName: text});
    } catch (e) {
      throw CouldNotUpdateTaskException();
    }
  }

  Future<void> setOrUpdateTaskDeadline({
    required String documentId,
    required DateTime deadline,
  }) async {
    try {
      await todoItem.doc(documentId).update({deadlineFieldName: deadline});
    } catch (e) {
      throw CouldNotUpdateTaskException();
    }
  }

  Future<void> markTaskAsDone(String documentId) async {
    try {
      await todoItem.doc(documentId).update({isDoneFieldName: true});
    } catch (e) {
      throw CouldNotUpdateTaskException();
    }
  }

  /// Set the task's done state to [isDone].
  Future<void> setTaskDone({
    required String documentId,
    required bool isDone,
  }) async {
    try {
      await todoItem.doc(documentId).update({isDoneFieldName: isDone});
    } catch (e) {
      throw CouldNotUpdateTaskException();
    }
  }

  Future<void> updateTaskDeadline({
    required String documentId,
    required DateTime deadline,
  }) async {
    return setOrUpdateTaskDeadline(documentId: documentId, deadline: deadline);
  }

  Stream<Iterable<CloudTask>> allTasks({required String ownerUserId}) {
    final todosCollection = todoItem
        .where(ownerUserIdFieldName, isEqualTo: ownerUserId)
        .snapshots()
        .map((event) => event.docs.map((doc) => CloudTask.fromSnapshot(doc)));
    return todosCollection;
  }

  Future<CloudTask> createNewTask({required String ownerUserId}) async {
    final now = DateTime.now();
    final defaultDeadline = now.add(const Duration(days: 7));
    final document = await todoItem.add({
      ownerUserIdFieldName: ownerUserId,
      textFieldName: '',
      isDoneFieldName: false,
      lastUpdatedFieldName: now,
      deadlineFieldName: defaultDeadline,
      priorityFieldName: 0,
    });
    final fetchedTask = await document.get();
    return CloudTask(
      documentId: fetchedTask.id,
      ownerUserId: ownerUserId,
      text: '',
      isDone: false,
      lastUpdated: DateTime.now(),
      deadline: DateTime.now().add(const Duration(days: 7)),
      priority: 0,
    );
  }

  static final FirebaseCloudStorage _shared =
      FirebaseCloudStorage._sharedInstance();
  FirebaseCloudStorage._sharedInstance();
  factory FirebaseCloudStorage() => _shared;
}

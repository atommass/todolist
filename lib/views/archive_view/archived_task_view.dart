import 'package:flutter/material.dart';
import 'package:todolist/extensions/buildcontext/loc.dart';
import 'package:todolist/services/auth/auth_service.dart';
import 'package:todolist/services/cloud/cloud_task.dart';
import 'package:todolist/services/cloud/firebase_cloud_storage.dart';
import 'package:todolist/views/todolist/task_inner_view.dart';

extension Count<T extends Iterable> on Stream<T> {
  Stream<int> get getLength => map((event) => event.length);
}

class ArchivedTaskView extends StatefulWidget {
  const ArchivedTaskView({super.key});

  @override
  State<ArchivedTaskView> createState() => _ArchivedTaskViewState();
}

class _ArchivedTaskViewState extends State<ArchivedTaskView> {
  late final FirebaseCloudStorage _taskService;

  String get userId => AuthService.firebase().currentUser!.id;

  @override
  void initState() {
    _taskService = FirebaseCloudStorage();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: StreamBuilder(
          stream: _taskService.archivedTasks(ownerUserId: userId).getLength,
          builder: (context, AsyncSnapshot<int> snapshot) {
            if (snapshot.hasData) {
              final itemCount = snapshot.data ?? 0;
              final text = context.loc.archived_task_title(itemCount);
              return Text(text);
            } else {
              return const Text('Loading...');
            }
          },
        ),
      ),
      body: StreamBuilder(
        stream: _taskService.archivedTasks(ownerUserId: userId),
        builder: (context, snapshot) {
          switch (snapshot.connectionState) {
            case ConnectionState.waiting:
            case ConnectionState.active:
              if (snapshot.hasData) {
                final archivedTasks = snapshot.data as Iterable<CloudTask>;
                return TaskListView(
                  tasks: archivedTasks,
                  onDeleteTask: (task) async {
                    await _taskService.deleteTask(documentId: task.documentId);
                  },
                  onTap: (task) {},
                  onToggleDone: (task) async {
                    // Toggle the isDone state
                    final newState = !task.isDone;
                    await _taskService.setTaskDone(
                      documentId: task.documentId,
                      isDone: newState,
                    );
                  },
                );
              } else {
                return const Center(child: CircularProgressIndicator());
              }
            default:
              return const Center(child: CircularProgressIndicator());
          }
        },
      ),
    );
  }
}

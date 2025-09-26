import 'package:flutter/material.dart';
import 'package:todolist/constants/routes.dart';
import 'package:todolist/enums/menu_action.dart';
import 'package:todolist/extensions/buildcontext/loc.dart';
import 'package:todolist/services/auth/auth_service.dart';
import 'package:todolist/services/cloud/cloud_task.dart';
import 'package:todolist/services/cloud/firebase_cloud_storage.dart';
import 'package:todolist/views/todolist/task_inner_view.dart';
import 'package:todolist/helpers/logout/logout_handler.dart';

extension Count<T extends Iterable> on Stream<T> {
  Stream<int> get getLength => map((event) => event.length);
}

class TaskView extends StatefulWidget {
  const TaskView({super.key});

  @override
  State<TaskView> createState() => _TaskViewState();
}

class _TaskViewState extends State<TaskView> {
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
          stream: _taskService.allTasks(ownerUserId: userId).getLength,
          builder: (context, AsyncSnapshot<int> snapshot) {
            if (snapshot.hasData) {
              final itemCount = snapshot.data ?? 0;
              final text = context.loc.task_title(itemCount);
              return Text(text);
            } else {
              return const Text('Loading...');
            }
          },
        ),
        actions: [
          IconButton(
            onPressed: () {
              Navigator.of(context).pushNamed(createUpdateTaskRoute);
            },
            icon: const Icon(Icons.add),
          ),
          PopupMenuButton<MenuAction>(
            onSelected: (value) {
              switch (value) {
                case MenuAction.logout:
                  handleLogout(context);
                  break;
                case MenuAction.archive:
                  Navigator.of(context).pushNamed(archivedTaskRoute);
                  break;
              }
            },
            itemBuilder: (context) {
              return [
                PopupMenuItem<MenuAction>(
                  value: MenuAction.archive,
                  child: Text('Archived Tasks'),
                ),
                PopupMenuItem<MenuAction>(
                  value: MenuAction.logout,
                  child: Text('Log out'),
                ),
              ];
            },
          ),
        ],
      ),
      body: StreamBuilder(
        stream: _taskService.allTasks(ownerUserId: userId),
        builder: (context, snapshot) {
          switch (snapshot.connectionState) {
            case ConnectionState.waiting:
            case ConnectionState.active:
              if (snapshot.hasData) {
                final allTasks = snapshot.data as Iterable<CloudTask>;
                return TaskListView(
                  tasks: allTasks,
                  onDeleteTask: (task) async {
                    await _taskService.deleteTask(documentId: task.documentId);
                  },
                  onTap: (task) {
                    Navigator.of(
                      context,
                    ).pushNamed(createUpdateTaskRoute, arguments: task);
                  },
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

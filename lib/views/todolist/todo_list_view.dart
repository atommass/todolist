import 'package:flutter/material.dart';
import 'package:todolist/services/cloud/cloud_task.dart';
import 'package:todolist/utilities/dialogs/delete_dialog.dart';


typedef TaskCallback = void Function(CloudTask task);

class TaskListView extends StatelessWidget {
  final Iterable<CloudTask> tasks;
  final TaskCallback onDeleteTask;
  final TaskCallback onTap;

  const TaskListView({
    super.key,
    required this.tasks,
    required this.onDeleteTask, 
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: tasks.length,
      itemBuilder: (context, index) {
        final task = tasks.elementAt(index);
        return ListTile(
          onTap: () {
            onTap(task);
          },
          title: Text(
            task.text,
            maxLines: 1,
            softWrap: true,
            overflow: TextOverflow.ellipsis,
          ),
          trailing: IconButton(
            onPressed: () async {
              final shouldDelete = await showDeleteDialog(context);
              if (shouldDelete) {
                onDeleteTask(task);
              }
            },
            icon: Icon(Icons.delete)),
        );
      },
    );
  }
}

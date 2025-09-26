import 'package:flutter/material.dart';
import 'package:todolist/services/cloud/cloud_task.dart';
import 'package:todolist/utilities/dialogs/delete_dialog.dart';

typedef TaskCallback = void Function(CloudTask task);
typedef ToggleTaskCallback = Future<void> Function(CloudTask task);

class TaskListView extends StatelessWidget {
  final Iterable<CloudTask> tasks;
  final TaskCallback onDeleteTask;
  final TaskCallback onTap;
  final ToggleTaskCallback? onToggleDone;

  const TaskListView({
    super.key,
    required this.tasks,
    required this.onDeleteTask,
    required this.onTap,
    this.onToggleDone,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: tasks.length,
      itemBuilder: (context, index) {
        final task = tasks.elementAt(index);
        // map numeric priority to a display color
        final Color priorityColor;
        switch (task.priority) {
          case 1:
            priorityColor = Colors.green;
            break;
          case 2:
            priorityColor = Colors.orange;
            break;
          case 3:
            priorityColor = Colors.red;
            break;
          default:
            priorityColor = Colors.grey;
        }
        return ListTile(
          onTap: () {
            onTap(task);
          },
          leading: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              GestureDetector(
                onTap: () async {
                  if (onToggleDone != null) {
                    await onToggleDone!(task);
                  }
                },
                child: Icon(
                  task.isDone ? Icons.check_box : Icons.check_box_outline_blank,
                ),
              ),
              const SizedBox(width: 16),
              Container(
                width: 10,
                height: 10,
                margin: const EdgeInsets.only(right: 8.0),
                decoration: BoxDecoration(
                  color: priorityColor,
                  shape: BoxShape.circle,
                ),
              ),
            ],
          ),
          title: Text(
            task.text,
            maxLines: 1,
            softWrap: true,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              decoration: task.isDone
                  ? TextDecoration.lineThrough
                  : TextDecoration.none,
              color: task.isDone
                  ? Colors.grey
                  : (task.deadline.isBefore(DateTime.now())
                        ? Colors.red
                        : null),
            ),
          ),
          trailing: IconButton(
            onPressed: () async {
              final shouldDelete = await showDeleteDialog(context);
              if (shouldDelete) {
                onDeleteTask(task);
              }
            },
            color: task.isDone ? Colors.grey : null,
            icon: Icon(Icons.delete),
          ),
        );
      },
    );
  }
}

import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';
import 'package:todolist/services/auth/auth_service.dart';
import 'package:todolist/services/cloud/cloud_task.dart';
import 'package:todolist/services/cloud/firebase_cloud_storage.dart';
import 'package:intl/intl.dart';
import 'package:todolist/utilities/dialogs/cannot_share_empty_todoitem_dialog.dart';
import 'package:todolist/utilities/generics/get_arguments.dart';


class CreateUpdateTaskView extends StatefulWidget {
  const CreateUpdateTaskView({super.key});

  @override
  State<CreateUpdateTaskView> createState() => _CreateUpdateTaskViewState();
}

class _CreateUpdateTaskViewState extends State<CreateUpdateTaskView> {
  CloudTask? _task;
  late final FirebaseCloudStorage _taskService;
  late final TextEditingController _textController;

  @override
  void initState() {
    _taskService = FirebaseCloudStorage();
    _textController = TextEditingController();
    super.initState();
  }

  void _textControllerListener() async {
    final task = _task;
    if (task == null) {
      return;
    }
    final text = _textController.text;
    await _taskService.updateTask(documentId: task.documentId, text: text);
  }

  void setuptextControllerListener() {
    _textController.removeListener(_textControllerListener);
    _textController.addListener(_textControllerListener);
  }

  Future<CloudTask> createOrGetExistingTask(BuildContext context) async {
    final widgetTask = context.getArgument<CloudTask>();

    if (widgetTask != null) {
      _task = widgetTask;
      _textController.text = widgetTask.text;
      return widgetTask;
    }

    final existingTask = _task;
    if (existingTask != null) {
      return existingTask;
    }
    final currentUser = AuthService.firebase().currentUser!;
    final userId = currentUser.id;
    final newTask = await _taskService.createNewTask(ownerUserId: userId);
    _task = newTask;
    return newTask;
  }

  void _deleteTaskIfTextIsEmpty() {
    final item = _task;
    if (_textController.text.isEmpty && item != null) {
      _taskService.deleteTask(documentId: item.documentId);
    }
  }

  void _saveTaskIfTaskEmpty() async {
    final item = _task;
    final text = _textController.text;
    if (item != null && text.isNotEmpty) {
      await _taskService.updateTask(documentId: item.documentId, text: text);
    }
  }

  @override
  void dispose() {
    _deleteTaskIfTextIsEmpty();
    _saveTaskIfTaskEmpty();
    _textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Task'),
        actions: [
          IconButton(
            onPressed: () async {
              final text = _textController.text;
              if (_task == null || text.isEmpty) {
                await showCannotShareEmptyToDoItemDialog(context);
              }
              SharePlus.instance.share(
                ShareParams(text: text)
              );
            }, 
            icon: const Icon(Icons.share))
          ],
      ),
      body: FutureBuilder(
        future: createOrGetExistingTask(context),
        builder: (context, snapshot) {
          switch (snapshot.connectionState) {
            case ConnectionState.done:
              if (snapshot.hasData && snapshot.data != null) {
                setuptextControllerListener();
                return Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      const SizedBox(height: 4.0),
                      Row(
                        children: [
                          const Text('Deadline:'),
                          const SizedBox(width: 8.0),
                          Expanded(
                            child: Text(
                              _task != null
                                  ? DateFormat.yMMMd().format(_task!.deadline.toLocal())
                                  : 'No deadline',
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          TextButton(
                            onPressed: () async {
                              final initial = _task?.deadline ?? DateTime.now();
                              final newDate = await showDatePicker(
                                context: context,
                                initialDate: initial,
                                firstDate: DateTime(2020),
                                lastDate: DateTime(2035),
                              );
                              if (newDate != null && _task != null) {
                                await _taskService.updateTaskDeadline(
                                  documentId: _task!.documentId,
                                  deadline: newDate,
                                );
                                setState(() {
                                  final t = _task!;
                                  _task = CloudTask(
                                    documentId: t.documentId,
                                    ownerUserId: t.ownerUserId,
                                    text: t.text,
                                    isDone: t.isDone,
                                    lastUpdated: DateTime.now(),
                                    deadline: newDate,
                                    priority: t.priority,
                                  );
                                });
                              }
                            },
                            child: const Text('Select Date'),
                          ),
                        ],
                      ),
                      TextField(
                        controller: _textController,
                        keyboardType: TextInputType.multiline,
                        maxLines: null,
                        decoration: const InputDecoration(
                          hintText: 'What do you want to do?',
                        ),
                      ),
                      const SizedBox(height: 16.0),
                      ElevatedButton(
                        onPressed: () {
                          if (_task != null) {
                            _taskService.markTaskAsDone(_task!.documentId);
                            Navigator.of(context).pop();
                          }
                        },
                        child: const Text('Mark as Done'),
                      ),
                      // TODO: implement priority selection
                      // TODO: implement that elevated button switches to "Mark as Undone" if the task is done
                      // TODO: implement that the text field has a line through if the task is done
                      // TODO: implement that the deadline date is red if the deadline is in the past
                      // TODO: implement that the deadline date is orange if the deadline is today
                      // TODO: implement that the deadline date is green if the deadline is in the future
                      // TODO: implement that the priority is red if the priority is high
                      // TODO: implement that the priority is orange if the priority is medium
                      // TODO: implement that the priority is green if the priority is low
                      // TODO: implement that the priority is grey if the priority is none
                      // TODO: implement that the priority is a dropdown button with the options: None, Low, Medium, High
                      // TODO: implement that the priority is saved to the database
                      // TODO: implement that the priority is loaded from the database
                      // TODO: implement that the priority shows up as a colored dot next to the task in the task list
                      // TODO: implement that date changes as soon as the user selects a new date
                      // TODO: implement that the priority changes as soon as the user selects a new priority
                      // TODO: implement task notifications
                      // TODO: implement task categories
                      // TODO: implement task tags
                      // TODO: implement task comments
                      // TODO: implement task attachments
                      // TODO: implement task archiving
                      // TODO: implement task filtering
                      // TODO: implement task search
                      // TODO: implement task sorting
                      // TODO: implement Google Calendar integration
                      // TODO: implement Google & Facebook login
                    ],
                  ),
                );
              } else {
                return const Center(child: Text('Failed to create the task.'));
              }
            default:
              return const CircularProgressIndicator();
          }
        },
      ),
    );
  }
}

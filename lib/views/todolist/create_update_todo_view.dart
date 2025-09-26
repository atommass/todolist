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
  // track priority as int consistent with CloudTask.priority
  int _selectedPriorityInt = 0;

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
      // initialize selected priority from the incoming task
      _selectedPriorityInt = widgetTask.priority;
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
    _selectedPriorityInt = newTask.priority;
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
    final List<String> items = <String>['None', 'Low', 'Medium', 'High'];
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
              SharePlus.instance.share(ShareParams(text: text));
            },
            icon: const Icon(Icons.share),
          ),
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
                                  ? DateFormat.yMMMd().format(
                                      _task!.deadline.toLocal(),
                                    )
                                  : 'No deadline',
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color:
                                    _task != null &&
                                        _task!.deadline.isBefore(DateTime.now())
                                    ? Colors.red
                                    : null,
                              ),
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
                      const SizedBox(height: 32.0),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Priority:',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          GestureDetector(
                            onTap: () {
                              // Implement priority change logic here
                              // noop - handled by DropdownButton onChanged
                            },
                            child: DropdownButton<int>(
                              value: _selectedPriorityInt,
                              icon: const Icon(Icons.arrow_downward),
                              elevation: 16,
                              style: const TextStyle(fontSize: 16),
                              underline: Container(
                                height: 2,
                                color: Colors.transparent,
                              ),
                              items: items.asMap().entries.map((entry) {
                                final index = entry.key; // 0..3
                                final label = entry.value;
                                // color the text according to priority
                                Color textColor = Colors.grey;
                                if (index == 1) textColor = Colors.green;
                                if (index == 2) textColor = Colors.orange;
                                if (index == 3) textColor = Colors.red;
                                return DropdownMenuItem<int>(
                                  value: index,
                                  child: Row(
                                    children: [
                                      Container(
                                        width: 10,
                                        height: 10,
                                        margin: const EdgeInsets.only(
                                          right: 8.0,
                                        ),
                                        decoration: BoxDecoration(
                                          color: textColor,
                                          shape: BoxShape.circle,
                                        ),
                                      ),
                                      Text(
                                        label,
                                        style: TextStyle(color: textColor),
                                      ),
                                      const SizedBox(width: 16.0),
                                    ],
                                  ),
                                );
                              }).toList(),
                              onChanged: (int? newValue) async {
                                if (newValue == null) return;
                                final item = _task;
                                setState(() {
                                  _selectedPriorityInt = newValue;
                                });
                                // persist change to backend and update local task
                                if (item != null) {
                                  await _taskService.updateTaskPriority(
                                    documentId: item.documentId,
                                    priority: newValue,
                                  );
                                  setState(() {
                                    final t = item;
                                    _task = CloudTask(
                                      documentId: t.documentId,
                                      ownerUserId: t.ownerUserId,
                                      text: t.text,
                                      isDone: t.isDone,
                                      lastUpdated: DateTime.now(),
                                      deadline: t.deadline,
                                      priority: newValue,
                                    );
                                  });
                                }
                              },
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 32.0),
                      ElevatedButton(
                        onPressed: () {
                          if (_task != null) {
                            if (_task!.isDone) {
                              _taskService.markTaskAsUndone(_task!.documentId);
                            } else {
                              _taskService.markTaskAsDone(_task!.documentId);
                            }
                            Navigator.of(context).pop();
                          }
                        },
                        child: Text(
                          _task != null && _task!.isDone
                              ? 'Mark as Undone'
                              : 'Mark as Done',
                        ),
                      ),
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

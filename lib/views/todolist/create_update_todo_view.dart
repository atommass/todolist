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
  int _selectedPriorityInt = 0;
  bool _isInitialized = false;

  @override
  void initState() {
    _taskService = FirebaseCloudStorage();
    _textController = TextEditingController();
    super.initState();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_isInitialized) {
      _initializeTask();
    }
  }

  void _initializeTask() async {
    final widgetTask = context.getArgument<CloudTask>();

    if (widgetTask != null) {
      setState(() {
        _task = widgetTask;
        _textController.text = widgetTask.text;
        _selectedPriorityInt = widgetTask.priority;
        _isInitialized = true;
      });
    } else {
      final currentUser = AuthService.firebase().currentUser!;
      final userId = currentUser.id;
      final newTask = await _taskService.createNewTask(ownerUserId: userId);
      setState(() {
        _task = newTask;
        _selectedPriorityInt = newTask.priority;
        _isInitialized = true;
      });
    }
    setuptextControllerListener();
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
    if (!_isInitialized) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

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
      body: Padding(
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
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: _task != null &&
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
                        _task = CloudTask(
                          documentId: _task!.documentId,
                          ownerUserId: _task!.ownerUserId,
                          text: _task!.text,
                          isDone: _task!.isDone,
                          lastUpdated: DateTime.now(),
                          deadline: newDate,
                          priority: _task!.priority,
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
                DropdownButton<int>(
                  value: _selectedPriorityInt,
                  icon: const Icon(Icons.arrow_downward),
                  elevation: 16,
                  style: const TextStyle(fontSize: 16),
                  underline: Container(
                    height: 2,
                    color: Colors.transparent,
                  ),
                  items: items.asMap().entries.map((entry) {
                    final index = entry.key;
                    final label = entry.value;
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
                            margin: const EdgeInsets.only(right: 8.0),
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
                    if (item != null) {
                      await _taskService.updateTaskPriority(
                        documentId: item.documentId,
                        priority: newValue,
                      );
                      setState(() {
                        _selectedPriorityInt = newValue;
                        _task = CloudTask(
                          documentId: _task!.documentId,
                          ownerUserId: _task!.ownerUserId,
                          text: _task!.text,
                          isDone: _task!.isDone,
                          lastUpdated: DateTime.now(),
                          deadline: _task!.deadline,
                          priority: newValue,
                        );
                      });
                    }
                  },
                ),
              ],
            ),
            const SizedBox(height: 32.0),
            ElevatedButton(
              onPressed: () async {
                if (_task != null) {
                  final isDone = !_task!.isDone;
                  await (isDone
                      ? _taskService.markTaskAsDone(_task!.documentId)
                      : _taskService.markTaskAsUndone(_task!.documentId));
                  setState(() {
                    _task = CloudTask(
                      documentId: _task!.documentId,
                      ownerUserId: _task!.ownerUserId,
                      text: _task!.text,
                      isDone: isDone,
                      lastUpdated: DateTime.now(),
                      deadline: _task!.deadline,
                      priority: _task!.priority,
                    );
                  });
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
      ),
    );
  }
}

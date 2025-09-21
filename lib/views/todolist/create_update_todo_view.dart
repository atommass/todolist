import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';
import 'package:todolist/services/auth/auth_service.dart';
import 'package:todolist/services/cloud/cloud_task.dart';
import 'package:todolist/services/cloud/firebase_cloud_storage.dart';
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
                  child: TextField(
                    controller: _textController,
                    keyboardType: TextInputType.multiline,
                    maxLines: null,
                    decoration: const InputDecoration(
                      hintText: 'Create your to-do item...',
                    ),
                  ),
                );
              } else {
                return const Center(child: Text('Failed to create to-do item.'));
              }
            default:
              return const CircularProgressIndicator();
          }
        },
      ),
    );
  }
}

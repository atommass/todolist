import 'package:flutter/material.dart';
import 'package:todolist/utilities/dialogs/generic_dialog.dart';


Future<bool> showDeleteDialog(BuildContext context) {
  return showGenericDialog<bool>(
    title: 'Delete',
    content: 'Are you sure you want to delete this task?',
    optionsBuilder: () => {'Cancel': false, 'Yes': true},
  ).then((value) => value ?? false);
}

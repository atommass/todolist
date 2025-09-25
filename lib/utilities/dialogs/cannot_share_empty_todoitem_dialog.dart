import 'package:flutter/material.dart';
import 'package:todolist/utilities/dialogs/generic_dialog.dart';

Future<void> showCannotShareEmptyToDoItemDialog(BuildContext context) {
  return showGenericDialog(
    title: 'Sharing',
    content: 'You cannot share an empty to-do item',
    optionsBuilder: () => {'OK': null},
  );
}

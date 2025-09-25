import 'package:flutter/material.dart';
import 'package:todolist/utilities/dialogs/generic_dialog.dart';

Future<bool> showLogOutDialog(BuildContext context) {
  return showGenericDialog<bool>(
    title: 'Log out',
    content: 'Are you sure you want to log out?',
    optionsBuilder: () => {'Cancel': false, 'Log out': true},
  ).then((value) => value ?? false);
}

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:todolist/services/auth/bloc/auth_bloc.dart';
import 'package:todolist/services/auth/bloc/auth_event.dart';
import 'package:todolist/utilities/dialogs/logout_dialog.dart';

Future<void> handleLogout(BuildContext context) async {
  final shouldLogout = await showLogOutDialog(context);
  if (!context.mounted) return;
  if (shouldLogout) {
    context.read<AuthBloc>().add(AuthEventLogOut());
  }
}

import 'package:flutter/widgets.dart';
import 'package:todolist/utilities/dialogs/generic_dialog.dart';

Future<void> showPasswordResetDialog(BuildContext context) {
  return showGenericDialog(
    context: context,
    title: 'Password Reset',
    content: 'We have now sent you a password reset link, check your email',
    optionsBuilder: () => {'OK': null},
  );
}

import 'package:todolist/utilities/dialogs/generic_dialog.dart';

Future<void> showErrorDialog(String text) {
  return showGenericDialog<void>(
    title: 'An error occurred',
    content: text,
    optionsBuilder: () => {'OK': null},
  );
}

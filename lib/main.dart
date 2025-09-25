import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:todolist/constants/routes.dart';
import 'package:todolist/helpers/loading/loading_screen.dart';
import 'package:todolist/l10n/app_localizations.dart';
import 'package:todolist/services/auth/bloc/auth_bloc.dart';
import 'package:todolist/services/auth/bloc/auth_event.dart';
import 'package:todolist/services/auth/bloc/auth_state.dart';
import 'package:todolist/services/auth/firebase_auth_provider.dart';
import 'package:todolist/views/login_view.dart';
import 'package:todolist/views/todolist/create_update_todo_view.dart';
import 'package:todolist/views/todolist/forgot_password_view.dart';
import 'package:todolist/views/todolist/todolist_view.dart';
import 'package:todolist/views/register_view.dart';
import 'package:todolist/views/verify_email_view.dart';

final GlobalKey<NavigatorState> navigatorKey =
    GlobalKey<NavigatorState>();

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(
    MaterialApp(
      supportedLocales: AppLocalizations.supportedLocales,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      navigatorKey: navigatorKey,
      home: BlocProvider<AuthBloc>(
        create: (context) => AuthBloc(FirebaseAuthProvider()),
        child: const HomePage(),
      ),
      routes: {
        createUpdateTaskRoute: (context) => const CreateUpdateTaskView(),
      },
    ),
  );
}

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    context.read<AuthBloc>().add(const AuthEventInitialize());
    return BlocConsumer<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state.isLoading) {
          LoadingScreen().show(
            context: context,
            text: state.loadingText ?? 'Please wait',
          );
        } else {
          LoadingScreen().hide();
        }
      },
      builder: (context, state) {
        if (state is AuthStateLoggedIn) {
          return const TaskView();
        } else if (state is AuthStateNeedsVerification) {
          return const VerifyEmailView();
        } else if (state is AuthStateLoggedOut) {
          return const LoginView();
        } else if (state is AuthStateForgotPassword) {
          return const ForgotPasswordView();
        } else if (state is AuthStateRegistering) {
          return const RegisterView();
        } else {
          return const Scaffold(body: CircularProgressIndicator());
        }
      },
    );
  }
}

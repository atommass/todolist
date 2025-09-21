import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:todolist/extensions/buildcontext/loc.dart';
import 'package:todolist/services/auth/auth_exceptions.dart';
import 'package:todolist/services/auth/bloc/auth_bloc.dart';
import 'package:todolist/services/auth/bloc/auth_event.dart';
import 'package:todolist/services/auth/bloc/auth_state.dart';
import 'package:todolist/utilities/dialogs/error_dialog.dart';

class LoginView extends StatefulWidget {
  const LoginView({super.key});

  @override
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
  late final TextEditingController _email;
  late final TextEditingController _password;

  @override
  void initState() {
    _email = TextEditingController();
    _password = TextEditingController();
    super.initState();
  }

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) async {
        if (state is AuthStateLoggedOut) {
          if (state.exception is UserNotFoundAuthException) {
            await showErrorDialog(
              context,
              'Your email or password is incorrect',
            );
          } else if (state.exception is InvalidEmailAuthException) {
            await showErrorDialog(
              context,
              'Please check the formatting of your email.',
            );
          } else if (state.exception is GenericAuthException) {
            await showErrorDialog(context, 'Authentication Error');
          }
        }
      },
      child: Scaffold(
        appBar: AppBar(title: Text(context.loc.my_title)),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              spacing: 32,
              children: [
                const Text('Please log in to your account to see your notes!'),
                Column(
                  children: [
                    TextField(
                      controller: _email,
                      enableSuggestions: false,
                      autocorrect: false,
                      keyboardType: TextInputType.emailAddress,
                      decoration: const InputDecoration(hintText: 'Enter your email'),
                    ),
                    TextField(
                      controller: _password,
                      obscureText: true,
                      enableSuggestions: false,
                      autocorrect: false,
                      decoration: const InputDecoration(
                        hintText: 'Enter your password',
                      ),
                    ),
                  ],
                ),
                Center(
                  child: Column(
                    spacing: 16,
                    children: [
                      const SizedBox(height: 16,),
                      TextButton(
                        style: ButtonStyle(
                          backgroundColor: WidgetStateProperty.all(Colors.black),
                          foregroundColor: WidgetStateProperty.all(Colors.white),
                          fixedSize: WidgetStateProperty.all(const Size.fromWidth(150)),
                        ),
                        onPressed: () async {
                          final email = _email.text;
                          final password = _password.text;
                          context.read<AuthBloc>().add(AuthEventLogIn(email, password));
                        },
                        child: const Text('Login'),
                      ),
                      TextButton(
                        onPressed: () {
                          context.read<AuthBloc>().add(const AuthEventForgotPassword(null));
                        },
                        child: const Text('I forgot my password'),
                      ),
                      TextButton(
                        
                        onPressed: () {
                          context.read<AuthBloc>().add(const AuthEventShouldRegister());
                        },
                        child: const Text('Not registered yet? Register here!'),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// This is a comment

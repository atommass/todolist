import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:todolist/services/auth/bloc/auth_bloc.dart';
import 'package:todolist/services/auth/bloc/auth_event.dart';

class VerifyEmailView extends StatefulWidget {
  const VerifyEmailView({super.key});

  @override
  State<VerifyEmailView> createState() => _VerifyEmailViewState();
}

class _VerifyEmailViewState extends State<VerifyEmailView> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Verify email')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            children: [
              const Text(
                "We've sent you an email where you need to verify your email address. Please check your account!",
              ),
              const SizedBox(height: 16,),
              const Text(
                "If you haven't received a verification, check the spam folder and if necessary, press the button below!",
              ),
              const SizedBox(height: 72,),
              TextButton(
                onPressed: () {
                  context.read<AuthBloc>().add(
                    const AuthEventSendEmailVerification(),
                  );
                },
                child: const Text('Resend email verification'),
              ),
              TextButton(
                onPressed: () async {
                  context.read<AuthBloc>().add(const AuthEventLogOut());
                },
                child: const Text('Restart'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

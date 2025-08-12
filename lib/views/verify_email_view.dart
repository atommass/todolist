import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:simplenotes/constants/routes.dart';

class VerifyEmailView extends StatefulWidget {
  const VerifyEmailView({super.key});

  @override
  State<VerifyEmailView> createState() => _VerifyEmailViewState();
}

class _VerifyEmailViewState extends State<VerifyEmailView> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Verify email'),),
      body: Column(
          children: [
            const Text("We've sent you an email where you need to verify your email address. Please check your accoutn!"),
            const Text("If you haven't received a verification, check the spam folder and if necessary, press the button below!"),
            TextButton(
              onPressed: () async {
                final user = FirebaseAuth.instance.currentUser;
                await user?.sendEmailVerification();
              },
              child: const Text('Send email verification'),
            ),
            TextButton(onPressed: () async {
              await FirebaseAuth.instance.signOut();
              Navigator.of(context).pushNamedAndRemoveUntil(registerRoute, (route) => false);
            }, child: const Text('Restart')),
          ],
        ),
    );
  }
}

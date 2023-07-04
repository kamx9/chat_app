import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

final _firebase = FirebaseAuth.instance;

class VerifyEmailScreen extends StatefulWidget {
  const VerifyEmailScreen({super.key, required this.done});

  final void Function() done;

  @override
  State<VerifyEmailScreen> createState() {
    return _VerifyEmailScreenState();
  }
}

class _VerifyEmailScreenState extends State<VerifyEmailScreen> {
  bool _isVerifyEmail = true;
  bool _canResendEmail = false;
  Timer? timer;

  @override
  void initState() {
    super.initState();
    _isVerifyEmail = _firebase.currentUser!.emailVerified;

    if (!_isVerifyEmail) {
      sendEmailVerification();
      timer = Timer.periodic(
        const Duration(seconds: 3),
        (_) => checkEmailVerified(),
      );
    }
  }

  Future checkEmailVerified() async {
    await _firebase.currentUser!.reload();
    setState(() {
      _isVerifyEmail = _firebase.currentUser!.emailVerified;
    });

    if (_isVerifyEmail) {
      timer?.cancel();
      widget.done();
    }
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  Future<void> sendEmailVerification() async {
    try {
      final user = _firebase.currentUser!;
      await user.sendEmailVerification();
      setState(() {
        _canResendEmail = false;
      });
      await Future.delayed(
        const Duration(seconds: 5),
      );
      setState(() {
        _canResendEmail = true;
      });
    } catch (error) {
      ScaffoldMessenger.of(context).clearSnackBars();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(error.toString()),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'You must first confirm your email.',
              style: Theme.of(context).textTheme.titleMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 10),
            Text(
              'A veryfication email has been sent to your email.',
              style: Theme.of(context).textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
                onPressed: _canResendEmail ? sendEmailVerification : null,
                child: const Text('Recent Email'))
          ],
        ),
      ),
    );
  }
}

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutterfire_ui/auth.dart';
import 'package:swole/firebase_options.dart';

class Login extends StatelessWidget {
  const Login({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SignInScreen(
        auth: FirebaseAuth.instance,
        providerConfigs: const [
          EmailProviderConfiguration(),
          PhoneProviderConfiguration(),
          GoogleProviderConfiguration(
              clientId: DefaultFirebaseOptions.googleClientID)
        ],
        actions: [
          AuthStateChangeAction<SignedIn>((context, state) {
            Navigator.pushNamed(context, '/home');
          }),
        ],
      ),
    );
  }
}

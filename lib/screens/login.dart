import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutterfire_ui/auth.dart';
import 'package:swole/components/nav_bar.dart';
import 'package:swole/firebase_options.dart';

class Login extends StatefulWidget {
  const Login({super.key});

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const NavBar(),
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
        footerBuilder: (context, action) => Padding(
          padding: const EdgeInsets.only(top: 20),
          child: CupertinoButton.filled(
            padding: EdgeInsets.zero,
            borderRadius: BorderRadius.circular(6),
            child: SizedBox(
              height: 42,
              child: Row(
                children: [
                  ClipRRect(
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(6),
                      bottomLeft: Radius.circular(6),
                    ),
                    child: Container(
                      color: Colors.white,
                      child: const SizedBox(
                        width: 44,
                        height: 42,
                        child: Icon(
                          Icons.person,
                          color: Colors.black,
                        ),
                      ),
                    ),
                  ),
                  const Expanded(
                      child: Text(
                    'Sign in as test user',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 20,
                    ),
                  )),
                ],
              ),
            ),
            onPressed: () async {
              if (!mounted) return;
              await FirebaseAuth.instance.signInWithEmailAndPassword(
                  email: "test@gmail.com", password: "123456");
              if (mounted) {
                Navigator.pushNamed(context, '/home');
              }
            },
          ),
        ),
      ),
    );
  }
}

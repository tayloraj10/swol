import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

//global
const appName = 'SWOL';
const appDescription = 'Strengths, Weaknesses, Opportunities and Limitations';

//auth
bool isLoggedIn() {
  return FirebaseAuth.instance.currentUser != null;
}

User? getUser() {
  return FirebaseAuth.instance.currentUser;
}

void logout(BuildContext context) {
  FirebaseAuth.instance.signOut();
  Navigator.pushNamed(context, '/');
}

//colors
const primaryColor = Colors.red;
const secondaryColor = Colors.blue;
const tertiaryColor = Colors.lightGreen;
const accentColor = Colors.black;

//text styles
const largeTextStyle = TextStyle(
  fontSize: 24,
  fontWeight: FontWeight.bold,
  letterSpacing: 1,
);

const mediumTextStyle = TextStyle(
  fontSize: 18,
  fontWeight: FontWeight.bold,
);

const smallTextStyle = TextStyle(
  fontSize: 16,
);

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

//global
const appName = 'SWOL';
const appDescription = 'Strengths, Weaknesses, Opportunities and Limitations';

//auth
bool isLoggedIn() {
  print(FirebaseAuth.instance.currentUser);
  return FirebaseAuth.instance.currentUser != null;
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

const smallTextStyle = TextStyle(
  fontSize: 16,
);

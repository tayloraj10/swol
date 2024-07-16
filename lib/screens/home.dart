import 'package:flutter/material.dart';
import 'package:swole/components/nav_bar.dart';
import 'package:swole/components/page_button.dart';
import 'package:swole/constants.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const NavBar(),
      body: Center(
        child: SizedBox.expand(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: const [
              PageButton(
                text: 'Habit Tracking',
                color: tertiaryColor,
              ),
              PageButton(
                text: 'Weight Lifting',
                color: primaryColor,
              ),
              PageButton(
                text: 'Calisthenics',
                color: secondaryColor,
              )
            ],
          ),
        ),
      ),
    );
  }
}

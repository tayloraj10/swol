import 'package:flutter/material.dart';
import 'package:swole/constants.dart';

class Loading extends StatefulWidget {
  const Loading({super.key});

  @override
  State<Loading> createState() => _LoadingState();
}

class _LoadingState extends State<Loading> {
  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    await Future.delayed(const Duration(seconds: 1));
    if (isLoggedIn() && mounted) {
      // Navigator.pushNamed(context, '/home');
      Navigator.pushNamed(context, '/calisthenics');
    } else {
      Navigator.pushNamed(context, '/login');
    }
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(child: CircularProgressIndicator()),
    );
  }
}

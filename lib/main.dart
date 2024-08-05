import 'package:flutter/material.dart';
import 'package:swole/constants.dart';
import 'package:swole/firebase_options.dart';
import 'package:swole/screens/calisthenics.dart';
import 'package:swole/screens/habits.dart';
import 'package:swole/screens/home.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:swole/screens/loading.dart';
import 'package:swole/screens/login.dart';
import 'package:url_strategy/url_strategy.dart';
import 'package:firebase_core/firebase_core.dart';

void main() async {
  setPathUrlStrategy();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: appName,
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        textTheme: GoogleFonts.archivoTextTheme().copyWith(
          headline1: const TextStyle(color: Colors.white),
          headline2: const TextStyle(color: Colors.white),
          headline3: const TextStyle(color: Colors.white),
          headline4: const TextStyle(color: Colors.white),
          headline5: const TextStyle(color: Colors.white),
          headline6: const TextStyle(color: Colors.white),
          bodyText1: const TextStyle(color: Colors.white),
          bodyText2: const TextStyle(color: Colors.white),
          caption: const TextStyle(color: Colors.white),
          button: const TextStyle(color: Colors.white),
          subtitle1: const TextStyle(color: Colors.white),
          subtitle2: const TextStyle(color: Colors.white),
        ),
        colorScheme: const ColorScheme(
            brightness: Brightness.dark,
            primary: Colors.red,
            onPrimary: Colors.white,
            secondary: Colors.black,
            onSecondary: Colors.white,
            error: Colors.amber,
            onError: Colors.white,
            background: Colors.white,
            onBackground: Colors.white,
            surface: Colors.white,
            onSurface: Colors.white),
      ),
      // home: const Loading(),
      initialRoute: '/',
      routes: {
        '/': (context) => const Loading(),
        '/home': (context) => const HomeScreen(),
        '/login': (context) => const Login(),
        '/calisthenics': (context) => const CalisthenicsHome(),
        '/habits': (context) => const Habits(),
      },
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _counter = 0;

  void _incrementCounter() {
    setState(() {
      _counter++;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text(
              'You have pushed the button this many times:',
            ),
            Text(
              '$_counter',
              style: Theme.of(context).textTheme.headline4,
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _incrementCounter,
        tooltip: 'Increment',
        child: const Icon(Icons.add),
      ),
    );
  }
}

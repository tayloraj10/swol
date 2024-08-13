import 'package:flutter/material.dart';
import 'package:swole/constants.dart';
import 'package:swole/screens/calisthenics.dart';
import 'package:swole/screens/habits.dart';

class PageButton extends StatelessWidget {
  final String text;
  final Color color;
  const PageButton({super.key, required this.text, required this.color});

  static const Map routeMapping = {
    'Habit Tracking': '/habits',
    'Calisthenics': '/calisthenics',
    'Weight Lifting': '/weights'
  };

  static const Map pageMapping = {
    'Habit Tracking': Habits(),
    'Calisthenics': CalisthenicsHome(),
    'Weight Lifting': Null
  };

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(10),
      child: ElevatedButton(
          style: ElevatedButton.styleFrom(backgroundColor: color),
          onPressed:
              // text == 'Weight Lifting'
              text != 'Habit Tracking'
                  ? null
                  : () => {
                        Navigator.push(
                          // or pushReplacement, if you need that
                          context,
                          QuickRoute(
                            routeName: routeMapping[text],
                            page: pageMapping[text],
                          ),
                        )

                        // Navigator.pushNamed(
                        //   context,
                        //   '/calisthenics',
                        // )
                      },
          child: Padding(
            padding: const EdgeInsets.all(30),
            child: Column(
              children: [
                Text(
                  text,
                  style: largeTextStyle,
                ),
                // if (text == 'Weight Lifting')
                if (text != 'Habit Tracking')
                  const Padding(
                    padding: EdgeInsets.only(top: 10),
                    child: Text(
                      'Coming Soon',
                      style: smallTextStyle,
                    ),
                  ),
              ],
            ),
          )),
    );
  }
}

class QuickRoute extends PageRouteBuilder {
  final Widget page;

  QuickRoute({required this.page, required String routeName})
      : super(
          settings: RouteSettings(name: routeName), // set name here
          pageBuilder: (
            BuildContext context,
            Animation<double> animation,
            Animation<double> secondaryAnimation,
          ) =>
              page,
          transitionsBuilder: (
            BuildContext context,
            Animation<double> animation,
            Animation<double> secondaryAnimation,
            Widget child,
          ) =>
              FadeTransition(
            opacity: animation,
            child: child,
          ),
          transitionDuration: Duration.zero,
        );
}

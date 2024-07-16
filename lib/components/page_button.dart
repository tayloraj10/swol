import 'package:flutter/material.dart';
import 'package:swole/constants.dart';

class PageButton extends StatelessWidget {
  final String text;
  final Color color;
  const PageButton({super.key, required this.text, required this.color});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(10),
      child: ElevatedButton(
          style: ElevatedButton.styleFrom(backgroundColor: color),
          onPressed: text != 'Calisthenics' ? null : () => {},
          child: Padding(
            padding: const EdgeInsets.all(30),
            child: Column(
              children: [
                Text(
                  text,
                  style: largeTextStyle,
                ),
                if (text != 'Calisthenics')
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

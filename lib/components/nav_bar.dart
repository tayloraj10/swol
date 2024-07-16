import 'package:flutter/material.dart';
import 'package:swole/constants.dart';

class NavBar extends StatelessWidget implements PreferredSizeWidget {
  const NavBar({super.key});
  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      centerTitle: true,
      backgroundColor: primaryColor,
      automaticallyImplyLeading: false,
      title: const Tooltip(
        textStyle: smallTextStyle,
        message: appDescription,
        child: Text(
          appName,
          style: largeTextStyle,
        ),
      ),
    );
  }
}

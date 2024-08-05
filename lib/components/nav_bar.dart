import 'package:flutter/material.dart';
import 'package:swole/components/user_chip.dart';
import 'package:swole/constants.dart';

class NavBar extends StatelessWidget implements PreferredSizeWidget {
  final Color color;
  const NavBar({super.key, this.color = Colors.black});
  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      centerTitle: true,
      backgroundColor: color,
      automaticallyImplyLeading: false,
      title: Tooltip(
        textStyle: smallTextStyle,
        message: appDescription,
        child: GestureDetector(
          onTap: () => {
            if (ModalRoute.of(context)?.settings.name != '/home')
              Navigator.pushNamed(context, '/home')
          },
          child: const Text(
            appName,
            style: largeTextStyle,
          ),
        ),
      ),
      actions: isLoggedIn() ? [const UserChip()] : null,
    );
  }
}

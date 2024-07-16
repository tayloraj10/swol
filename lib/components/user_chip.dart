import 'package:flutter/material.dart';
import 'package:swole/constants.dart';

class UserChip extends StatelessWidget {
  const UserChip({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: (() => {logout(context)}),
      child: Tooltip(
        message: 'Logout',
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Chip(
            label: Text(
              getUser()!.displayName!,
              style: smallTextStyle,
            ),
          ),
        ),
      ),
    );
  }
}

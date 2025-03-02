import 'package:flutter/material.dart';
import 'package:swole/constants.dart';

class UserChip extends StatelessWidget {
  const UserChip({
    super.key,
  });

  getUserName() {
    if (getUser()!.displayName != null) {
      return getUser()!.displayName;
    }
    return getUser()!.email;
  }

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
              getUserName(),
              style: smallTextStyle,
            ),
          ),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';

class TodoEditDialog extends StatefulWidget {
  final TextEditingController controller;
  final FocusNode focusNode;
  final Function(String, String) updateTask;
  final String id;

  const TodoEditDialog(
      {super.key,
      required this.controller,
      required this.focusNode,
      required this.updateTask,
      required this.id});

  @override
  State<TodoEditDialog> createState() => _TodoEditDialogState();
}

class _TodoEditDialogState extends State<TodoEditDialog> {
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Edit Task'),
      content: TextField(
        controller: widget.controller,
        onChanged: (value) => {
          widget.updateTask(widget.id, value),
          widget.focusNode.requestFocus()
        },
        focusNode: widget.focusNode,
      ),
      actions: <Widget>[
        TextButton(
          child: const Text('Close'),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
      ],
    );
  }
}

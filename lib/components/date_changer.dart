import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:swole/constants.dart';

class DateChanger extends StatefulWidget {
  final DateTime initialDate;
  final ValueChanged<DateTime> onDateChanged;

  const DateChanger({
    super.key,
    required this.initialDate,
    required this.onDateChanged,
  });

  @override
  State<DateChanger> createState() => _DateChangerState();
}

class _DateChangerState extends State<DateChanger> {
  late DateTime selectedDate;

  @override
  void initState() {
    super.initState();
    selectedDate = widget.initialDate;
  }

  void _updateDate(DateTime newDate) {
    setState(() {
      selectedDate = newDate;
    });
    widget.onDateChanged(newDate); // notify parent
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null && picked != selectedDate) {
      _updateDate(picked);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton(
          tooltip: 'Previous Day',
          padding: EdgeInsets.zero,
          onPressed: () => _updateDate(
            selectedDate.subtract(const Duration(days: 1)),
          ),
          icon: const Icon(Icons.arrow_back_ios),
        ),
        ElevatedButton(
          onPressed: () => _selectDate(context),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.green,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(4),
              side: BorderSide(
                color: selectedDate.year == DateTime.now().year &&
                        selectedDate.month == DateTime.now().month &&
                        selectedDate.day == DateTime.now().day
                    ? Colors.white
                    : Colors.transparent,
                width: 2,
              ),
            ),
            elevation: 0,
          ),
          child: Text(
            DateFormat('yyyy-MM-dd').format(selectedDate),
            style: mediumTextStyle,
          ),
        ),
        IconButton(
          tooltip: 'Next Day',
          padding: EdgeInsets.zero,
          onPressed: () => _updateDate(
            selectedDate.add(const Duration(days: 1)),
          ),
          icon: const Icon(Icons.arrow_forward_ios),
        ),
      ],
    );
  }
}

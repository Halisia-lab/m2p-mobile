import 'package:flutter/material.dart';

import '../utils/eighteen_years_ago.dart';

class DateTextField extends StatefulWidget {
  const DateTextField(
      {Key? key,
      required this.controller,
      required this.fieldName,
      this.restorationId})
      : super(key: key);

  final TextEditingController controller;
  final String fieldName;
  final String? restorationId;

  @override
  State<DateTextField> createState() => _DateTextFieldState();
}

class _DateTextFieldState extends State<DateTextField> with RestorationMixin {
  String? get restorationId => widget.restorationId;

  final RestorableDateTime _selectedDate =
      RestorableDateTime(getEighteenYearsAgo());

  late final RestorableRouteFuture<DateTime?> _restorableDatePickerRouteFuture =
      RestorableRouteFuture<DateTime?>(
    onComplete: _selectDate,
    onPresent: (NavigatorState navigator, Object? arguments) {
      return navigator.restorablePush(
        _datePickerRoute,
        arguments: _selectedDate.value.millisecondsSinceEpoch,
      );
    },
  );

  static Route<DateTime> _datePickerRoute(
    BuildContext context,
    Object? arguments,
  ) {
    return DialogRoute<DateTime>(
      context: context,
      builder: (BuildContext context) {
        return DatePickerDialog(
          initialEntryMode: DatePickerEntryMode.calendarOnly,
          initialDate: DateTime.fromMillisecondsSinceEpoch(arguments! as int),
          firstDate: DateTime(1900),
          lastDate: getEighteenYearsAgo(),
          cancelText: "ANNULER",
          
        );
      },
    );
  }

  @override
  void restoreState(RestorationBucket? oldBucket, bool initialRestore) {
    registerForRestoration(_selectedDate, 'selected_date');
    registerForRestoration(
        _restorableDatePickerRouteFuture, 'date_picker_route_future');
  }

  void _selectDate(DateTime? newSelectedDate) {
    if (newSelectedDate != null) {
      setState(() {
        var month = newSelectedDate.month.toString();
        var day = newSelectedDate.day.toString();
        if (newSelectedDate.month < 10) {
          month = '0${newSelectedDate.month}';
        }
        if (newSelectedDate.day < 10) {
          day = '0${newSelectedDate.day}';
        }
        widget.controller.text =
            '${newSelectedDate.year}-$month-$day';
        _selectedDate.value = newSelectedDate;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: widget.controller,
      decoration: InputDecoration(
          labelText: widget.fieldName,
          enabledBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Colors.black, width: 2),
            borderRadius: BorderRadius.all(Radius.zero),
          ),
          border: OutlineInputBorder(
            borderSide: BorderSide(color: Colors.black, width: 2),
            borderRadius: BorderRadius.all(Radius.zero),
          ),
          labelStyle: Theme.of(context).textTheme.labelSmall,
          suffixIcon: IconButton(
            icon: Icon(Icons.calendar_month_outlined, color: Colors.black),
            onPressed: () => _restorableDatePickerRouteFuture.present(),
          ),
      ),
      keyboardType: TextInputType.datetime,
      textInputAction: TextInputAction.next,
    );
  }
}

import 'package:flutter/cupertino.dart';
import 'package:intl/intl.dart';

import '../presentation.dart';
import 'components/app_datepicker.dart';
import 'components/app_text_field.dart';

class AppDateField extends StatelessWidget {
  AppDateField({
    super.key,
    required this.controller,
    this.validator,
    this.isRequired = false,
    this.displayFormat,
    this.label,
    this.hint,
    this.onChanged,
  }) {
    if (displayFormat != null) controller._changeFormat(displayFormat!);
  }

  final bool isRequired;
  final DateFieldController controller;
  final DateFormat? displayFormat;
  final String? label;
  final String? hint;
  final ValueChanged<DateTime>? onChanged;
  final String? Function(DateTime?)? validator;

  String? Function(String)? _makeValidator() {
    if (validator != null) {
      return (_) => validator!(controller.selectedDate);
    } else if (isRequired) {
      return (_) {
        if (controller.selectedDate == null) {
          return 'This field is required';
        } else {
          return null;
        }
      };
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return AppTextField(
      controller: controller,
      onTap: () => controller.select(title: label),
      onFocusChange: (inFocus) async {
        if (inFocus && !controller._pickerIsOpen) {
          await controller.select(title: label);
        }
      },
      keyboardType: TextInputType.none,
      label: label,
      hint: hint,
      isRequired: isRequired,
      validator: _makeValidator(),
      suffix: Icon(
        CupertinoIcons.calendar,
        color: AppColors.of(context).grey3,
        size: 20,
      ),
    );
  }
}

class DateFieldController extends TextEditingController {
  final DateTime earliestDateAllowed;
  final DateTime latestDateAllowed;
  DateFormat _format = DateFormat('dd MMM, yyyy');
  DateTime? _date;

  bool _pickerIsOpen = false;

  DateFieldController({
    required this.earliestDateAllowed,
    required this.latestDateAllowed,
  });

  DateTime? get selectedDate => _date;

  set selectedDate(DateTime? date) {
    _date = date;
    _displayDateInFormat();
  }

  Future<void> select({String? title}) async {
    final picker = AppDatePicker(
      title: title,
      initialSelection: _date,
      firstDate: earliestDateAllowed,
      lastDate: latestDateAllowed,
    );
    _pickerIsOpen = true;
    FocusManager.instance.primaryFocus?.unfocus();
    final selection = await picker.show();
    if (selection != null) selectedDate = selection;
    Future.delayed(
      const Duration(milliseconds: 300),
      () => _pickerIsOpen = false,
    );
  }

  void _changeFormat(DateFormat dateFormat) {
    _format = dateFormat;
    _displayDateInFormat();
  }

  void _displayDateInFormat() {
    if (_date != null) {
      text = _format.format(_date!);
    }
  }
}

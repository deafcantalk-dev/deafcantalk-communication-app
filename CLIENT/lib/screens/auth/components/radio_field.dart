import 'package:flutter/material.dart';

class CustomRadio extends StatefulWidget {
  final List<String> options;
  final Function(String) onChanged;

  const CustomRadio({super.key, required this.options, required this.onChanged});

  @override
  _CustomRadioState createState() => _CustomRadioState();
}

class _CustomRadioState extends State<CustomRadio> {
  String? _selectedValue;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: widget.options.map((option) {
        return Row(
          children: [
            Radio(
              value: option,
              groupValue: _selectedValue,
              onChanged: (value) {
                setState(() {
                  _selectedValue = value;
                });
                widget.onChanged(_selectedValue!);
              },
                activeColor: const Color(0xff3d949b),
            ),
            Text(option),
          ],
        );
      }).toList(),
    );
  }
}

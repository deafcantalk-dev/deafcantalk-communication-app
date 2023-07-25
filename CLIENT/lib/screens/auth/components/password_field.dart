import 'package:flutter/material.dart';

class PasswordField extends StatelessWidget {
  final TextEditingController controller;
  final bool obscureText;
  final VoidCallback onEyePressed;
  final TextInputAction? textInputAction;
  final TextInputType? keyboardType;
  final String? Function(String?)? validator;

  const PasswordField({
    Key? key,
    required this.controller,
    required this.obscureText,
    required this.onEyePressed,
    this.textInputAction,
    this.keyboardType,
    this.validator,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      textInputAction: textInputAction,
      keyboardType: keyboardType,
      validator: validator,
      cursorColor: const Color(0xff3d949b),
      decoration: const InputDecoration(
        border: OutlineInputBorder(
            borderSide: BorderSide(
          color: Color(0xff3d949b),
        )),
        focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(
          color: Color(0xff3d949b),
          width: 2,
        )),
        prefixIcon: Icon(
          Icons.lock,
          color: Color.fromARGB(255, 61, 148, 155),
        ),
        labelText: 'Password',
        labelStyle: TextStyle(
          color: Color.fromARGB(255, 61, 148, 155),
        ),
        hintText: 'Enter your password',
      ),
    );
  }
}

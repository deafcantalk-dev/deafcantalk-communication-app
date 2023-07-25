import 'package:flutter/material.dart';
import 'package:deafcantalk/services/http_service.dart';
import 'package:deafcantalk/screens/auth/login_screen.dart';
import 'package:get/get.dart';
import 'package:deafcantalk/enums/snackbar_message.dart';

import '../../widgets/widgets.dart';


class PasswordResetScreen extends StatefulWidget {
  const PasswordResetScreen({Key? key}) : super(key: key);

  @override
  _PasswordResetScreenState createState() => _PasswordResetScreenState();
}

class _PasswordResetScreenState extends State<PasswordResetScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _resetCodeController = TextEditingController();
  final TextEditingController _newPasswordController = TextEditingController();
  final HttpService httpService = HttpService();

  bool _showResetFields = false;

  Future<void> _requestPasswordReset() async {
    final email = _emailController.text;

    final response =
    await httpService.post('/user/reset-password', {'email': email});

    if (response.statusCode == 200) {
      setState(() {
        showSnackbar(SnackbarMessage.success, 'Password reset email sent successfully.');
        _showResetFields = true;
      });
    } else {
      setState(() {
        showSnackbar(SnackbarMessage.success, 'Failed to request password reset. Please try again.');
        _showResetFields = false;
      });
    }
  }

  Future<void> _resetPassword() async {
    final email = _emailController.text;
    final resetCode = _resetCodeController.text;
    final newPassword = _newPasswordController.text;

    final response = await httpService.post('/user/reset-password/verify', {'email': email, 'resetCode': resetCode, 'newPassword': newPassword},
    );

    print(response.body);

    if (response.statusCode == 200) {
      setState(() {
        showSnackbar(SnackbarMessage.success, 'Password reset successful!');
        Get.off(const LoginScreen());
      });
    } else {
      setState(() {
        showSnackbar(SnackbarMessage.success, 'Failed to reset password. Please check your reset code and try again.');
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 61, 148, 155),
        title: const Text('Password Reset'),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if(!_showResetFields)
                Column(
                  children: [
                    TextFormField(
                      cursorColor: const Color.fromARGB(255, 61, 148, 155),
                      controller: _emailController,
                      decoration: const InputDecoration(
                        labelText: 'Email',
                        labelStyle: TextStyle(
                          color: Color.fromARGB(255, 61, 148, 155),
                          fontSize: 20,

                        ),
                        focusedBorder: UnderlineInputBorder(
                          borderSide: BorderSide(color: Color.fromARGB(255, 61, 148, 155)),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16.0),
                    ElevatedButton(
                      style: ButtonStyle(
                        backgroundColor: MaterialStateProperty.all<Color>(const Color.fromARGB(255, 61, 148, 155)),
                        fixedSize: MaterialStateProperty.all(
                          Size(
                            MediaQuery.of(context).size.width * 0.7,
                            50,
                          ),
                        ),
                        textStyle: MaterialStateProperty.all<TextStyle>(
                          const TextStyle(
                            fontSize: 20.0,
                          ),
                        ),
                      ),
                      onPressed: _requestPasswordReset,
                      child: const Text('Reset Password'),
                    ),
                  ],
                ),

              if (_showResetFields)
                Column(
                  children: [
                    const SizedBox(height: 16.0),
                    TextFormField(
                      cursorColor: const Color.fromARGB(255, 61, 148, 155),
                      controller: _resetCodeController,
                      decoration: const InputDecoration(
                        labelText: 'Reset Code',
                        labelStyle: TextStyle(
                          color: Color.fromARGB(255, 61, 148, 155),
                          fontSize: 20,
                        ),
                        focusedBorder: UnderlineInputBorder(
                          borderSide: BorderSide(color: Color.fromARGB(255, 61, 148, 155)),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16.0),
                    TextFormField(
                      cursorColor: const Color.fromARGB(255, 61, 148, 155),
                      controller: _newPasswordController,
                      obscureText: true,
                      decoration: const InputDecoration(
                        labelText: 'New Password',
                        labelStyle: TextStyle(
                          color: Color.fromARGB(255, 61, 148, 155),
                          fontSize: 20,
                        ),
                        focusedBorder: UnderlineInputBorder(
                          borderSide: BorderSide(color: Color.fromARGB(255, 61, 148, 155)),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16.0),
                    ElevatedButton(
                      style: ButtonStyle(
                        backgroundColor: MaterialStateProperty.all<Color>(const Color.fromARGB(255, 61, 148, 155)),
                        fixedSize: MaterialStateProperty.all(
                          Size(
                            MediaQuery.of(context).size.width * 0.7,
                            50,
                          ),
                        ),
                        textStyle: MaterialStateProperty.all<TextStyle>(
                          const TextStyle(
                            fontSize: 20.0,
                          ),
                        ),
                      ),
                      onPressed: _resetPassword,
                      child: const Text('Reset Password'),
                    ),
                  ],
                ),
              const SizedBox(height: 16.0),
              ElevatedButton(
                style: ButtonStyle(
                  backgroundColor: MaterialStateProperty.all<Color>(const Color.fromARGB(255, 61, 148, 155)),
                  fixedSize: MaterialStateProperty.all(
                    Size(
                      MediaQuery.of(context).size.width * 0.7,
                      50,
                    ),
                  ),
                  textStyle: MaterialStateProperty.all<TextStyle>(
                    const TextStyle(
                      fontSize: 20.0,
                    ),
                  ),
                ),
                onPressed: () {
                  Get.off(const LoginScreen());
                },
                child: const Text('Go Back'),
              ),
              const SizedBox(height: 16.0),
            ],
          ),
        ),
      ),
    );
  }
}

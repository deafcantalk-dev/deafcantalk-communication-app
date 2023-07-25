import 'package:deafcantalk/screens/auth/components/auth_button.dart';
import 'package:deafcantalk/screens/auth/components/auth_field.dart';
import 'package:deafcantalk/screens/auth/components/password_field.dart';
import 'package:deafcantalk/screens/auth/controllers/login_controller.dart';
import 'package:deafcantalk/screens/auth/signup_screen.dart';
import 'package:deafcantalk/screens/auth/forgot-password.dart';
import 'package:deafcantalk/widgets/widgets.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class LoginScreen extends GetView<LoginController> {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Get.put(LoginController());
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        backgroundColor: Colors.white,
        body: Form(
          key: controller.formKey,
          autovalidateMode: AutovalidateMode.always,
          child: Center(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 10.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  //mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      'Hello, Welcome Back',
                      style: TextStyle(
                        fontSize: 25,
                        fontWeight: FontWeight.bold,
                        color: Color.fromARGB(255, 61, 148, 155),
                      ),
                    ),
                    const SizedBox(height: 10),

                    const Text(
                      'Happy to see you again, to use your account please login.',
                      style: TextStyle(
                        fontSize: 15,
                        color: Colors.black,
                      ),
                    ),
                    const SizedBox(height: 50),

                    AuthField(
                      labelText: 'Username',
                      iconData: Icons.person,
                      hintText: 'Enter your username',
                      controller: controller.usernameController,
                      textInputAction: TextInputAction.next,
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return '';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 10),
                    Obx(
                      () => PasswordField(
                        controller: controller.passwordController,
                        onEyePressed: () {
                          controller.obscureText(!controller.obscureText.value);
                        },
                        obscureText: controller.obscureText.value,
                        textInputAction: TextInputAction.done,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return '';
                          }
                          return null;
                        },
                      ),
                    ),
                    const SizedBox(height: 20),
                    Obx(
                      () => controller.loading.value
                          ? circularProgress()
                          : AuthButton(
                              text: 'Sign In',
                              onPressed: () => controller.login(),
                            ),
                    ),
                    const SizedBox(height: 10),
                    Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          TextButton(
                            onPressed: () {
                              Get.off(const PasswordResetScreen());
                            },
                            child: const Text(
                              'Forgot Password?',
                              style: TextStyle(
                                color: Color.fromARGB(255, 61, 148, 155),
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                decoration: TextDecoration.underline,
                              ),
                            ),
                          ),
                      ]
                    ),
                    const SizedBox(height: 5),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text(
                          'Don\'t have an account?',
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 16,
                          ),
                        ),
                        TextButton(
                          onPressed: () {
                            Get.off(const SignupScreen());
                          },
                          child: const Text(
                            'Sign Up',
                            style: TextStyle(
                              color: Color.fromARGB(255, 61, 148, 155),
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              decoration: TextDecoration.underline,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

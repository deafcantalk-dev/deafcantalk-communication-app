import 'package:deafcantalk/screens/auth/components/auth_button.dart';
import 'package:deafcantalk/screens/auth/components/auth_field.dart';
import 'package:deafcantalk/screens/auth/components/password_field.dart';
import 'package:deafcantalk/screens/auth/controllers/signup_controller.dart';
import 'package:deafcantalk/screens/auth/login_screen.dart';
import 'package:deafcantalk/widgets/widgets.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class SignupScreen extends GetView<SignupController> {
  const SignupScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Get.put(SignupController());
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
                padding:
                    const EdgeInsets.symmetric(horizontal: 30, vertical: 10.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  //mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      'Hello, Welcome',
                      style: TextStyle(
                        fontSize: 25,
                        fontWeight: FontWeight.bold,
                        color: Color.fromARGB(255, 61, 148, 155),
                      ),
                    ),
                    const SizedBox(height: 10),
                    const Text(
                      'Kindly create your account to continue using the app',
                      style: TextStyle(
                        fontSize: 15,
                        color: Colors.black,
                      ),
                    ),
                    const SizedBox(height: 50),
                    AuthField(
                      labelText: 'Username',
                      hintText: 'Enter your username',
                      iconData: Icons.person,
                      controller: controller.usernameController,
                      textInputAction: TextInputAction.next,
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return '';
                        }
                        if (value.contains(' ')) {
                          return 'Username can\'t contain spaces';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 15),
                    AuthField(
                      labelText: 'Email',
                      hintText: 'Enter your email',
                      iconData: Icons.email,
                      controller: controller.emailController,
                      textInputAction: TextInputAction.next,
                      keyboardType: TextInputType.emailAddress,
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return '';
                        }
                        if (!GetUtils.isEmail(value.trim())) {
                          return '';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 15),
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
                          if (value.length < 8) {
                            return 'Your password must not less than 8 characters';
                          }
                          return null;
                        },
                      ),
                    ),
                    const SizedBox(height: 15),
                    const Text(
                      'Are you a hard-of-hearing person?',
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 16,
                      ),
                    ),
                    const Row(
                      children: [
                        HearingButton(value: 'Yes', title: 'Yes'),
                        HearingButton(value: 'No', title: 'No')
                      ],
                    ),
                    const SizedBox(height: 20),
                    Obx(
                      () => controller.loading.value
                          ? circularProgress()
                          : AuthButton(
                              text: 'Sign Up',
                              onPressed: () => controller.signup(),
                            ),
                    ),

                    const SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text(
                          'Already have an account?',
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 16,
                          ),
                        ),
                        TextButton(
                          onPressed: () {
                            Get.off(const LoginScreen());
                          },
                          child: const Text(
                            'Sign In',
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

class HearingButton extends StatelessWidget {
  final String value;
  final String title;

  const HearingButton({

    required this.value,
    required this.title,

  });

  @override
  Widget build(BuildContext context) {
    return GetBuilder<SignupController>(
      builder: (SignupController) {
        return InkWell(
          onTap: () => SignupController.setHearingType(value),
          child: Row(
            children: [
              Radio(
                value: value,
                groupValue: SignupController.hearingType,
                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                onChanged: (String? value) {
                  SignupController.setHearingType(value!);
                },
                activeColor: const Color.fromARGB(255, 61, 148, 155),
              ),
              const SizedBox(width: 10),
              Text(title,
                style: const TextStyle(
                  color: Colors.black,
                  fontSize: 14,
                ),),
              const SizedBox(width: 5),
            ],
          ),
        );
      },
    );
  }
}

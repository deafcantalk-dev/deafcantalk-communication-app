import 'package:deafcantalk/screens/auth/login_screen.dart';
import 'package:deafcantalk/screens/auth/signup_screen.dart';
import 'package:deafcantalk/screens/starter/components/box_container.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lottie/lottie.dart';
import 'package:animate_do/animate_do.dart';


class WelcomeScreen extends StatelessWidget {
  final Duration duration = const Duration(milliseconds: 800);

  const WelcomeScreen({Key? key}) : super(key: key);


  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 61, 148, 155),
      body: Center(
        child: FractionallySizedBox(
          widthFactor: 0.9,
          heightFactor: 0.9,
          child: Container(
            margin: const EdgeInsets.all(8),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                FadeInUp(
                  duration: duration,
                  delay: const Duration(milliseconds: 1600),
                  child: Container(
                    margin: const EdgeInsets.only(
                      top: 50,
                      left: 25,
                      right: 25,
                    ),
                    width: size.width,
                    child: const Text(
                      "Let's Talk",
                      style: TextStyle(
                          color: Color.fromARGB(255, 255, 255, 255),
                          fontSize: 30,
                          fontWeight: FontWeight.bold),
                    ),
                  ),
                ),

                const SizedBox(
                  height: 10,
                ),

                FadeInUp(
                  duration: duration,
                  delay: const Duration(milliseconds: 1600),
                  child: Container(
                    margin: const EdgeInsets.only(
                      top: 0,
                      left: 25,
                      right: 25,
                    ),
                    width: size.width,
                    child: const Text(
                      "Helps you to communicate easily",
                      style: TextStyle(
                          color: Color.fromARGB(255, 255, 255, 255),
                          fontSize: 20,
                          fontWeight: FontWeight.bold),
                    ),
                  ),
                ),

                const SizedBox(height: 10,),

                FadeInUp(
                  duration: duration,
                  delay: const Duration(milliseconds: 2000),
                  child: Container(
                    margin: const EdgeInsets.only(
                      top: 50,
                      left: 5,
                      right: 5,
                    ),
                    width: size.width,
                    height: size.height / 2.5,
                    child: Image.asset(
                      'assets/images/logo.jpeg',
                      width: 250.0,
                      height: 250.0,
                    ),
                  ),
                ),

                const SizedBox(height: 10),

                FadeInUp(
                  duration: duration,
                  delay: const Duration(milliseconds: 200),
                  child: FractionallySizedBox(
                    widthFactor: 0.9,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        foregroundColor: const Color.fromARGB(255, 61, 148, 155),
                        backgroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                          vertical: 15,
                          horizontal: 30,
                        ),
                      ),
                      onPressed: () {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: ((context) => const SignupScreen()),
                          ),
                        );
                      },
                      child: const Text(
                        "Get Started",
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),

                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
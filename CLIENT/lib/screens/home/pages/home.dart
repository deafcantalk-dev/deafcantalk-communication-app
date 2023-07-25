import 'package:deafcantalk/screens/home/pages/chat_page.dart';
import 'package:flutter/material.dart';

class Home extends StatefulWidget {
  const Home({Key? key}) : super(key: key);

  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              SizedBox(height: 150),
              AspectRatio(
                aspectRatio: 2, // Set the desired aspect ratio here
                child: Container(
                  margin: const EdgeInsets.all(25),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Center(
                    child: FloatingActionButton.large(
                      backgroundColor: const Color.fromARGB(255, 61, 148, 155),
                      elevation: 20,
                      onPressed: () {},
                      child: IconButton(
                        iconSize: 60,
                        icon: const Icon(Icons.mic),
                        color: Colors.white,
                        onPressed: () {
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder: ((context) => const Chat()),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

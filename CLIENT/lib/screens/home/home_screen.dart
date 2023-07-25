import 'package:deafcantalk/screens/home/controllers/home_controller.dart';

import 'package:flutter/material.dart';
import 'package:get/get.dart';

class HomeScreen extends GetView<HomeController> {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Get.put(HomeController());
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        foregroundColor: const Color.fromARGB(255, 61, 148, 155),
        title: const Text("DeafCanTalk",
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
            )
        ),
        centerTitle: false,
        actions: <Widget>[
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              // Handle button press
              controller.logout();
            },
          ),
        ],
      ),

      bottomNavigationBar: BottomAppBar(
        color: Colors.white,
        shape: const CircularNotchedRectangle(),
        notchMargin: 10,
        child: SizedBox(
          height: 60,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: <Widget>[
                Obx(
                      () => IconButton(
                    icon: Column(
                      children: [
                        Icon(
                          Icons.home,
                          color: controller.currentIndex.value == 0
                              ? const Color.fromARGB(255, 61, 148, 155)
                              : Colors.black54,
                          size: 30,
                        ),
                        const Text(
                          'Home',
                          style: TextStyle(
                              fontSize: 10
                          ),
                        )
                      ],
                    ),

                    onPressed: () {
                      controller.currentIndex(0);
                    },
                    iconSize: 50,
                  ),
                ),
                Obx(
                      () => IconButton(
                    icon: Column(
                      children: [
                        Icon(
                          Icons.chat,
                          color: controller.currentIndex.value == 2
                              ? const Color.fromARGB(255, 61, 148, 155)
                              : Colors.black54,
                          size: 30,
                        ),
                        const Text(
                          'History',
                          style: TextStyle(
                              fontSize: 10
                          ),
                        )
                      ],
                    ),

                    onPressed: () {
                      controller.currentIndex(2);
                    },
                    iconSize:50,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),

        body: Obx(() => controller.widgets[controller.currentIndex.value]),
    );
  }
}

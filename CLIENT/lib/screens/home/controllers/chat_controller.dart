import 'dart:convert';

import 'package:flutter/material.dart';
import 'dart:async';
import 'package:deafcantalk/enums/snackbar_message.dart';
import 'package:deafcantalk/services/http_service.dart';
import 'package:deafcantalk/widgets/widgets.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;


late String cSessionId;
late String cText;
late String cIsMe;
late String cTime;
late String cUsername;

late TextEditingController sessionController;
late TextEditingController textController;
late TextEditingController ismeController;
late TextEditingController timeController;

class ChatController extends GetxController {
  final RxBool loading = false.obs;
  final HttpService httpService = HttpService();

  @override
  void onInit() {
    super.onInit();
    sessionController = TextEditingController();
    textController = TextEditingController();
    ismeController = TextEditingController();
    timeController = TextEditingController();
  }

  @override
  void onClose() {
    super.onClose();
  }

  Future<void> saveChatMessage() async {
    try {
      loading.value = true;
      Map<String, String> data = {
        'sessionId': sessionController.text.trim(),
        'text': textController.text.trim(),
        'isMe': ismeController.text.trim(),
        'time': timeController.text.trim(),
      };

      http.Response response = await httpService.post('/chat/add', data);

      var jsonData = json.decode(response.body);
      if (response.statusCode == 200 || response.statusCode == 201) {
        // Chat message saved successfully
      } else if (response.statusCode == 400) {
        loading.value = false;
        showSnackbar(SnackbarMessage.error, jsonData['msg']);
      } else {
        loading.value = false;
        showSnackbar(SnackbarMessage.error, 'Unknown Error Occurred');
      }
    } catch (e) {
      loading.value = false;
      showSnackbar(SnackbarMessage.error, e.toString());
    }
  }
}

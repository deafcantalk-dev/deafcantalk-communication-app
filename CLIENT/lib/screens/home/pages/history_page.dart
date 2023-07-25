import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:async';
import 'package:deafcantalk/services/http_service.dart';
import 'package:deafcantalk/enums/snackbar_message.dart';
import 'package:deafcantalk/widgets/widgets.dart';
import 'package:deafcantalk/screens/home/pages/old_chat.dart';

class History extends StatefulWidget {
  const History({Key? key}) : super(key: key);

  @override
  _HistoryState createState() => _HistoryState();
}

class _HistoryState extends State<History> {
  List<String> sessionsIds = [];
  List<String> sessionsLastMsg = [];

  final HttpService httpService = HttpService();

  @override
  void initState() {
    super.initState();
    fetchSessions();
  }

  Future<void> fetchSessions() async {
    try {

      http.Response response = await httpService.get('/chat/getOwnSessions');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          var tmp = data['data'];

          for (var item in tmp) {
            sessionsIds.add(item['sessionId']);
            sessionsLastMsg.add(item['lastMsg']);
          }
        });
      } else {
        showSnackbar(SnackbarMessage.error, response.statusCode.toString());
      }
    } catch (error) {
      showSnackbar(SnackbarMessage.error, error.toString());
    }
  }

  void navigateToChatScreen(String sessionId) {
    // Navigate to the chat screen with the selected session ID
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => OldChat(sessionId: sessionId),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    List<String> reversedIds = sessionsIds.reversed.toList();
    List<String> reversedLastMsg = sessionsLastMsg.reversed.toList();

    return Scaffold(
      body: SizedBox(
        height: MediaQuery.of(context).size.height * 0.7, // Set the height to 70% of the screen height
        child: ListView.builder(
          itemCount: reversedIds.length,
          itemBuilder: (context, index) {
            final sessionId = reversedIds[index];
            final sessionLastMsg = reversedLastMsg[index];

            return Container(
              margin: const EdgeInsets.symmetric(vertical: 0.5, horizontal: 16.0),
              child: Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15.0),
                ),
                elevation: 4.0,
                child: ListTile(
                  title: Text(sessionLastMsg),
                  onTap: () => navigateToChatScreen(sessionId),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

}

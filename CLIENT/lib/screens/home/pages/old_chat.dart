import 'package:flutter/material.dart';
import 'package:deafcantalk/screens/home/home_screen.dart';
import 'package:intl/intl.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:web_socket_channel/io.dart';
import 'package:mic_stream/mic_stream.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:deafcantalk/services/http_service.dart';
import 'package:http/http.dart' as http;
import 'package:deafcantalk/enums/snackbar_message.dart';
import 'package:deafcantalk/widgets/widgets.dart';
import 'package:get/get.dart';



class OldChat extends StatefulWidget {
  final String sessionId;

  const OldChat({Key? key, required this.sessionId}) : super(key: key);

  @override
  _OldChatState createState() => _OldChatState();
}

class Message {
  final String text;
  final bool isMe;
  final String time;

  Message({required this.text, required this.isMe, required this.time});
}

enum TtsState { playing, stopped, paused, continued }

class _OldChatState extends State<OldChat> {

  // URL for your backend-2 (Amazon Transcribe API integration)
  static const websocketUrl = 'ws://127.0.0.1"8080';


  final List<Message> _messages = [];
  final TextEditingController _controller = TextEditingController();
  Stream? audioStream;
  StreamSubscription<List<int>>? _audioStreamSubscription;
  late IOWebSocketChannel? _webSocketChannel;
  late bool _isRecording = false;
  late String _transcription = '';
  late String recordingStatus = '';
  static const AUDIO_FORMAT = AudioFormat.ENCODING_PCM_16BIT;

  final ScrollController _scrollController = ScrollController();

  late FlutterTts flutterTts;
  String? language;
  String? engine;
  double volume = 0.5;
  double pitch = 1.0;
  double rate = 0.5;
  bool isCurrentLanguageInstalled = false;

  String? _newVoiceText;
  int? _inputLength;

  TtsState ttsState = TtsState.stopped;

  get isPlaying => ttsState == TtsState.playing;
  get isStopped => ttsState == TtsState.stopped;
  get isPaused => ttsState == TtsState.paused;
  get isContinued => ttsState == TtsState.continued;

  bool get isIOS => !kIsWeb && Platform.isIOS;
  bool get isAndroid => !kIsWeb && Platform.isAndroid;
  bool get isWindows => !kIsWeb && Platform.isWindows;
  bool get isWeb => kIsWeb;

  final HttpService httpService = HttpService();

  @override
  void initState() {
    super.initState();
    _startRecording();
    WidgetsBinding.instance?.addPostFrameCallback((_) {
      initTts();
      retrieveMessages(_messages);
    });
  }

  initTts() {
    flutterTts = FlutterTts();

    _setAwaitOptions();

    if (isAndroid) {
      _getDefaultEngine();
      _getDefaultVoice();
    }

    flutterTts.setStartHandler(() {
      setState(() {
        print("Playing");
        ttsState = TtsState.playing;
      });
    });

    if (isAndroid) {
      flutterTts.setInitHandler(() {
        setState(() {
          print("TTS Initialized");
        });
      });
    }

    flutterTts.setCompletionHandler(() {
      setState(() {
        print("Complete");
        ttsState = TtsState.stopped;
      });
    });

    flutterTts.setErrorHandler((msg) {
      setState(() {
        print("error: $msg");
        ttsState = TtsState.stopped;
      });
    });
  }


  Future _getDefaultEngine() async {
    var engine = await flutterTts.getDefaultEngine;
    if (engine != null) {
      print(engine);
    }
  }

  Future _getDefaultVoice() async {
    var voice = await flutterTts.getDefaultVoice;
    if (voice != null) {
      print(voice);
    }
  }

  Future _speak(stext) async {
    _stopRecording();
    await flutterTts.setVolume(volume);
    await flutterTts.setSpeechRate(rate);
    await flutterTts.setPitch(pitch);
    await flutterTts.speak(stext);
    _startRecording();
  }

  Future _setAwaitOptions() async {
    await flutterTts.awaitSpeakCompletion(true);
  }

  @override
  void dispose() {
    _audioStreamSubscription?.cancel();
    _webSocketChannel?.sink.close();
    _controller.dispose();
    _scrollController.dispose();
    flutterTts.stop();
    super.dispose();
  }

  Future<void> _startRecording() async {

    if (_isRecording) {
      return;
    }

    MicStream.shouldRequestPermission(true);

    final audioStream = await MicStream.microphone(
      sampleRate: 16000,
      audioSource: AudioSource.DEFAULT,
      audioFormat: AUDIO_FORMAT,
    );

    _webSocketChannel = IOWebSocketChannel.connect(Uri.parse(websocketUrl));
    _audioStreamSubscription = audioStream?.listen((data) {
      if (_webSocketChannel != null) {
        _webSocketChannel!.sink.add(data);
        //print(data);
      }
    });

    _webSocketChannel?.stream.listen((message) {
      final decodedMessage = jsonDecode(message);

      setState(() {

        if (_messages.isNotEmpty) {
          final lastMessage = _messages.last;
          final isLastMessageMe = lastMessage.isMe == true;
          int lastIndex = _messages.lastIndexWhere((message) => message.isMe == true);

          if (isLastMessageMe) {
            _messages.add(Message(
              text: decodedMessage['transcript'],
              isMe: false,
              time: DateFormat.jm().format(DateTime.now()),
            ));

          } else {
            final combinedText = lastMessage.text + " " + decodedMessage['transcript'];
            _messages[_messages.length - 1] = Message(
              text: combinedText,
              isMe: false,
              time: DateFormat.jm().format(DateTime.now()),
            );
          }
        } else {
          _messages.add(Message(
            text: decodedMessage['transcript'],
            isMe: false,
            time: DateFormat.jm().format(DateTime.now()),
          ));
        }

      });

      // Scroll to the end after adding a new message
      WidgetsBinding.instance!.addPostFrameCallback((_) {
        _scrollController.jumpTo(
            _scrollController.position.maxScrollExtent);
      });

    });

    setState(() {
      _isRecording = true;
    });
  }

  void _stopRecording() async {
    if (!_isRecording) {
      return;
    }

    _audioStreamSubscription?.cancel();

    setState(() {
      _isRecording = false;
      _transcription = '';
    });
  }

  Future<void> saveMessageToDatabase(Message message) async {
    try {
      Map<String, String> data = {
        'sessionId': widget.sessionId,
        'text': message.text,
        'isMe': message.isMe.toString(),
        'time': message.time,
      };

      http.Response response = await httpService.post('/chat/add', data);
      var jsonData = json.decode(response.body);
      if (response.statusCode == 200 || response.statusCode == 201) {
        // OldChat message saved successfully
        //showSnackbar(SnackbarMessage.success, 'Saved Successfully');
      } else if (response.statusCode == 400) {
        showSnackbar(SnackbarMessage.error, jsonData['msg']);
      } else {
        showSnackbar(SnackbarMessage.error, 'Unknown Error Occurred');
      }

    } catch (error) {
      // Handle any exceptions
      print('Error saving message: $error');
    }
  }

  Future<void> saveSessionToDatabase(Message message) async {
    try {
      Map<String, String> data = {
        'sessionId': widget.sessionId,
        'lastMsg': message.text,
      };

      http.Response response = await httpService.post('/chat/addSession', data);

      var jsonData = json.decode(response.body);
      if (response.statusCode == 200 || response.statusCode == 201) {
        // OldChat message saved successfully
        //showSnackbar(SnackbarMessage.success, 'Saved Successfully');
      } else if (response.statusCode == 400) {
        showSnackbar(SnackbarMessage.error, jsonData['msg']);
      } else {
        showSnackbar(SnackbarMessage.error, 'Unknown Error Occurred');
      }

    } catch (error) {
      // Handle any exceptions
      print('Error saving message: $error');
    }
  }

  bool convertStringToBool(String stringValue) {
    String lowercaseValue = stringValue.toLowerCase();
    if (lowercaseValue == 'true') {
      return true;
    } else if (lowercaseValue == 'false') {
      return false;
    } else {
      // Handle invalid or unrecognized values
      return false; // Or throw an exception, depending on your use case
    }
  }

  Future<void> retrieveMessages(List<Message> message) async {

    if (message.isNotEmpty) {
      // Messages have already been retrieved, no need to fetch again
      return;
    }

    try {
      final sid = widget.sessionId;
      //print(sid);
      Map<String, String> data = {
        'sessionId': sid,
      };

      http.Response response = await httpService.post('/chat/getOwnMessages', data);

      final info = jsonDecode(response.body);
      var tmp = info['data'];

      for(var itm in tmp) {
          final msg = Message(text: itm['text'], isMe: convertStringToBool(itm['isMe']), time: itm['time']);
          message.add(msg);
          // Scroll to the end after adding a new message
          WidgetsBinding.instance!.addPostFrameCallback((_) {
            _scrollController.jumpTo(
                _scrollController.position.maxScrollExtent);
          });
      }

      if (response.statusCode == 200) {
        setState(() {

        });
      } else if (response.statusCode == 400) {
        showSnackbar(SnackbarMessage.error, 'Connection Error');
      } else {
        showSnackbar(SnackbarMessage.error, 'Unknown Error Occurred');
      }

    } catch (error) {
      // Handle any exceptions
      print('Error saving message: $error');
    }
  }

  void _scrollToBottom() {
    _scrollController.animateTo(
      _scrollController.position.maxScrollExtent,
      duration: const Duration(milliseconds: 100),
      curve: Curves.easeOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: Colors.grey[300],
      body: Column(
        children: [
          Row(
              children: [
                Expanded(
                  child: Container(
                    margin: const EdgeInsets.only(top:50, bottom: 20, right: 150),
                    height: 60,
                    child: FloatingActionButton(
                      backgroundColor: const Color.fromARGB(255, 61, 148, 155),
                      elevation: 25,
                      onPressed: () {},
                      child: IconButton(
                        iconSize: 40,
                        icon: const Icon(Icons.arrow_back),
                        color: Colors.white,
                        onPressed: () {
                          // controller.currentIndex(2);
                          if(_messages.isNotEmpty) {
                            saveSessionToDatabase(_messages[0]);
                          }
                          Get.off(const HomeScreen());
                        },
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: Container(
                    margin: const EdgeInsets.only(top:50, bottom: 20, left: 150),
                    //width: MediaQuery.of(context).size.width - 100,
                    height: 60,
                    child: FloatingActionButton(
                      backgroundColor: const Color.fromARGB(255, 61, 148, 155),
                      elevation: 25,
                      onPressed: () {},
                      child: GestureDetector(
                        onTap: _isRecording ? _stopRecording : _startRecording,
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            // Mic off icon
                            Visibility(
                              visible: !_isRecording,
                              child: const Icon(
                                Icons.mic_off,
                                size: 40,
                                color: Colors.white,
                              ),
                            ),
                            // Mic on icon
                            Visibility(
                              visible: _isRecording,
                              child: const Icon(
                                Icons.mic,
                                size: 40,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                  ),
                ),
              ]),
          Expanded(
            child: Container(
              margin: const EdgeInsets.symmetric(
                vertical: 5,
                horizontal: 10,
              ),
              child: ListView.builder(
                controller: _scrollController,
                itemCount: _messages.length,
                itemBuilder: (BuildContext context, int index) {
                  final message = _messages[index];
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 5.0),
                    child: Row(
                      mainAxisAlignment: message.isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
                      children: [
                        Container(
                          constraints: BoxConstraints(
                            maxWidth: MediaQuery.of(context).size.width * 0.5,
                          ),
                          padding: const EdgeInsets.all(10.0),
                          decoration: BoxDecoration(
                            color: message.isMe ? const Color.fromARGB(255, 61, 148, 155) : Colors.grey[600],
                            borderRadius: message.isMe
                                ? const BorderRadius.only(
                              topLeft: Radius.circular(15.0),
                              topRight: Radius.circular(15.0),
                              bottomLeft: Radius.circular(15.0),
                              bottomRight: Radius.circular(3.0),
                            )
                                : const BorderRadius.only(
                              topLeft: Radius.circular(15.0),
                              topRight: Radius.circular(15.0),
                              bottomLeft: Radius.circular(3.0),
                              bottomRight: Radius.circular(15.0),
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.1),
                                spreadRadius: 2,
                                blurRadius: 5,
                                offset: const Offset(0, 2),
                              ),
                              if (message.isMe)
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.1),
                                  spreadRadius: -1,
                                  blurRadius: 1,
                                  offset: const Offset(-1, 1),
                                ),
                              if (!message.isMe)
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.1),
                                  spreadRadius: 1,
                                  blurRadius: 1,
                                  offset: const Offset(1, 1),
                                ),
                            ],
                          ),


                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                message.text,
                                style: TextStyle(
                                  color: message.isMe
                                      ? Colors.white : Colors.white,
                                  fontSize: 20.0,
                                ),
                              ),
                              const SizedBox(height: 5.0),
                              Text(
                                textAlign: message.isMe ? TextAlign.right : TextAlign.left,
                                message.time,
                                style: TextStyle(
                                  color: message.isMe
                                      ? Colors.white54 : Colors.white54,
                                  fontSize: 15.0,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ),
          Row(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.max,
              children: [
                Container(
                  margin: const EdgeInsets.only(bottom: 20, left: 20),
                  width: MediaQuery.of(context).size.width - 100,
                  height: 60,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(30),
                    color: const Color(0xffF3F3F3),
                    boxShadow: const [
                      BoxShadow(
                        color: Color(0xffDBDBDB),
                        blurRadius: 15,
                        spreadRadius: 1.5,
                      ),
                    ],
                  ),
                  child: TextFormField(
                    keyboardAppearance: Brightness.dark,
                    //textInputAction: TextInputAction.continueAction,
                    controller: _controller,
                    maxLines: 35,
                    decoration: InputDecoration(
                      contentPadding: const EdgeInsets.symmetric(horizontal: 30.0, vertical: 15.0),
                      hintText: 'Message...',
                      hintStyle: GoogleFonts.inter(
                        fontSize: 20,
                        color: const Color(0xffB5B4B4),
                      ),
                      border: InputBorder.none,
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(
                    bottom: 10,
                    right: 0,
                    left: 10,
                  ),
                  child: FloatingActionButton(
                    elevation: 15,
                    onPressed: () {},
                    child: ElevatedButton(
                      onPressed: () {
                        if (_controller.text.isNotEmpty) {

                          final lastMsg = _messages.last;

                          if (lastMsg.isMe == false) {
                            saveMessageToDatabase(_messages.last);
                          }

                          final message = Message(text: _controller.text, isMe: true, time: DateFormat.jm().format(DateTime.now()));

                          saveMessageToDatabase(message);

                          setState(() {
                            _messages.add(message);

                          });
                          _speak(_controller.text);
                          // Scroll to the end after adding a new message
                          WidgetsBinding.instance!.addPostFrameCallback((_) {
                            _scrollController.jumpTo(
                                _scrollController.position.maxScrollExtent);
                          });
                          _scrollToBottom();
                          _controller.clear();
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        foregroundColor: const Color(0xffFFFFFF),
                        backgroundColor: const Color.fromARGB(255, 61, 148, 155),
                        shape: const CircleBorder(),
                        disabledForegroundColor:
                        const Color.fromARGB(255, 61, 148, 155).withOpacity(0.38),
                        disabledBackgroundColor:
                        const Color.fromARGB(255, 61, 148, 155).withOpacity(0.12),
                        padding: const EdgeInsets.all(10),
                      ),
                      child: Image.asset(
                        "assets/send1.png",
                        color: Colors.white,
                        height: 36,
                        width: 27,
                      ),
                    ),
                  ),
                ),
              ]),
        ],
      ),
    );
  }
}

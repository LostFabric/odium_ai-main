import 'dart:io';

import 'package:flutter/material.dart';
import 'package:gigachat_dart/gigachat_dart.dart';
import 'database_helper.dart';

void main() {
  HttpOverrides.global = MyHttpOverrides();
  runApp(MyApp());
}

class MyHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return super.createHttpClient(context)
      ..badCertificateCallback =
          (X509Certificate cert, String host, int port) => true;
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        title: 'AI Assistant',
        theme: ThemeData(
          scaffoldBackgroundColor: Color.fromARGB(255, 32, 34, 37),
          appBarTheme: AppBarTheme(
            color: Color.fromARGB(255, 64, 68, 75),
            elevation: 0,
            titleTextStyle: TextStyle(
                color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
          ),
        ),
        home: ChatScreen());
  }
}

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _controller = TextEditingController();
  final List<Map<String, String>> _chatHistory = [];
  late GigachatClient _gigachatModel;

  @override
  void initState() {
    super.initState();
    _gigachatModel = GigachatClient.fromBase64(
        base64token:
            'NTJmNGU5ZTEtZmRlZS00MTAzLWE3NDEtMzRmYWU0MjFhNGNiOjI4MGNlZmVkLTk0YjgtNDI5Yi05MTZhLTg1NTY5Mzk1N2E4YQ==');
  }

  Future<String?> _getAnswerFromFaq(String query) async {
    final db = await DatabaseHelper.instance.database;
    List<Map> results = await db.query(
      'faq',
      where: 'LOWER(question) = LOWER(?)',
      whereArgs: [query],
    );

    if (results.isNotEmpty) {
      return results.first['answer'] as String?;
    }
    return null;
  }

  Future<String> _processQuery(String query) async {
    final localAnswer = await _getAnswerFromFaq(query);
    if (localAnswer != null) {
      return localAnswer;
    }

    final aiResponse = await _queryGigaChatAPI(query);
    return aiResponse ?? 'Извините, я не могу ответить на ваш вопрос.';
  }

  Future<String?> _queryGigaChatAPI(String query) async {
    try {
      final response = await _gigachatModel.generateChatCompletion(
          request: Chat(model: 'GigaChat', messages: [
        Message(
            role: MessageRole.system,
            content:
                'Ты ассистент технической поддержки оператора сотовой связи. Тебе нельзя отвечать на все не связанные с тематикой вопросы. Ты должен предоставлять ответы на вопросы пользователей связанные с тематикой. Если тебе недостаточно информации проводи поиск во внутренней базе данных.'),
        Message(role: MessageRole.user, content: query),
      ]));

      return response.choices?.first.message?.content;
    } catch (e) {
      print("Ошибка запроса: $e");
      return null;
    }
  }

  void _addToChatHistory(String query, String response) {
    setState(() {
      _chatHistory.add({"user": query, "bot": response});
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 40,
        title: Row(
          children: [
            Image.asset(
              "assets/images/logo.png",
              height: 30,
            ),
            SizedBox(width: 10),
            Text(
              "ODIUM AI",
              style: TextStyle(color: Colors.white, fontFamily: 'OpenSans'),
            ),
          ],
        ),
        centerTitle: false,
      ),
      body: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage("assets/images/chat_background.png"),
                fit: BoxFit.cover,
              ),
            ),
          ),
          Column(
            children: [
              Expanded(
                child: ListView.builder(
                  itemCount: _chatHistory.length,
                  reverse: true,
                  itemBuilder: (context, index) {
                    final entry = _chatHistory[_chatHistory.length - 1 - index];
                    final isUser = entry.containsKey("user");
                    return Align(
                      alignment:
                          isUser ? Alignment.centerRight : Alignment.centerLeft,
                      child: Container(
                        margin:
                            EdgeInsets.symmetric(vertical: 5, horizontal: 10),
                        padding: EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: isUser
                              ? Color.fromARGB(255, 64, 68, 75)
                              : Colors.grey[300],
                          borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(20),
                            topRight: Radius.circular(20),
                            bottomLeft:
                                isUser ? Radius.circular(20) : Radius.zero,
                            bottomRight:
                                isUser ? Radius.zero : Radius.circular(20),
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text.rich(
                              TextSpan(
                                children: [
                                  TextSpan(
                                    text: "Вы: ",
                                    style: TextStyle(
                                        fontFamily: 'OpenSans',
                                        color:
                                            Color.fromARGB(255, 126, 231, 231)),
                                  ),
                                  TextSpan(
                                    text: "${entry["user"]}",
                                    style: TextStyle(
                                        fontFamily: 'OpenSans',
                                        fontWeight: FontWeight.w200,
                                        color: Colors.white),
                                  ),
                                ],
                              ),
                            ),
                            SizedBox(height: 4),
                            Text.rich(
                              TextSpan(
                                children: [
                                  TextSpan(
                                    text: "AI-ассистент: ",
                                    style: TextStyle(
                                        fontFamily: 'OpenSans',
                                        color:
                                            Color.fromARGB(255, 126, 231, 231)),
                                  ),
                                  TextSpan(
                                    text: "${entry["bot"]}",
                                    style: TextStyle(
                                        fontFamily: 'OpenSans',
                                        fontWeight: FontWeight.w200,
                                        color: Colors.white),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
              SafeArea(
                child: Container(
                height: 60,
                padding: EdgeInsets.symmetric(horizontal: 15),
                decoration: BoxDecoration(
                  color: Color.fromARGB(255, 64, 68, 75),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _controller,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                        ),
                        decoration: InputDecoration(
                          border: InputBorder.none,
                          hintText: "Сообщение",
                          hintStyle: TextStyle(
                              color: Color.fromARGB(255, 202, 202, 204)),
                        ),
                      ),
                    ),
                    SizedBox(width: 8),
                    IconButton(
                      onPressed: () async {
                        final query = _controller.text;
                        if (query.isEmpty) return;

                        final response = await _processQuery(query);
                        _addToChatHistory(query, response);
                        _controller.clear();
                      },
                      icon: Icon(Icons.send),
                      color: Color.fromARGB(255, 34, 158, 217),
                    ),
                  ],
                ),
              ),
              )
            ],
          ),
        ],
      ),
    );
  }
}

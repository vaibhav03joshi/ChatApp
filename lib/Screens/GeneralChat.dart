import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'dart:convert';

class GeneralChat extends StatefulWidget {
  GeneralChat({required this.name, super.key});
  String name;
  @override
  State<GeneralChat> createState() => _GeneralChatState();
}

class _GeneralChatState extends State<GeneralChat> {
  TextEditingController _textController = TextEditingController();
  Map<String, Map<String, dynamic>> data = {};
  List<GeneralMessage> messagesList = [];

  Future<void> sendMessage(String name, String message) async {
    DatabaseReference ref = FirebaseDatabase.instance
        .ref("General/${DateTime.now().toString().replaceAll(".", "_")}");
    ref.set({
      name: message,
    });
  }

  void getMessages() async {
    DatabaseReference ref = FirebaseDatabase.instance.ref("General/");
    DataSnapshot snapshot = await ref.get();
    if (snapshot.value != null) {
      final dataMap = Map<String, dynamic>.from(snapshot.value as Map);
      dataMap.forEach((timestamp, messageMap) {
        final messageData = Map<String, dynamic>.from(messageMap);
        messageData.forEach((username, message) {
          GeneralMessage messageObj = GeneralMessage(message, username);
          messagesList.add(messageObj);
          print(messagesList.length);
        });
      });
    }
    setState(() {});
  }

  @override
  void initState() {
    listenToMessages();
    super.initState();
  }

  void listenToMessages() {
    DatabaseReference ref = FirebaseDatabase.instance.ref("General/");
    ref.onValue.listen((event) {
      final data = event.snapshot.value as Map?;
      if (data != null) {
        messagesList.clear();
        data.forEach((timestamp, messageMap) {
          final messageData = Map<String, dynamic>.from(messageMap);
          messageData.forEach((username, message) {
            GeneralMessage messageObj = GeneralMessage(message, username);
            messagesList.add(messageObj);
          });
        });
        setState(() {}); // Refresh the UI with new messages
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("General Chat"),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: messagesList.length,
              itemBuilder: (context, index) => Container(
                child: Row(
                  children: [
                    Text(
                      messagesList[index].message!,
                      style: TextStyle(fontSize: 14),
                    ),
                    Text(
                      " -" + messagesList[index].sender!,
                      style: TextStyle(fontSize: 8),
                    ),
                  ],
                ),
              ),
            ),
          ),
          TextField(
            controller: _textController,
            onSubmitted: (yo) {
              sendMessage(widget.name, _textController.text);
              _textController.clear();
            },
          ),
          IconButton(
            onPressed: () {
              sendMessage(widget.name, _textController.text);
              _textController.clear();
            },
            icon: Icon(CupertinoIcons.up_arrow),
          )
        ],
      ),
    );
  }
}

class GeneralMessage {
  GeneralMessage(this.message, this.sender) {}
  String? message;
  String? sender;
}

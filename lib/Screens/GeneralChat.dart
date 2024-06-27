import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class GeneralChat extends StatefulWidget {
  GeneralChat({required this.name, required this.path, super.key});
  String name;
  String path;
  @override
  State<GeneralChat> createState() => _GeneralChatState();
}

class _GeneralChatState extends State<GeneralChat> {
  TextEditingController _textController = TextEditingController();
  TextEditingController _editMessageController = TextEditingController();
  Map<String, Map<String, dynamic>> data = {};
  List<GeneralMessage> messagesList = [];

  Future<void> sendMessage(String name, String message) async {
    DatabaseReference ref = FirebaseDatabase.instance.ref(
        "${widget.path}/${DateTime.now().toString().replaceAll(".", "_")}");
    ref.set({
      name: message,
    });
  }

  @override
  void initState() {
    listenToMessages();
    super.initState();
  }

  void listenToMessages() {
    DatabaseReference ref = FirebaseDatabase.instance.ref(widget.path);
    ref.onValue.listen((event) {
      final data = event.snapshot.value as Map?;
      if (data != null) {
        messagesList.clear();
        data.forEach((timestamp, messageMap) {
          final messageData = Map<String, dynamic>.from(messageMap);
          messageData.forEach((username, message) {
            GeneralMessage messageObj =
                GeneralMessage(message, username, timestamp);
            messagesList.add(messageObj);
          });
        });
        messagesList.sort((a, b) {
          DateTime dateA = DateTime.parse(a.timStamp!.split('_').first);
          DateTime dateB = DateTime.parse(b.timStamp!.split('_').first);
          return dateA.compareTo(dateB);
        });
        setState(() {}); // Refresh the UI with new messages
      }
    });
  }

  Future<void> updateMessage(String timeStamp, String updatedMessage) async {
    DatabaseReference ref =
        FirebaseDatabase.instance.ref("${widget.path}/${timeStamp}");
    await ref.set({widget.name: updatedMessage});
  }

  Future<void> deleteMessage(String timeStamp) async {
    DatabaseReference ref =
        FirebaseDatabase.instance.ref("${widget.path}/${timeStamp}");
    await ref.remove();
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
                child: GestureDetector(
                  onLongPress: () {
                    _editMessageController.text = messagesList[index].message!;
                    if (widget.name != messagesList[index].sender) {
                      return;
                    }
                    showDialog(
                      context: context,
                      builder: (context) => Dialog(
                        child: Column(
                          children: [
                            TextField(
                              controller: _editMessageController,
                            ),
                            Row(
                              children: [
                                MaterialButton(
                                  onPressed: () {
                                    Navigator.pop(context);
                                  },
                                  child: Text("Cancel"),
                                ),
                                MaterialButton(
                                  onPressed: () {
                                    updateMessage(
                                      messagesList[index].timStamp!,
                                      _editMessageController.text,
                                    );
                                    Navigator.pop(context);
                                  },
                                  child: Text("Update"),
                                ),
                                MaterialButton(
                                  onPressed: () {
                                    deleteMessage(
                                        messagesList[index].timStamp!);
                                    Navigator.pop(context);
                                  },
                                  child: Text("Delete"),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  },
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
              if (_textController.text.isNotEmpty) {
                sendMessage(widget.name, _textController.text);
                _textController.clear();
              }
            },
            icon: Icon(CupertinoIcons.up_arrow),
          )
        ],
      ),
    );
  }
}

class GeneralMessage {
  GeneralMessage(this.message, this.sender, this.timStamp) {}
  String? message;
  String? sender;
  String? timStamp;
}

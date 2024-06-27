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
                      _editMessageController.text =
                          messagesList[index].message!;
                      if (widget.name != messagesList[index].sender) {
                        return;
                      }
                      showDialog(
                        context: context,
                        builder: (context) => Dialog(
                          child: Container(
                            padding: EdgeInsets.symmetric(
                                vertical: 20, horizontal: 16),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                Container(
                                  width: double.infinity,
                                  child: TextField(
                                    controller: _editMessageController,
                                    maxLines:
                                        null, // Allow unlimited lines of text
                                    textAlignVertical: TextAlignVertical
                                        .top, // Start text from the top
                                    decoration: InputDecoration(
                                      border: OutlineInputBorder(),
                                      hintText: 'Edit your message...',
                                    ),
                                  ),
                                ),
                                SizedBox(height: 20),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    TextButton(
                                      onPressed: () {
                                        Navigator.pop(context);
                                      },
                                      child: Text("Cancel"),
                                    ),
                                    SizedBox(width: 15),
                                    ElevatedButton(
                                      onPressed: () {
                                        updateMessage(
                                          messagesList[index].timStamp!,
                                          _editMessageController.text,
                                        );
                                        Navigator.pop(context);
                                      },
                                      child: Text("Update"),
                                    ),
                                    SizedBox(width: 15),
                                    TextButton(
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
                        ),
                      );
                    },
                    child: Padding(
                      padding: const EdgeInsets.only(top: 5, left: 8),
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(
                              messagesList[index].message!,
                              style: TextStyle(fontSize: 18),
                              overflow: TextOverflow.ellipsis,
                              maxLines: 10,
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text(
                              " -" + messagesList[index].sender!,
                              style: TextStyle(fontSize: 8),
                              overflow: TextOverflow.ellipsis,
                              maxLines: 10,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
            Row(
              children: [
                Flexible(
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 20.0),
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                    child: TextFormField(
                      controller: _textController,
                      maxLines: null,
                      keyboardType: TextInputType.multiline,
                      decoration: InputDecoration(
                        hintText: 'Type your message here...',
                        border: InputBorder.none,
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 10),
                ElevatedButton.icon(
                  onPressed: () {
                    String message = _textController.text.trim();
                    if (message.isNotEmpty) {
                      sendMessage(widget.name, _textController.text);
                      print('Message sent: $message');

                      _textController.clear();
                    }
                  },
                  icon: Icon(Icons.send),
                  label: Text('SEND'),
                  style: ElevatedButton.styleFrom(
                    padding:
                        EdgeInsets.symmetric(vertical: 15.0, horizontal: 20.0),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ));
  }
}

class GeneralMessage {
  GeneralMessage(this.message, this.sender, this.timStamp) {}
  String? message;
  String? sender;
  String? timStamp;
}

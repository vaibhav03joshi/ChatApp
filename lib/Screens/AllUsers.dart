import 'dart:convert';
import 'dart:math';

import 'package:chat_app_task/Screens/GeneralChat.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';

class AllUsers extends StatefulWidget {
  AllUsers({required this.email, required this.name, super.key});
  String email;
  String name;

  @override
  State<AllUsers> createState() => _AllUsersState();
}

class _AllUsersState extends State<AllUsers> {
  static const String _chars =
      'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789';
  Random _rnd = Random();
  List<UserData> usersList = [];
  @override
  void initState() {
    getUsersData();
    super.initState();
  }

  Future<void> getUsersData() async {
    DatabaseReference ref = FirebaseDatabase.instance.ref("Users/");
    DataSnapshot snapshot = await ref.get();
    var data = jsonDecode(jsonEncode(snapshot.value)) as Map<String, dynamic>;
    data.forEach((key, value) {
      UserData userData = new UserData(
          value["name"], value["email"], value["mobileNumber"], "");
      usersList.add(userData);
    });
    setState(() {});
  }

  Future<void> createContact(String email) async {
    DatabaseReference ref = FirebaseDatabase.instance.ref(
        "Users/${widget.email.replaceAll('@', '').replaceAll('.', '')}/Contacts/${email}/");
    DataSnapshot snapshot = await ref.get();
    if (snapshot.exists) {
      Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => GeneralChat(
                name: "name", path: "PersonalChat/${snapshot.value}/"),
          ));
      return;
    }
    //If Contact don't exist
    String randomString = String.fromCharCodes(Iterable.generate(
        10, (_) => _chars.codeUnitAt(_rnd.nextInt(_chars.length))));
    ref = FirebaseDatabase.instance.ref(
        "Users/${widget.email.replaceAll('@', '').replaceAll('.', '')}/Contacts");
    ref.update({email: randomString});
    ref = FirebaseDatabase.instance.ref("Users/${email}/Contacts");
    ref.update(
        {widget.email.replaceAll('@', '').replaceAll('.', ''): randomString});
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => GeneralChat(
            name: widget.name, path: "PersonalChat/${randomString}/"),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("All Users"),
      ),
      body: ListView.builder(
        itemCount: usersList.length,
        itemBuilder: (context, index) => MaterialButton(
          onPressed: () {
            createContact(
                usersList[index].email.replaceAll('@', '').replaceAll('.', ''));
          },
          child: Row(
            children: [
              Text(usersList[index].name),
              Text("      " + usersList[index].email),
            ],
          ),
        ),
      ),
    );
  }
}

class UserData {
  UserData(this.name, this.email, this.number, this.value);
  String name;
  String email;
  String number;
  String? value;
}
